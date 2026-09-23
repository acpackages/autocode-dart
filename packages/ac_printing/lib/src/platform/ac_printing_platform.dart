import 'ac_printing_platform_interface.dart';
import 'ac_printing_platform_stub.dart'
    if (dart.library.io) 'ac_printing_platform_io.dart'
    if (dart.library.js_interop) 'ac_printing_platform_web.dart';

class AcPrintingPlatform {
  static AcPrintingPlatformAdapter? _instance;

  static AcPrintingPlatformAdapter get instance {
    _instance ??= getPlatformAdapter();
    return _instance!;
  }

  static void setInstance(AcPrintingPlatformAdapter adapter) {
    _instance = adapter;
  }

  static void resetToDefault() {
    _instance = getPlatformAdapter();
  }
}
