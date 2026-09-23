import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;
import '../../models/ac_page_format.dart';
import '../../models/ac_print_settings.dart';
import '../../models/ac_printer.dart';
import '../ac_printing_platform_interface.dart';

class AcWebPrinting implements AcPrintingPlatformAdapter {
  @override
  Future<List<AcPrinter>> getPrinters() async {
    return [
      AcPrinter()
        ..name = 'System Print Dialog'
        ..isDefault = true
        ..isAvailable = true
        ..comment = 'Browser native print preview',
    ];
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
      final jsArray = pdfBytes.toJS;
      final blobParts = [jsArray].toJS;
      final options = web.BlobPropertyBag(type: 'application/pdf');
      final blob = web.Blob(blobParts, options);
      final url = web.URL.createObjectURL(blob);

      final iframe = web.document.createElement('iframe') as web.HTMLIFrameElement;
      iframe.style.position = 'fixed';
      iframe.style.right = '100%';
      iframe.style.bottom = '100%';
      iframe.style.width = '0px';
      iframe.style.height = '0px';
      iframe.style.border = 'none';
      iframe.src = url;

      final completer = Completer<bool>();

      final effectiveFormat = pageFormat ?? settings?.pageFormat;
      final widthMm = (effectiveFormat != null && effectiveFormat.width > 0) ? effectiveFormat.width : 210.0;
      final heightMm = (effectiveFormat != null && effectiveFormat.height > 0) ? effectiveFormat.height : 297.0;
      final isPortrait = effectiveFormat?.isPortrait ?? true;

      iframe.addEventListener(
        'load',
        (web.Event _) {
          try {
            try {
              final styleEl = web.document.createElement('style') as web.HTMLStyleElement;
              styleEl.textContent =
                  '@page { size: ${widthMm}mm ${heightMm}mm ${isPortrait ? 'portrait' : 'landscape'}; margin: 0; }';
              iframe.contentDocument?.head?.appendChild(styleEl);
            } catch (_) {}

            iframe.contentWindow?.focus();
            iframe.contentWindow?.print();
            if (!completer.isCompleted) {
              completer.complete(true);
            }
          } catch (_) {
            if (!completer.isCompleted) {
              completer.complete(false);
            }
          } finally {
            Future.delayed(const Duration(seconds: 60), () {
              iframe.remove();
              web.URL.revokeObjectURL(url);
            });
          }
        }.toJS,
      );

      web.document.body?.appendChild(iframe);
      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () => true,
      );
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
      final jsArray = bytes.toJS;
      final blobParts = [jsArray].toJS;
      final options = web.BlobPropertyBag(type: 'application/pdf');
      final blob = web.Blob(blobParts, options);
      final url = web.URL.createObjectURL(blob);

      final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
      anchor.href = url;
      anchor.download = name;
      web.document.body?.appendChild(anchor);
      anchor.click();
      anchor.remove();

      Future.delayed(const Duration(seconds: 10), () {
        web.URL.revokeObjectURL(url);
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  bool get isDirectPrintSupported => false;
}
