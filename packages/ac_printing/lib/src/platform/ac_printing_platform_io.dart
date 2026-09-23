import 'dart:io';
import 'ac_printing_platform_interface.dart';
import 'ac_printing_platform_stub.dart';
import 'adapters/ac_cups_printing.dart';
import 'adapters/ac_flutter_mobile_provider.dart';
import 'adapters/ac_windows_printing.dart';

AcPrintingPlatformAdapter getPlatformAdapter() {
  if (Platform.isAndroid || Platform.isIOS) {
    final flutterAdapter = getFlutterMobileAdapter();
    if (flutterAdapter != null) {
      return flutterAdapter;
    }
  }

  if (Platform.isWindows) {
    return AcWindowsPrinting();
  }

  if (Platform.isMacOS || Platform.isLinux) {
    return AcCupsPrinting();
  }

  return AcPrintingStubAdapter();
}
