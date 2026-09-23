import 'ac_printing_platform_interface.dart';
import 'adapters/ac_web_printing.dart';

AcPrintingPlatformAdapter getPlatformAdapter() => AcWebPrinting();
