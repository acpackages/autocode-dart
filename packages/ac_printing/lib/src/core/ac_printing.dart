import 'dart:typed_data';
import 'package:autocode/autocode.dart';
import '../models/ac_page_format.dart';
import '../models/ac_print_settings.dart';
import '../models/ac_printer.dart';
import '../platform/ac_printing_platform.dart';

class AcPrinting {
  AcPrinter? activePrinter;

  static List<AcPrinter>? _cachedPrinters;
  static DateTime? _cacheTimestamp;
  static const Duration defaultCacheTtl = Duration(seconds: 30);

  /// Clears the in-memory printer list cache.
  static void clearCache() {
    _cachedPrinters = null;
    _cacheTimestamp = null;
  }

  /// Retrieves all available printers installed on the system, with in-memory TTL caching.
  Future<AcResult> getPrinters({
    bool refresh = false,
    Duration ttl = defaultCacheTtl,
  }) async {
    final result = AcResult();
    try {
      if (!refresh && _cachedPrinters != null && _cacheTimestamp != null) {
        if (DateTime.now().difference(_cacheTimestamp!) < ttl) {
          result.setSuccess(value: _cachedPrinters!);
          return result;
        }
      }

      final List<AcPrinter> printers = await AcPrintingPlatform.instance.getPrinters();
      _cachedPrinters = printers;
      _cacheTimestamp = DateTime.now();
      result.setSuccess(value: printers);
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    }
    return result;
  }

  /// Shares a PDF document (opens the system share dialog or default viewer).
  ///
  /// [bytes]: The PDF document as Uint8List.
  /// [name]: Optional filename for the shared PDF (defaults to 'document.pdf').
  Future<bool> sharePdf({
    required Uint8List bytes,
    String name = 'document.pdf',
  }) async {
    try {
      return await AcPrintingPlatform.instance.sharePdf(bytes: bytes, name: name);
    } catch (_) {
      return false;
    }
  }

  /// Sends a PDF document to a printer.
  ///
  /// [pdfBytes]: The complete PDF as Uint8List.
  /// [printer]: Target printer model.
  /// [printerName]: Target printer name.
  /// [pageFormat]: Desired page format.
  /// [settings]: Detailed print settings (copies, color, duplex, orientation).
  /// [jobName]: Document title shown in print spooler.
  /// [asynchronous]: When `true`, dispatches the print job in the background and returns immediately (< 15 ms).
  Future<AcResult> printPdf({
    required Uint8List pdfBytes,
    AcPrinter? printer,
    String? printerName,
    AcPageFormat? pageFormat,
    AcPrintSettings? settings,
    String jobName = 'Document',
    bool asynchronous = false,
  }) async {
    final result = AcResult();
    try {
      AcPrinter? printerToUse;

      // Fast-path: When printer or printerName is specified, bypass system discovery
      if (printerName != null && printerName.isNotEmpty) {
        if (_cachedPrinters != null) {
          for (final p in _cachedPrinters!) {
            if (p.name.toLowerCase() == printerName.toLowerCase()) {
              printerToUse = p;
              break;
            }
          }
        }
        printerToUse ??= (AcPrinter()
          ..name = printerName
          ..isAvailable = true);
      } else if (printer != null) {
        printerToUse = printer;
      } else if (activePrinter != null) {
        printerToUse = activePrinter;
      } else {
        // Fallback: Only enumerate if we must discover the default printer
        final printersResult = await getPrinters();
        final printers = printersResult.isSuccess() && printersResult.value is List<AcPrinter>
            ? printersResult.value as List<AcPrinter>
            : <AcPrinter>[];

        for (final p in printers) {
          if (p.isDefault) {
            printerToUse = p;
            break;
          }
        }
        if (printerToUse == null && printers.isNotEmpty) {
          printerToUse = printers.first;
        }
      }

      if (printerToUse != null && !printerToUse.isAvailable) {
        result.setFailure(message: 'printer "${printerToUse.name}" is not available');
        return result;
      }

      final detectedFormat = (pageFormat == null || pageFormat.width <= 0)
          ? AcPageFormat.fromPdfBytes(pdfBytes)
          : null;
      final effectivePageFormat = pageFormat ?? settings?.pageFormat ?? detectedFormat;
      AcPrintSettings? effectiveSettings = settings;
      if (effectivePageFormat != null && effectiveSettings != null) {
        effectiveSettings.pageFormat = effectivePageFormat;
      } else if (effectivePageFormat != null && effectiveSettings == null) {
        effectiveSettings = AcPrintSettings()..pageFormat = effectivePageFormat;
      }

      final success = await AcPrintingPlatform.instance.printPdf(
        pdfBytes: pdfBytes,
        printer: printerToUse,
        printerName: printerToUse?.name,
        pageFormat: effectivePageFormat,
        settings: effectiveSettings,
        jobName: jobName,
        asynchronous: asynchronous,
      );

      if (success) {
        result.setSuccess();
      } else {
        result.setFailure(
            message: 'could not print to "${printerToUse?.name ?? 'default printer'}"');
      }
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    }

    return result;
  }

  /// Convenience method to directly print a PDF to a specific printer.
  Future<AcResult> directPrintPdf({
    required Uint8List pdfBytes,
    AcPrinter? printer,
    String? printerName,
    AcPageFormat? pageFormat,
    AcPrintSettings? settings,
    String jobName = 'Document',
  }) {
    return printPdf(
      pdfBytes: pdfBytes,
      printer: printer,
      printerName: printerName,
      pageFormat: pageFormat,
      settings: settings,
      jobName: jobName,
    );
  }

  /// Sends raw bytes (ESC/POS receipt, TSPL/ZPL label, PostScript) directly to a printer.
  ///
  /// [bytes]: The raw commands or payload as Uint8List.
  /// [printer]: Target printer model.
  /// [printerName]: Target printer name.
  /// [jobName]: Document title shown in print spooler.
  /// [dataType]: Spooler data type (e.g. 'RAW', 'TEXT').
  Future<AcResult> printRaw({
    required Uint8List bytes,
    AcPrinter? printer,
    String? printerName,
    String jobName = 'Receipt',
    String dataType = 'RAW',
  }) async {
    final result = AcResult();
    try {
      AcPrinter? printerToUse;
      if (printerName != null && printerName.isNotEmpty) {
        if (_cachedPrinters != null) {
          for (final p in _cachedPrinters!) {
            if (p.name.toLowerCase() == printerName.toLowerCase()) {
              printerToUse = p;
              break;
            }
          }
        }
        printerToUse ??= (AcPrinter()
          ..name = printerName
          ..isAvailable = true);
      } else if (printer != null) {
        printerToUse = printer;
      } else if (activePrinter != null) {
        printerToUse = activePrinter;
      } else {
        final printersResult = await getPrinters();
        final printers = printersResult.isSuccess() && printersResult.value is List<AcPrinter>
            ? printersResult.value as List<AcPrinter>
            : <AcPrinter>[];

        for (final p in printers) {
          if (p.isDefault) {
            printerToUse = p;
            break;
          }
        }
        if (printerToUse == null && printers.isNotEmpty) {
          printerToUse = printers.first;
        }
      }

      if (printerToUse != null && !printerToUse.isAvailable) {
        result.setFailure(message: 'printer "${printerToUse.name}" is not available');
        return result;
      }

      final success = await AcPrintingPlatform.instance.printRaw(
        bytes: bytes,
        printer: printerToUse,
        printerName: printerToUse?.name,
        jobName: jobName,
        dataType: dataType,
      );

      if (success) {
        result.setSuccess();
      } else {
        result.setFailure(
            message: 'could not send raw data to "${printerToUse?.name ?? 'default printer'}"');
      }
    } catch (ex, stack) {
      result.setException(exception: ex, stackTrace: stack);
    }
    return result;
  }
}
