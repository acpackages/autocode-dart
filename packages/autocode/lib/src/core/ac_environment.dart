/* AcDoc({
  "description": "Manages the current runtime environment and configuration settings.",
  "author": "Sanket Patel",
  "type": "utility"
}) */
import 'package:autocode/autocode.dart';

class AcEnvironment {
  /* AcDoc({
    "description": "Defines the current application environment. Default is 'local'."
  }) */
  static AcEnumEnvironment environment = AcEnumEnvironment.local;

  /* AcDoc({
    "description": "Stores configuration values for the current environment."
  }) */
  static Map<String, dynamic> config = {};

  /* AcDoc({
    "description": "Checks if the environment is 'development'.",
    "returns": "True if environment is development, false otherwise."
  }) */
  static bool isDevelopment() => environment == AcEnumEnvironment.development;

  /* AcDoc({
    "description": "Checks if the environment is 'local'.",
    "returns": "True if environment is local, false otherwise."
  }) */
  static bool isLocal() => environment == AcEnumEnvironment.local;

  /* AcDoc({
    "description": "Checks if the environment is 'production'.",
    "returns": "True if environment is production, false otherwise."
  }) */
  static bool isProduction() => environment == AcEnumEnvironment.production;

  /* AcDoc({
    "description": "Checks if the environment is 'staging'.",
    "returns": "True if environment is staging, false otherwise."
  }) */
  static bool isStaging() => environment == AcEnumEnvironment.staging;
}
