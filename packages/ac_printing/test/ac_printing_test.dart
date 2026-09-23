import 'dart:typed_data';
import 'package:ac_printing/ac_printing.dart';
import 'package:test/test.dart';

class MockPrintingAdapter implements AcPrintingPlatformAdapter {
  bool printPdfCalled = false;
  bool sharePdfCalled = false;
  Uint8List? lastPdfBytes;
  String? lastPrinterName;

  @override
  Future<List<AcPrinter>> getPrinters() async {
    return [
      AcPrinter()
        ..name = 'Mock Laser Printer'
        ..driverName = 'Mock Driver'
        ..url = 'USB001'
        ..isDefault = true
        ..isAvailable = true,
      AcPrinter()
        ..name = 'Mock Label Printer'
        ..driverName = 'Zebra Driver'
        ..url = 'COM1'
        ..isDefault = false
        ..isAvailable = true,
    ];
  }

  AcPageFormat? lastPageFormat;
  AcPrintSettings? lastSettings;

  @override
  Future<bool> printPdf({
    required Uint8List pdfBytes,
    AcPrinter? printer,
    String? printerName,
    AcPageFormat? pageFormat,
    AcPrintSettings? settings,
    String jobName = 'Document',
  }) async {
    printPdfCalled = true;
    lastPdfBytes = pdfBytes;
    lastPrinterName = printerName ?? printer?.name;
    lastPageFormat = pageFormat;
    lastSettings = settings;
    return true;
  }

  @override
  Future<bool> sharePdf({
    required Uint8List bytes,
    String name = 'document.pdf',
  }) async {
    sharePdfCalled = true;
    lastPdfBytes = bytes;
    return true;
  }

  @override
  bool get isDirectPrintSupported => true;
}

void main() {
  group('AcPrinting Model & PageFormat Tests', () {
    test('AcPrinter JSON serialization roundtrip', () {
      final printer = AcPrinter()
        ..name = 'Office Printer'
        ..url = '192.168.1.100'
        ..driverName = 'HP LaserJet'
        ..location = '2nd Floor'
        ..comment = 'Color printer'
        ..isDefault = true
        ..isAvailable = true;

      final json = printer.toJson();
      expect(json['name'], equals('Office Printer'));
      expect(json['url'], equals('192.168.1.100'));
      expect(json['driver_name'], equals('HP LaserJet'));
      expect(json['is_default'], isTrue);

      final restored = AcPrinter.instanceFromJson(jsonData: json);
      expect(restored.name, equals('Office Printer'));
      expect(restored.driverName, equals('HP LaserJet'));
      expect(restored.isDefault, isTrue);
    });

    test('AcPageFormat standard sizes and conversions', () {
      final a4 = AcPageFormat.instanceFromName(name: 'A4');
      expect(a4.width, equals(210.0));
      expect(a4.height, equals(297.0));

      final letter = AcPageFormat.instanceFromName(name: 'LETTER');
      expect(letter.width, equals(216.0));
      expect(letter.height, equals(279.0));

      final pdfFormat = a4.toPdfPageFormat();
      expect(pdfFormat.width, closeTo(210.0 * 72.0 / 25.4, 0.1));
    });

    test('AcPrintSettings configuration and serialization', () {
      final settings = AcPrintSettings()
        ..copies = 3
        ..color = true
        ..duplex = true
        ..orientation = 'landscape';

      final json = settings.toJson();
      expect(json['copies'], equals(3));
      expect(json['color'], isTrue);
      expect(json['duplex'], isTrue);
      expect(json['orientation'], equals('landscape'));
    });
  });

  group('AcPrinting Engine & Platform Tests', () {
    late MockPrintingAdapter mockAdapter;
    late AcPrinting acPrinting;

    setUp(() {
      mockAdapter = MockPrintingAdapter();
      AcPrintingPlatform.setInstance(mockAdapter);
      acPrinting = AcPrinting();
    });

    test('getPrinters returns success and printer list from platform', () async {
      final result = await acPrinting.getPrinters();
      expect(result.isSuccess(), isTrue);
      expect(result.value, isA<List<AcPrinter>>());

      final printers = result.value as List<AcPrinter>;
      expect(printers.length, equals(2));
      expect(printers.first.name, equals('Mock Laser Printer'));
      expect(printers.first.isDefault, isTrue);
      expect(printers[1].name, equals('Mock Label Printer'));
    });

    test('printPdf routes to active/specified printer through platform', () async {
      final testBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final result = await acPrinting.printPdf(
        pdfBytes: testBytes,
        printerName: 'Mock Label Printer',
        jobName: 'Invoice #101',
      );

      expect(result.isSuccess(), isTrue);
      expect(mockAdapter.printPdfCalled, isTrue);
      expect(mockAdapter.lastPrinterName, equals('Mock Label Printer'));
      expect(mockAdapter.lastPdfBytes, equals(testBytes));
    });

    test('sharePdf routes through platform', () async {
      final testBytes = Uint8List.fromList([10, 20, 30]);
      final success = await acPrinting.sharePdf(
        bytes: testBytes,
        name: 'report.pdf',
      );

      expect(success, isTrue);
      expect(mockAdapter.sharePdfCalled, isTrue);
      expect(mockAdapter.lastPdfBytes, equals(testBytes));
    });

    test('printPdf synchronizes and passes pageFormat and settings', () async {
      final testBytes = Uint8List.fromList([1, 2, 3]);
      final format = AcPageFormat.instanceFromName(name: 'A5');
      final result = await acPrinting.printPdf(
        pdfBytes: testBytes,
        pageFormat: format,
      );

      expect(result.isSuccess(), isTrue);
      expect(mockAdapter.lastPageFormat, isNotNull);
      expect(mockAdapter.lastPageFormat!.width, equals(148.0));
      expect(mockAdapter.lastPageFormat!.height, equals(210.0));
      expect(mockAdapter.lastSettings, isNotNull);
      expect(mockAdapter.lastSettings!.pageFormat.width, equals(148.0));
    });
  });

  group('AcPrinting Native Platform Discovery Test', () {
    test('Queries native OS printers on current machine without error', () async {
      // Restore native platform adapter (e.g. Windows on this system)
      AcPrintingPlatform.resetToDefault();

      final nativePrinting = AcPrinting();
      final result = await nativePrinting.getPrinters();

      expect(result.isSuccess(), isTrue);
      expect(result.value, isA<List<AcPrinter>>());
      final printers = result.value as List<AcPrinter>;
      print('Detected native OS printers count: ${printers.length}');
      expect(printers.isNotEmpty, isTrue);
    });
  });
}
