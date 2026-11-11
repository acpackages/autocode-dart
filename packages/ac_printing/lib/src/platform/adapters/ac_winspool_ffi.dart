// ignore_for_file: camel_case_types, non_constant_identifier_names
import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import '../../models/ac_printer.dart';

final class DocInfo1W extends Struct {
  external Pointer<Utf16> pDocName;
  external Pointer<Utf16> pOutputFile;
  external Pointer<Utf16> pDatatype;
}

final class PRINTER_INFO_2W extends Struct {
  external Pointer<Utf16> pServerName;
  external Pointer<Utf16> pPrinterName;
  external Pointer<Utf16> pShareName;
  external Pointer<Utf16> pPortName;
  external Pointer<Utf16> pDriverName;
  external Pointer<Utf16> pComment;
  external Pointer<Utf16> pLocation;
  external Pointer<Void> pDevMode;
  external Pointer<Utf16> pSepFile;
  external Pointer<Utf16> pPrintProcessor;
  external Pointer<Utf16> pDatatype;
  external Pointer<Utf16> pParameters;
  external Pointer<Void> pSecurityDescriptor;
  @Uint32()
  external int Attributes;
  @Uint32()
  external int Priority;
  @Uint32()
  external int DefaultPriority;
  @Uint32()
  external int StartTime;
  @Uint32()
  external int UntilTime;
  @Uint32()
  external int Status;
  @Uint32()
  external int cJobs;
  @Uint32()
  external int AveragePPM;
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

typedef EnumPrintersWNative = Int32 Function(
  Uint32 Flags,
  Pointer<Utf16> Name,
  Uint32 Level,
  Pointer<Uint8> pPrinterEnum,
  Uint32 cbBuf,
  Pointer<Uint32> pcbNeeded,
  Pointer<Uint32> pcReturned,
);
typedef EnumPrintersWDart = int Function(
  int Flags,
  Pointer<Utf16> Name,
  int Level,
  Pointer<Uint8> pPrinterEnum,
  int cbBuf,
  Pointer<Uint32> pcbNeeded,
  Pointer<Uint32> pcReturned,
);

typedef GetDefaultPrinterWNative = Int32 Function(
  Pointer<Utf16> pszBuffer,
  Pointer<Uint32> pcchBuffer,
);
typedef GetDefaultPrinterWDart = int Function(
  Pointer<Utf16> pszBuffer,
  Pointer<Uint32> pcchBuffer,
);

typedef ShellExecuteWNative = IntPtr Function(
  IntPtr hwnd,
  Pointer<Utf16> lpOperation,
  Pointer<Utf16> lpFile,
  Pointer<Utf16> lpParameters,
  Pointer<Utf16> lpDirectory,
  Int32 nShowCmd,
);
typedef ShellExecuteWDart = int Function(
  int hwnd,
  Pointer<Utf16> lpOperation,
  Pointer<Utf16> lpFile,
  Pointer<Utf16> lpParameters,
  Pointer<Utf16> lpDirectory,
  int nShowCmd,
);

class AcWinSpool {
  static DynamicLibrary? _winspool;
  static DynamicLibrary? _shell32;
  static bool _initialized = false;

  static OpenPrinterWDart? _openPrinter;
  static StartDocPrinterWDart? _startDocPrinter;
  static StartPagePrinterDart? _startPagePrinter;
  static WritePrinterDart? _writePrinter;
  static EndPagePrinterDart? _endPagePrinter;
  static EndDocPrinterDart? _endDocPrinter;
  static ClosePrinterDart? _closePrinter;
  static EnumPrintersWDart? _enumPrinters;
  static GetDefaultPrinterWDart? _getDefaultPrinter;
  static ShellExecuteWDart? _shellExecute;

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
      _enumPrinters = _winspool!.lookupFunction<EnumPrintersWNative, EnumPrintersWDart>('EnumPrintersW');
      _getDefaultPrinter = _winspool!.lookupFunction<GetDefaultPrinterWNative, GetDefaultPrinterWDart>('GetDefaultPrinterW');
    } catch (_) {}

    try {
      _shell32 = DynamicLibrary.open('shell32.dll');
      _shellExecute = _shell32!.lookupFunction<ShellExecuteWNative, ShellExecuteWDart>('ShellExecuteW');
    } catch (_) {}
  }

  /// Retrieves the default printer name on Windows in < 0.1 ms using native Win32 FFI.
  static String? getDefaultPrinterName() {
    _init();
    if (_getDefaultPrinter == null) return null;

    final pcch = calloc<Uint32>();
    try {
      _getDefaultPrinter!(nullptr, pcch);
      if (pcch.value <= 0) return null;

      final buf = calloc<Uint16>(pcch.value);
      try {
        final res = _getDefaultPrinter!(buf.cast<Utf16>(), pcch);
        if (res != 0) {
          return buf.cast<Utf16>().toDartString();
        }
      } finally {
        calloc.free(buf);
      }
    } catch (_) {
      return null;
    } finally {
      calloc.free(pcch);
    }
    return null;
  }

  /// Enumerates all local and network printers in ~1 to 2 ms using native Win32 FFI (Level 2).
  static List<AcPrinter> getPrinters() {
    _init();
    if (_enumPrinters == null) return <AcPrinter>[];

    final defaultPrinter = getDefaultPrinterName() ?? '';
    final printers = <AcPrinter>[];

    final pcbNeeded = calloc<Uint32>();
    final pcReturned = calloc<Uint32>();

    try {
      // PRINTER_ENUM_LOCAL (2) | PRINTER_ENUM_CONNECTIONS (4) = 6
      const flags = 6;
      _enumPrinters!(flags, nullptr, 2, nullptr, 0, pcbNeeded, pcReturned);

      final cbBuf = pcbNeeded.value;
      if (cbBuf <= 0) return printers;

      final pBuffer = calloc<Uint8>(cbBuf);
      try {
        final res = _enumPrinters!(flags, nullptr, 2, pBuffer, cbBuf, pcbNeeded, pcReturned);
        final count = pcReturned.value;

        if (res != 0 && count > 0) {
          final infoPtr = pBuffer.cast<PRINTER_INFO_2W>();
          for (int i = 0; i < count; i++) {
            final info = (infoPtr + i).ref;
            final name = info.pPrinterName != nullptr ? info.pPrinterName.toDartString() : '';
            if (name.isEmpty) continue;

            final driver = info.pDriverName != nullptr ? info.pDriverName.toDartString() : '';
            final port = info.pPortName != nullptr ? info.pPortName.toDartString() : '';
            final comment = info.pComment != nullptr ? info.pComment.toDartString() : '';
            final location = info.pLocation != nullptr ? info.pLocation.toDartString() : '';

            // PRINTER_ATTRIBUTE_DEFAULT = 0x00000004
            final isDefault = (info.Attributes & 0x00000004) != 0 ||
                (defaultPrinter.isNotEmpty && name.toLowerCase() == defaultPrinter.toLowerCase());

            // Status == 0 means printer is idle / ready without error
            final isAvailable = info.Status == 0 || (info.Status & 0x00000002) == 0; // Not paused

            final printer = AcPrinter()
              ..name = name
              ..driverName = driver
              ..url = port
              ..comment = comment
              ..location = location
              ..isDefault = isDefault
              ..isAvailable = isAvailable;

            printers.add(printer);
          }
        }
      } finally {
        calloc.free(pBuffer);
      }
    } catch (_) {
      return printers;
    } finally {
      calloc.free(pcbNeeded);
      calloc.free(pcReturned);
    }

    return printers;
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

  /// Dispatches a print job directly via Win32 ShellExecuteW in < 1 ms without spawning PowerShell.
  static bool shellExecutePrint({
    required String filePath,
    String? printerName,
  }) {
    _init();
    if (_shellExecute == null) return false;

    final filePtr = filePath.toNativeUtf16();
    final operation = (printerName != null && printerName.isNotEmpty) ? 'printto' : 'print';
    final opPtr = operation.toNativeUtf16();
    final paramPtr = (printerName != null && printerName.isNotEmpty)
        ? '"$printerName"'.toNativeUtf16()
        : nullptr;

    try {
      // nShowCmd = 0 (SW_HIDE)
      final res = _shellExecute!(0, opPtr, filePtr, paramPtr, nullptr, 0);
      // HINSTANCE > 32 indicates success
      return res > 32;
    } catch (_) {
      return false;
    } finally {
      calloc.free(filePtr);
      calloc.free(opPtr);
      if (paramPtr != nullptr) calloc.free(paramPtr);
    }
  }
}
