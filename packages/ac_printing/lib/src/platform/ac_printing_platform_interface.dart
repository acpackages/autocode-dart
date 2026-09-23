import 'dart:typed_data';
import '../models/ac_page_format.dart';
import '../models/ac_print_settings.dart';
import '../models/ac_printer.dart';

abstract class AcPrintingPlatformAdapter {
  Future<List<AcPrinter>> getPrinters();

  Future<bool> printPdf({
    required Uint8List pdfBytes,
    AcPrinter? printer,
    String? printerName,
    AcPageFormat? pageFormat,
    AcPrintSettings? settings,
    String jobName = 'Document',
  });

  Future<bool> sharePdf({
    required Uint8List bytes,
    String name = 'document.pdf',
  });

  bool get isDirectPrintSupported => true;
}
