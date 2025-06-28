import 'package:autocode/autocode.dart';

/* AcDoc({
  "description": "Contains metadata about a deprecated element such as version, reason, and planned removal details.",
  "type": "development",
  "author": "AcDocs System"
}) */
class AcDeprecation {
  static const String keyMessage = "message";
  static const String keySince = "since";
  static const String keyPlannedRemoval = "planned_removal";
  static const String keyRemovalDate = "removal_date";
  static const String keyReplacement = "replacement";
  static const String keyReason = "reason";
  static const String keyStatus = "status";

  /* AcDoc({
    "description": "Short message about the deprecation.",
    "type": "development"
  }) */
  String? message;

  /* AcDoc({
    "description": "Version since when the element is deprecated.",
    "type": "development"
  }) */
  String? since;

  /* AcDoc({
    "description": "Planned version or milestone when the deprecated item will be removed.",
    "type": "development"
  }) */
  @AcBindJsonProperty(key: AcDeprecation.keyPlannedRemoval)
  String? plannedRemoval;

  /* AcDoc({
    "description": "Planned calendar date for removal of the deprecated element.",
    "type": "development"
  }) */
  @AcBindJsonProperty(key: AcDeprecation.keyRemovalDate)
  String? removalDate;

  /* AcDoc({
    "description": "Suggested replacement for the deprecated element, if any.",
    "type": "development"
  }) */
  String? replacement;

  /* AcDoc({
    "description": "Why this element is deprecated.",
    "type": "development"
  }) */
  String? reason;

  /* AcDoc({
    "description": "Current deprecation status (e.g., planned, active, obsolete).",
    "type": "development"
  }) */
  String? status;

  /* AcDoc({
    "description": "Creates an empty deprecation model.",
    "type": "development"
  }) */
  AcDeprecation();

  /* AcDoc({
    "description": "Creates and populates an instance of AcDeprecation from JSON.",
    "params": {
      "jsonData": "Map representing the deprecation metadata in snake_case."
    },
    "returns": {
      "type": "AcDeprecation",
      "description": "An instance with all fields populated."
    },
    "type": "development"
  }) */
  factory AcDeprecation.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcDeprecation();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  /* AcDoc({
    "description": "Populates this instance from a given JSON map.",
    "params": {
      "jsonData": "JSON data to load values from."
    },
    "returns": {
      "type": "AcDeprecation",
      "description": "This instance after assignment."
    },
    "type": "development"
  }) */
  AcDeprecation fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  /* AcDoc({
    "description": "Converts this instance into a JSON-compatible map.",
    "returns": {
      "type": "Map<String, dynamic>",
      "description": "Map of deprecation properties in snake_case."
    },
    "type": "development"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({
    "description": "String representation of the instance using pretty-printed JSON.",
    "returns": {
      "type": "String",
      "description": "Human-readable JSON string of the current object."
    },
    "type": "development"
  }) */
  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
