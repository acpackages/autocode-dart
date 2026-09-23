import 'dart:typed_data';
import 'package:ac_printing/ac_printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<void> main() async {
  print('=== AcPrinting CLI Example ===\n');

  final acPrinting = AcPrinting();

  // 1. Retrieve all available printers on this system
  print('Discovering system printers...');
  final result = await acPrinting.getPrinters();

  if (result.isSuccess() && result.value is List<AcPrinter>) {
    final printers = result.value as List<AcPrinter>;
    print('Found ${printers.length} printer(s):\n');
    for (int i = 0; i < printers.length; i++) {
      final p = printers[i];
      final defaultMark = p.isDefault ? ' [DEFAULT]' : '';
      print('${i + 1}. ${p.name}$defaultMark');
      print('   - Driver: ${p.driverName}');
      print('   - Port / URL: ${p.url}');
      print('   - Available: ${p.isAvailable}');
      if (p.location.isNotEmpty) print('   - Location: ${p.location}');
      if (p.comment.isNotEmpty) print('   - Comment: ${p.comment}');
      print('');
    }
  } else {
    print('Failed to get printers: ${result.message}');
  }

  // 2. Generate a minimal PDF in memory using the pdf package
  print('Generating sample PDF...');
  final pdf = pw.Document();
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Text(
            'Hello from AcPrinting Native Dart CLI!',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
        );
      },
    ),
  );

  final Uint8List pdfBytes = await pdf.save();
  print('Generated PDF: ${pdfBytes.lengthInBytes} bytes');

  print('\nAcPrinting ready. Call acPrinting.printPdf(pdfBytes: pdfBytes) to send to any printer.');
}
