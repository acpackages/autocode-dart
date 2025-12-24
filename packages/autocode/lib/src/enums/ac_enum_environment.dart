import 'package:ac_mirrors/ac_mirrors.dart';

/* AcDoc({
  "description": "Enumeration of environments used in application deployment and configuration contexts.",
  "author": "Sanket Patel",
  "type": "development"
}) */
@AcReflectable()
enum AcEnumEnvironment {
  /* AcDoc({"description": "Development environment used by engineers for building and testing."}) */
  development('DEVELOPMENT'),

  /* AcDoc({"description": "Local environment typically used for personal machines or isolated setups."}) */
  local('LOCAL'),

  /* AcDoc({"description": "Production environment for live deployment and real users."}) */
  production('PRODUCTION'),

  /* AcDoc({"description": "Staging environment for final testing before going live."}) */
  staging('STAGING'),

  unknown('UNKNOWN');

  /* AcDoc({"description": "The string representation of the environment."}) */
  final String value;

  /* AcDoc({"description": "Constructor that initializes the enum with its string representation."}) */
  const AcEnumEnvironment(this.value);

  /* AcDoc({
    "description": "Gets the enum constant matching the given string value.",
    "params": [{"name": "value", "description": "The string value representing the environment."}],
    "returns": "The corresponding AcEnumEnvironment or null if no match found."
  }) */
  static AcEnumEnvironment? fromValue(String value) {
    try {
      return AcEnumEnvironment.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }

  /* AcDoc({
    "description": "Checks if the environment's string value matches the given string.",
    "params": [{"name": "other", "description": "The string to compare."}],
    "returns": "true if equal; otherwise false."
  }) */
  bool equals(String other) => value == other;

  /* AcDoc({
    "description": "Returns the string representation of the environment.",
    "returns": "The string value."}) */
  @override
  String toString() => value;

  dynamic toJson() {
    return value;
  }

}
