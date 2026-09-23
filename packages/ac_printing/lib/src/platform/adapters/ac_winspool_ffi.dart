import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

final class DocInfo1W extends Struct {
  external Pointer<Utf16> pDocName;
  external Pointer<Utf16> pOutputFile;
  external Pointer<Utf16> pDatatype;
}

typedef OpenPrinterWNative = Int32 Function(
  Pointer<Utf16> pPrinterName,
  Pointer<IntPtr> phPrinter,
  Pointer<Void> pDefault,
);
typedef OpenPrinterWDart = int Function(
  Pointer<Utf16> pPrinterName,
  Pointer<IntPtr> phPrinter,
  Pointer<Void> pDefault,
);

typedef StartDocPrinterWNative = Uint32 Function(
  IntPtr hPrinter,
  Uint32 level,
  Pointer<DocInfo1W> pDocInfo,
);
typedef StartDocPrinterWDart = int Function(
  int hPrinter,
  int level,
  Pointer<DocInfo1W> pDocInfo,
);

typedef StartPagePrinterNative = Int32 Function(IntPtr hPrinter);
typedef StartPagePrinterDart = int Function(int hPrinter);

typedef WritePrinterNative = Int32 Function(
  IntPtr hPrinter,
  Pointer<Uint8> pBuf,
  Uint32 cbBuf,
  Pointer<Uint32> pcbWritten,
);
typedef WritePrinterDart = int Function(
  int hPrinter,
  Pointer<Uint8> pBuf,
  int cbBuf,
  Pointer<Uint32> pcbWritten,
);

typedef EndPagePrinterNative = Int32 Function(IntPtr hPrinter);
typedef EndPagePrinterDart = int Function(int hPrinter);

typedef EndDocPrinterNative = Int32 Function(IntPtr hPrinter);
typedef EndDocPrinterDart = int Function(int hPrinter);

typedef ClosePrinterNative = Int32 Function(IntPtr hPrinter);
typedef ClosePrinterDart = int Function(int hPrinter);

class AcWinSpool {
  static DynamicLibrary? _winspool;
  static bool _initialized = false;

  static OpenPrinterWDart? _openPrinter;
  static StartDocPrinterWDart? _startDocPrinter;
  static StartPagePrinterDart? _startPagePrinter;
  static WritePrinterDart? _writePrinter;
  static EndPagePrinterDart? _endPagePrinter;
  static EndDocPrinterDart? _endDocPrinter;
  static ClosePrinterDart? _closePrinter;

  static void _init() {
    if (_initialized) return;
    _initialized = true;
    try {
      _winspool = DynamicLibrary.open('winspool.drv');
      _openPrinter = _winspool!.lookupFunction<OpenPrinterWNative, OpenPrinterWDart>('OpenPrinterW');
      _startDocPrinter = _winspool!.lookupFunction<StartDocPrinterWNative, StartDocPrinterWDart>('StartDocPrinterW');
      _startPagePrinter = _winspool!.lookupFunction<StartPagePrinterNative, StartPagePrinterDart>('StartPagePrinter');
      _writePrinter = _winspool!.lookupFunction<WritePrinterNative, WritePrinterDart>('WritePrinter');
      _endPagePrinter = _winspool!.lookupFunction<EndPagePrinterNative, EndPagePrinterDart>('EndPagePrinter');
      _endDocPrinter = _winspool!.lookupFunction<EndDocPrinterNative, EndDocPrinterDart>('EndDocPrinter');
      _closePrinter = _winspool!.lookupFunction<ClosePrinterNative, ClosePrinterDart>('ClosePrinter');
    } catch (_) {}
  }

  /// Sends raw bytes (PDF / PostScript / ESC/POS) directly to Windows printer spooler.
  static bool printRawBytes({
    required String printerName,
    required Uint8List bytes,
    String docName = 'AcDocument',
    String dataType = 'RAW',
  }) {
    _init();
    if (_openPrinter == null) return false;

    final printerNamePtr = printerName.toNativeUtf16();
    final phPrinter = calloc<IntPtr>();

    try {
      final openRes = _openPrinter!(printerNamePtr, phPrinter, nullptr);
      if (openRes == 0) return false;
      final hPrinter = phPrinter.value;

      final docInfo = calloc<DocInfo1W>();
      final docNamePtr = docName.toNativeUtf16();
      final dataTypePtr = dataType.toNativeUtf16();

      docInfo.ref.pDocName = docNamePtr;
      docInfo.ref.pOutputFile = nullptr;
      docInfo.ref.pDatatype = dataTypePtr;

      try {
        final jobId = _startDocPrinter!(hPrinter, 1, docInfo);
        if (jobId == 0) {
          _closePrinter!(hPrinter);
          return false;
        }

        _startPagePrinter!(hPrinter);

        final buf = calloc<Uint8>(bytes.length);
        final bufList = buf.asTypedList(bytes.length);
        bufList.setAll(0, bytes);

        final pcbWritten = calloc<Uint32>();

        try {
          _writePrinter!(hPrinter, buf, bytes.length, pcbWritten);
          _endPagePrinter!(hPrinter);
          _endDocPrinter!(hPrinter);
        } finally {
          calloc.free(buf);
          calloc.free(pcbWritten);
        }

        _closePrinter!(hPrinter);
        return true;
      } finally {
        calloc.free(docNamePtr);
        calloc.free(dataTypePtr);
        calloc.free(docInfo);
      }
    } catch (_) {
      return false;
    } finally {
      calloc.free(printerNamePtr);
      calloc.free(phPrinter);
    }
  }
}
