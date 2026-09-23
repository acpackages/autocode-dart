import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../../models/ac_page_format.dart';
import '../../models/ac_print_settings.dart';
import '../../models/ac_printer.dart';
import '../ac_printing_platform_interface.dart';

AcPrintingPlatformAdapter? getFlutterMobileAdapter() => AcFlutterMobilePrinting();

class AcFlutterMobilePrinting implements AcPrintingPlatformAdapter {
  static const MethodChannel _channel = MethodChannel('plugins.autocode.run/ac_printing');

  @override
  Future<List<AcPrinter>> getPrinters() async {
    try {
      final List<dynamic>? result = await _channel.invokeListMethod('getPrinters');
      if (result == null) return <AcPrinter>[];

      return result.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return AcPrinter()
          ..name = map['name']?.toString() ?? ''
          ..url = map['url']?.toString() ?? ''
          ..location = map['location']?.toString() ?? ''
          ..comment = map['comment']?.toString() ?? ''
          ..isDefault = map['isDefault'] == true
          ..isAvailable = map['isAvailable'] != false;
      }).toList();
    } catch (_) {
      return <AcPrinter>[];
    }
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
    try {
      final targetPrinter = printerName ?? printer?.name;
      final printerUrl = printer?.url;
      final effectiveFormat = pageFormat ?? settings?.pageFormat;
      final widthMm = (effectiveFormat != null && effectiveFormat.width > 0) ? effectiveFormat.width : 210.0;
      final heightMm = (effectiveFormat != null && effectiveFormat.height > 0) ? effectiveFormat.height : 297.0;
      final isPortrait = effectiveFormat?.isPortrait ?? (settings?.orientation.toLowerCase() != 'landscape');

      final result = await _channel.invokeMethod<bool>('printPdf', {
        'bytes': pdfBytes,
        'jobName': jobName,
        'printerName': targetPrinter,
        'printerUrl': printerUrl,
        'copies': settings?.copies ?? 1,
        'duplex': settings?.duplex ?? false,
        'orientation': isPortrait ? 'portrait' : 'landscape',
        'widthMm': widthMm,
        'heightMm': heightMm,
        'isPortrait': isPortrait,
        'paperName': effectiveFormat != null ? _resolvePaperName(effectiveFormat) : 'A4',
        'marginLeftMm': effectiveFormat?.marginLeft ?? 0.0,
        'marginRightMm': effectiveFormat?.marginRight ?? 0.0,
        'marginTopMm': effectiveFormat?.marginTop ?? 0.0,
        'marginBottomMm': effectiveFormat?.marginBottom ?? 0.0,
      });
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> sharePdf({
    required Uint8List bytes,
    String name = 'document.pdf',
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('sharePdf', {
        'bytes': bytes,
        'name': name,
      });
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  String _resolvePaperName(AcPageFormat format) {
    if ((format.width - 210).abs() <= 2 && (format.height - 297).abs() <= 2) return 'A4';
    if ((format.width - 216).abs() <= 2 && (format.height - 279).abs() <= 2) return 'LETTER';
    if ((format.width - 216).abs() <= 2 && (format.height - 356).abs() <= 2) return 'LEGAL';
    if ((format.width - 297).abs() <= 2 && (format.height - 420).abs() <= 2) return 'A3';
    if ((format.width - 148).abs() <= 2 && (format.height - 210).abs() <= 2) return 'A5';
    if ((format.width - 105).abs() <= 2 && (format.height - 148).abs() <= 2) return 'A6';
    if ((format.width - 190).abs() <= 2 && (format.height - 254).abs() <= 2) return 'EXECUTIVE';
    return 'CUSTOM';
  }

  @override
  bool get isDirectPrintSupported => true;
}
