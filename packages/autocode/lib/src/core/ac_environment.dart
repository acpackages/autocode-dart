import 'package:autocode/autocode.dart';

class AcEnvironment {
  static String environment = AcEnumEnvironment.LOCAL;
  static Map<String, dynamic> config = {};

  static bool isDevelopment() => environment == AcEnumEnvironment.DEVELOPMENT;

  static bool isLocal() => environment == AcEnumEnvironment.LOCAL;

  static bool isProduction() => environment == AcEnumEnvironment.PRODUCTION;

  static bool isStaging() => environment == AcEnumEnvironment.STAGING;
}
