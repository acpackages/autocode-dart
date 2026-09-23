import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import '../../models/ac_page_format.dart';
import '../../models/ac_print_settings.dart';
import '../../models/ac_printer.dart';
import '../ac_printing_platform_interface.dart';

class AcCupsPrinting implements AcPrintingPlatformAdapter {
  @override
  Future<List<AcPrinter>> getPrinters() async {
    final printers = <AcPrinter>[];
    String defaultPrinter = '';

    try {
      final statResult = await Process.run('lpstat', ['-p', '-d']);
      if (statResult.exitCode == 0) {
        final stdoutText = statResult.stdout.toString();
        final lines = LineSplitter.split(stdoutText);

        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.startsWith('system default destination:')) {
            defaultPrinter = trimmed.replaceFirst('system default destination:', '').trim();
          } else if (trimmed.startsWith('printer ')) {
            final parts = trimmed.split(' ');
            if (parts.length > 1) {
              final printerName = parts[1];
              final isAvailable = !trimmed.contains('disabled');
              final printer = AcPrinter()
                ..name = printerName
                ..isAvailable = isAvailable
                ..isDefault = false;
              printers.add(printer);
            }
          }
        }
      }
    } catch (_) {
      // lpstat may not be installed or available in minimal containers
    }

    try {
      final deviceResult = await Process.run('lpstat', ['-v']);
      if (deviceResult.exitCode == 0) {
        final lines = LineSplitter.split(deviceResult.stdout.toString());
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.startsWith('device for ')) {
            final colonIdx = trimmed.indexOf(':');
            if (colonIdx > 0) {
              final header = trimmed.substring(0, colonIdx);
              final uri = trimmed.substring(colonIdx + 1).trim();
              final printerName = header.replaceFirst('device for ', '').trim();
              for (final p in printers) {
                if (p.name == printerName) {
                  p.url = uri;
                  break;
                }
              }
            }
          }
        }
      }
    } catch (_) {}

    for (final p in printers) {
      if (p.name == defaultPrinter && defaultPrinter.isNotEmpty) {
        p.isDefault = true;
      }
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
    final tempDir = Directory.systemTemp;
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final tempFile = File('${tempDir.path}/ac_print_$timestamp.pdf');

    try {
      await tempFile.writeAsBytes(pdfBytes, flush: true);

      final args = <String>[];
      final targetPrinter = printerName ?? printer?.name;
      if (targetPrinter != null && targetPrinter.isNotEmpty) {
        args.addAll(['-d', targetPrinter]);
      }

      args.addAll(['-t', jobName]);

      if (settings != null) {
        if (settings.copies > 1) {
          args.addAll(['-n', settings.copies.toString()]);
        }
        if (settings.orientation.toLowerCase() == 'landscape') {
          args.addAll(['-o', 'orientation-requested=4']);
        }
        if (settings.duplex) {
          args.addAll(['-o', 'sides=two-sided-long-edge']);
        }
      }

      final effectiveFormat = pageFormat ?? settings?.pageFormat;
      if (effectiveFormat != null && effectiveFormat.width > 0 && effectiveFormat.height > 0) {
        final mediaOption = _resolveCupsMedia(effectiveFormat);
        args.addAll(['-o', 'media=$mediaOption']);
        if (!effectiveFormat.isPortrait) {
          args.addAll(['-o', 'landscape']);
        }
        args.addAll(['-o', 'fit-to-page']);
      }

      args.add(tempFile.path);

      final result = await Process.run('lp', args);
      return result.exitCode == 0;
    } catch (e) {
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

  @override
  Future<bool> sharePdf({
    required Uint8List bytes,
    String name = 'document.pdf',
  }) async {
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/$name');

    try {
      await tempFile.writeAsBytes(bytes, flush: true);
      if (Platform.isMacOS) {
        final result = await Process.run('open', [tempFile.path]);
        return result.exitCode == 0;
      } else {
        final result = await Process.run('xdg-open', [tempFile.path]);
        return result.exitCode == 0;
      }
    } catch (_) {
      return false;
    }
  }

  String _resolveCupsMedia(AcPageFormat format) {
    // Check standard sizes by dimensions (within 2mm tolerance)
    if ((format.width - 210).abs() <= 2 && (format.height - 297).abs() <= 2) return 'A4';
    if ((format.width - 216).abs() <= 2 && (format.height - 279).abs() <= 2) return 'Letter';
    if ((format.width - 216).abs() <= 2 && (format.height - 356).abs() <= 2) return 'Legal';
    if ((format.width - 297).abs() <= 2 && (format.height - 420).abs() <= 2) return 'A3';
    if ((format.width - 148).abs() <= 2 && (format.height - 210).abs() <= 2) return 'A5';
    if ((format.width - 105).abs() <= 2 && (format.height - 148).abs() <= 2) return 'A6';
    if ((format.width - 182).abs() <= 2 && (format.height - 257).abs() <= 2) return 'B5';

    // Fallback to custom dimensions with Custom. prefix required by CUPS
    final w = format.width.round();
    final h = format.height > 0 ? format.height.round() : 200;
    return 'Custom.${w}x${h}mm';
  }

  @override
  bool get isDirectPrintSupported => true;
}

