import 'dart:typed_data';
import '../models/ac_page_format.dart';
import '../models/ac_print_settings.dart';
import '../models/ac_printer.dart';
import 'ac_printing_platform_interface.dart';

AcPrintingPlatformAdapter getPlatformAdapter() => AcPrintingStubAdapter();

class AcPrintingStubAdapter implements AcPrintingPlatformAdapter {
  @override
  Future<List<AcPrinter>> getPrinters() async {
    return <AcPrinter>[];
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
    throw UnsupportedError('Printing is not supported on this platform.');
  }

  @override
  Future<bool> sharePdf({
    required Uint8List bytes,
    String name = 'document.pdf',
  }) async {
    throw UnsupportedError('Sharing is not supported on this platform.');
  }

  @override
  bool get isDirectPrintSupported => false;
}
