import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() async {
  final doc = pw.Document();
  // A4 Landscape: width = 297mm, height = 210mm
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      build: (c) => pw.Container(
        decoration: pw.BoxDecoration(border: pw.Border.all(width: 2)),
        child: pw.Center(
          child: pw.Text('TAX INVOICE - A4 LANDSCAPE', style: pw.TextStyle(fontSize: 28)),
        ),
      ),
    ),
  );
  await File('landscape_test.pdf').writeAsBytes(await doc.save());
  print('landscape_test.pdf generated');
}
