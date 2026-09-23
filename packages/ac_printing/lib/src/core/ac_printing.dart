import 'dart:typed_data';
import 'package:autocode/autocode.dart';
import '../models/ac_page_format.dart';
import '../models/ac_print_settings.dart';
import '../models/ac_printer.dart';
import '../platform/ac_printing_platform.dart';

class AcPrinting {
  AcPrinter? activePrinter;

  /// Retrieves all available printers installed on the system.
  Future<AcResult> getPrinters() async {
    final result = AcResult();
    try {
      final List<AcPrinter> printers = await AcPrintingPlatform.instance.getPrinters();
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
  Future<AcResult> printPdf({
    required Uint8List pdfBytes,
    AcPrinter? printer,
    String? printerName,
    AcPageFormat? pageFormat,
    AcPrintSettings? settings,
    String jobName = 'Document',
  }) async {
    final result = AcResult();
    try {
      final printersResult = await getPrinters();
      final printers = printersResult.isSuccess() && printersResult.value is List<AcPrinter>
          ? printersResult.value as List<AcPrinter>
          : <AcPrinter>[];

      AcPrinter? printerToUse;
      if (printerName != null && printerName.isNotEmpty) {
        for (final p in printers) {
          if (p.name.toLowerCase() == printerName.toLowerCase()) {
            printerToUse = p;
            break;
          }
        }
        printerToUse ??= (AcPrinter()..name = printerName);
      } else if (printer != null) {
        printerToUse = printer;
      } else if (activePrinter != null) {
        printerToUse = activePrinter;
      } else {
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

      final effectivePageFormat = pageFormat ?? settings?.pageFormat ?? AcPageFormat.instanceFromName(name: 'A4');
      final effectiveSettings = settings ?? (AcPrintSettings()..pageFormat = effectivePageFormat);
      effectiveSettings.pageFormat = effectivePageFormat;

      final success = await AcPrintingPlatform.instance.printPdf(
        pdfBytes: pdfBytes,
        printer: printerToUse,
        printerName: printerToUse?.name,
        pageFormat: effectivePageFormat,
        settings: effectiveSettings,
        jobName: jobName,
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
}