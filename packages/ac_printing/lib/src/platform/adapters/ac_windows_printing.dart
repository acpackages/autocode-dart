import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import '../../models/ac_page_format.dart';
import '../../models/ac_print_settings.dart';
import '../../models/ac_printer.dart';
import '../ac_printing_platform_interface.dart';
import 'ac_winspool_ffi.dart';

class AcWindowsPrinting implements AcPrintingPlatformAdapter {
  @override
  Future<List<AcPrinter>> getPrinters() async {
    final printers = <AcPrinter>[];

    try {
      const psCommand =
          '@(Get-CimInstance Win32_Printer | Select-Object Name,DriverName,PortName,Default,PrinterStatus,Location,Comment) | ConvertTo-Json -Compress';
      final result = await Process.run(
        'powershell',
        ['-NoProfile', '-NonInteractive', '-Command', psCommand],
      );

      if (result.exitCode == 0) {
        final stdoutText = result.stdout.toString().trim();
        if (stdoutText.isNotEmpty) {
          final decoded = jsonDecode(stdoutText);
          final List<dynamic> items = decoded is List ? decoded : [decoded];

          for (final item in items) {
            if (item is Map) {
              final printer = AcPrinter()
                ..name = item['Name']?.toString() ?? ''
                ..driverName = item['DriverName']?.toString() ?? ''
                ..url = item['PortName']?.toString() ?? ''
                ..isDefault = item['Default'] == true
                ..location = item['Location']?.toString() ?? ''
                ..comment = item['Comment']?.toString() ?? ''
                ..isAvailable = item['PrinterStatus'] == null ||
                    item['PrinterStatus'] == 3 ||
                    item['PrinterStatus'] == 0;
              printers.add(printer);
            }
          }
        }
      }
    } catch (_) {}

    // Fallback: If CIM returned nothing or failed, try legacy WMI
    if (printers.isEmpty) {
      try {
        const fallbackCmd =
            '@(Get-WmiObject -Class Win32_Printer | Select-Object Name,DriverName,PortName,Default,PrinterStatus,Location,Comment) | ConvertTo-Json -Compress';
        final result = await Process.run(
          'powershell',
          ['-NoProfile', '-NonInteractive', '-Command', fallbackCmd],
        );
        if (result.exitCode == 0) {
          final stdoutText = result.stdout.toString().trim();
          if (stdoutText.isNotEmpty) {
            final decoded = jsonDecode(stdoutText);
            final List<dynamic> items = decoded is List ? decoded : [decoded];
            for (final item in items) {
              if (item is Map) {
                final printer = AcPrinter()
                  ..name = item['Name']?.toString() ?? ''
                  ..driverName = item['DriverName']?.toString() ?? ''
                  ..url = item['PortName']?.toString() ?? ''
                  ..isDefault = item['Default'] == true
                  ..location = item['Location']?.toString() ?? ''
                  ..comment = item['Comment']?.toString() ?? ''
                  ..isAvailable = true;
                printers.add(printer);
              }
            }
          }
        }
      } catch (_) {}
    }

    return printers;
  }

  @override
  Future<bool> printPdf({
    required Uint8List pdfBytes,
    AcPrinter? printer,
    String? printerName,
    AcPageFormat? pageFormat,
    AcPrintSettings? settings,
    String jobName = 'Document',
  }) async {
    final targetPrinter = printerName ?? printer?.name ?? '';
    final hasExplicitFormat = (pageFormat != null && pageFormat.width > 0) ||
        (settings?.pageFormat != null && settings!.pageFormat.width > 0);
    final widthMm = hasExplicitFormat
        ? (pageFormat?.width ?? settings!.pageFormat.width)
        : 0.0;
    final heightMm = hasExplicitFormat
        ? (pageFormat?.height ?? settings!.pageFormat.height)
        : 0.0;
    final orientation = settings?.orientation.toLowerCase() ??
        (pageFormat != null ? (pageFormat.isPortrait ? 'portrait' : 'landscape') : 'auto');
    final copies = settings?.copies ?? 1;

    final tempDir = Directory.systemTemp;
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final tempFile = File('${tempDir.path}\\ac_print_$timestamp.pdf');

    try {
      await tempFile.writeAsBytes(pdfBytes, flush: true);

      // Strategy 1: Native Windows WinRT + PrintDocument with high DPI & auto-orientation
      final success = await _printViaWinRtPrintDocument(
        pdfFile: tempFile,
        printerName: targetPrinter,
        widthMm: widthMm,
        heightMm: heightMm,
        orientation: orientation,
        copies: copies,
        jobName: jobName,
      );

      if (success) return true;

      // Strategy 2: System PrintTo verb via PowerShell
      final escapedPath = tempFile.path.replaceAll("'", "''");
      final escapedPrinter = targetPrinter.replaceAll("'", "''");

      String psCommand;
      if (escapedPrinter.isNotEmpty) {
        psCommand =
            'Start-Process -FilePath \'$escapedPath\' -Verb PrintTo -ArgumentList \'"$escapedPrinter"\' -WindowStyle Hidden -Wait';
      } else {
        psCommand =
            'Start-Process -FilePath \'$escapedPath\' -Verb Print -WindowStyle Hidden -Wait';
      }

      final procResult = await Process.run(
        'powershell',
        ['-NoProfile', '-NonInteractive', '-Command', psCommand],
      );

      if (procResult.exitCode == 0) {
        return true;
      }

      // Strategy 3: Edge silent print if available
      final edgePaths = [
        'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe',
        'C:\\Program Files\\Microsoft\\Edge\\Application\\msedge.exe',
      ];
      for (final edgePath in edgePaths) {
        if (File(edgePath).existsSync()) {
          final edgeArgs = ['--headless', '--disable-gpu'];
          if (targetPrinter.isNotEmpty) {
            edgeArgs.add('--print-to-printer=$targetPrinter');
          }
          edgeArgs.add(tempFile.path);

          final edgeResult = await Process.run(edgePath, edgeArgs);
          if (edgeResult.exitCode == 0) {
            return true;
          }
          break;
        }
      }

      // Strategy 4: Direct WinSpool FFI (useful for POS/receipt/raw printers)
      if (targetPrinter.isNotEmpty) {
        final ffiSuccess = AcWinSpool.printRawBytes(
          printerName: targetPrinter,
          bytes: pdfBytes,
          docName: jobName,
        );
        if (ffiSuccess) return true;
      }

      return false;
    } catch (_) {
      return false;
    } finally {
      Future.delayed(const Duration(seconds: 15), () async {
        try {
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        } catch (_) {}
      });
    }
  }

  Future<bool> _printViaWinRtPrintDocument({
    required File pdfFile,
    required String printerName,
    required double widthMm,
    required double heightMm,
    required String orientation,
    required int copies,
    required String jobName,
  }) async {
    try {
      final script = '''
param(
    [string]\$PdfPath,
    [string]\$PrinterName,
    [double]\$WidthMm,
    [double]\$HeightMm,
    [string]\$Orientation,
    [int]\$Copies,
    [string]\$DocTitle
)

try {
    Add-Type -AssemblyName System.Runtime.WindowsRuntime -ErrorAction Stop
    Add-Type -AssemblyName System.Drawing -ErrorAction Stop

    [Windows.Storage.StorageFile, Windows.Storage, ContentType = WindowsRuntime] | Out-Null
    [Windows.Data.Pdf.PdfDocument, Windows.Data.Pdf, ContentType = WindowsRuntime] | Out-Null
    [Windows.Storage.Streams.InMemoryRandomAccessStream, Windows.Storage.Streams, ContentType = WindowsRuntime] | Out-Null
    [Windows.Data.Pdf.PdfPageRenderOptions, Windows.Data.Pdf, ContentType = WindowsRuntime] | Out-Null

    \$methods = [System.WindowsRuntimeSystemExtensions].GetMethods()
    \$asTaskGeneric = (\$methods | Where-Object { 
        \$_.Name -eq 'AsTask' -and 
        \$_.IsGenericMethod -and 
        \$_.GetParameters().Count -eq 1 -and 
        \$_.GetParameters()[0].ParameterType.Name.StartsWith('IAsyncOperation')
    })[0]

    \$asTaskAction = (\$methods | Where-Object { 
        \$_.Name -eq 'AsTask' -and 
        (-not \$_.IsGenericMethod) -and 
        \$_.GetParameters().Count -eq 1 -and 
        \$_.GetParameters()[0].ParameterType.Name -eq 'IAsyncAction'
    })[0]

    function Await-WinRT(\$winRtTask, [Type]\$resultType) {
        \$m = \$asTaskGeneric.MakeGenericMethod(\$resultType)
        \$task = \$m.Invoke(\$null, @(\$winRtTask))
        \$task.Wait(-1) | Out-Null
        return \$task.Result
    }

    function Await-Action(\$winRtAction) {
        \$task = \$asTaskAction.Invoke(\$null, @(\$winRtAction))
        \$task.Wait(-1) | Out-Null
    }

    \$file = Await-WinRT ([Windows.Storage.StorageFile]::GetFileFromPathAsync(\$PdfPath)) ([Windows.Storage.StorageFile])
    \$doc = Await-WinRT ([Windows.Data.Pdf.PdfDocument]::LoadFromFileAsync(\$file)) ([Windows.Data.Pdf.PdfDocument])

    if (\$doc.PageCount -eq 0) {
        exit 0
    }

    \$pd = New-Object System.Drawing.Printing.PrintDocument
    if (\$PrinterName -ne "") {
        \$pd.PrinterSettings.PrinterName = \$PrinterName
    }
    \$pd.DocumentName = \$DocTitle
    \$pd.DefaultPageSettings.Margins = New-Object System.Drawing.Printing.Margins(0, 0, 0, 0)
    \$pd.OriginAtMargins = \$false

    if (\$Copies -gt 1) {
        \$pd.PrinterSettings.Copies = \$Copies
    }

    # Match paper size
    if (\$WidthMm -gt 0 -and \$HeightMm -gt 0) {
        \$docShort = [Math]::Min(\$WidthMm, \$HeightMm)
        \$docLong = [Math]::Max(\$WidthMm, \$HeightMm)
    } else {
        \$p0 = \$doc.GetPage(0)
        \$docShort = [Math]::Min(\$p0.Size.Width, \$p0.Size.Height) * 25.4 / 72.0
        \$docLong = [Math]::Max(\$p0.Size.Width, \$p0.Size.Height) * 25.4 / 72.0
    }

    \$targetShort = [int](\$docShort / 25.4 * 100)
    \$targetLong = [int](\$docLong / 25.4 * 100)

    \$bestMatch = \$null
    \$bestDiff = 999999

    foreach (\$ps in \$pd.PrinterSettings.PaperSizes) {
        \$psShort = [Math]::Min(\$ps.Width, \$ps.Height)
        \$psLong = [Math]::Max(\$ps.Width, \$ps.Height)
        \$diffShort = [Math]::Abs(\$psShort - \$targetShort)
        \$diffLong = [Math]::Abs(\$psLong - \$targetLong)
        \$totalDiff = \$diffShort + \$diffLong

        # Max tolerance: 10 hundredths of an inch (~2.5mm) per dimension to avoid false matches (e.g. Statement vs A5)
        if (\$diffShort -le 10 -and \$diffLong -le 10 -and \$totalDiff -lt \$bestDiff) {
            \$bestDiff = \$totalDiff
            \$bestMatch = \$ps
            if (\$totalDiff -eq 0) { break }
        }
    }

    if (\$bestMatch) {
        \$pd.DefaultPageSettings.PaperSize = \$bestMatch
    } elseif (\$WidthMm -gt 0 -and \$HeightMm -gt 0) {
        \$pd.DefaultPageSettings.PaperSize = New-Object System.Drawing.Printing.PaperSize("Custom", \$targetShort, \$targetLong)
    }

    \$script:pageIndex = 0

    \$pd.add_QueryPageSettings({
        param(\$sender, \$e)
        if (\$script:pageIndex -lt \$doc.PageCount) {
            \$p = \$doc.GetPage(\$script:pageIndex)
            \$isLandscape = (\$p.Size.Width -gt \$p.Size.Height)
            if (\$Orientation.ToLower() -eq "landscape") {
                \$e.PageSettings.Landscape = \$true
            } elseif (\$Orientation.ToLower() -eq "portrait") {
                \$e.PageSettings.Landscape = \$false
            } else {
                \$e.PageSettings.Landscape = \$isLandscape
            }
        }
    })

    \$pd.add_PrintPage({
        param(\$sender, \$e)
        if (\$script:pageIndex -lt \$doc.PageCount) {
            \$p = \$doc.GetPage(\$script:pageIndex)
            \$stream = New-Object Windows.Storage.Streams.InMemoryRandomAccessStream

            \$opt = New-Object Windows.Data.Pdf.PdfPageRenderOptions
            \$dpiScale = 300.0 / 72.0
            \$opt.DestinationWidth = [uint32][Math]::Round(\$p.Size.Width * \$dpiScale)
            \$opt.DestinationHeight = [uint32][Math]::Round(\$p.Size.Height * \$dpiScale)

            Await-Action (\$p.RenderToStreamAsync(\$stream, \$opt))
            \$netStream = [System.IO.WindowsRuntimeStreamExtensions]::AsStreamForRead(\$stream)
            \$bmp = [System.Drawing.Bitmap]::FromStream(\$netStream)

            \$pageW = \$e.PageBounds.Width
            \$pageH = \$e.PageBounds.Height

            \$scaleX = \$pageW / \$bmp.Width
            \$scaleY = \$pageH / \$bmp.Height
            \$fitScale = [Math]::Min(\$scaleX, \$scaleY)

            \$destW = [int][Math]::Round(\$bmp.Width * \$fitScale)
            \$destH = [int][Math]::Round(\$bmp.Height * \$fitScale)
            \$destX = [int][Math]::Round((\$pageW - \$destW) / 2.0)
            \$destY = [int][Math]::Round((\$pageH - \$destH) / 2.0)

            \$destRect = New-Object System.Drawing.Rectangle(\$destX, \$destY, \$destW, \$destH)

            \$e.Graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            \$e.Graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
            \$e.Graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
            \$e.Graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality

            \$e.Graphics.DrawImage(\$bmp, \$destRect)

            \$bmp.Dispose()
            \$netStream.Dispose()
            \$stream.Dispose()

            \$script:pageIndex++
            \$e.HasMorePages = (\$script:pageIndex -lt \$doc.PageCount)
        } else {
            \$e.HasMorePages = \$false
        }
    })

    \$pd.PrintController = New-Object System.Drawing.Printing.StandardPrintController
    \$pd.Print()
    exit 0
} catch {
    [Console]::Error.WriteLine(\$_)
    exit 1
}
''';

      final tempScript = File(
          '${pdfFile.parent.path}\\ac_win_print_${DateTime.now().microsecondsSinceEpoch}.ps1');
      await tempScript.writeAsString(script, flush: true);

      try {
        final result = await Process.run(
          'powershell',
          [
            '-NoProfile',
            '-ExecutionPolicy',
            'Bypass',
            '-File',
            tempScript.path,
            '-PdfPath',
            pdfFile.path,
            '-PrinterName',
            printerName,
            '-WidthMm',
            widthMm.toString(),
            '-HeightMm',
            heightMm.toString(),
            '-Orientation',
            orientation,
            '-Copies',
            copies.toString(),
            '-DocTitle',
            jobName,
          ],
        );
        return result.exitCode == 0;
      } finally {
        if (await tempScript.exists()) {
          await tempScript.delete();
        }
      }
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> sharePdf({
    required Uint8List bytes,
    String name = 'document.pdf',
  }) async {
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}\\$name');

    try {
      await tempFile.writeAsBytes(bytes, flush: true);
      final result = await Process.run('cmd', ['/c', 'start', '', tempFile.path]);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  @override
  bool get isDirectPrintSupported => true;
}
