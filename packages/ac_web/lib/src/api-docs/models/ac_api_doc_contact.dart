import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

/* AcDoc({
  "summary": "Represents the contact information for the exposed API.",
  "description": "This class models the Contact Object in an OpenAPI specification, providing human-readable contact details for the API support.",
  "example": "final contactInfo = AcApiDocContact()\n  ..name = 'API Support Team'\n  ..url = 'https://www.example.com/support'\n  ..email = 'support@example.com';"
}) */
@AcReflectable()
class AcApiDocContact {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyEmail = "email";
  static const String keyName = "name";
  static const String keyUrl = "url";

  /* AcDoc({"summary": "The email address of the contact person/organization."}) */
  @AcBindJsonProperty(key: keyEmail)
  String email = "";

  /* AcDoc({"summary": "The identifying name of the contact person/organization."}) */
  @AcBindJsonProperty(key: keyName)
  String name = "";

  /* AcDoc({"summary": "The URL pointing to the contact information."}) */
  @AcBindJsonProperty(key: keyUrl)
  String url = "";

  /* AcDoc({"summary": "Creates a new, empty instance of API contact information."}) */
  AcApiDocContact();

  /* AcDoc({
    "summary": "Creates a new AcApiDocContact instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the contact information."}
    ],
    "returns": "A new, populated AcApiDocContact instance.",
    "returns_type": "AcApiDocContact"
  }) */
  factory AcApiDocContact.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcApiDocContact();
    return instance.fromJson(jsonData: jsonData);
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "An instance method that uses reflection-based utilities to set the properties of this object from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the contact properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcApiDocContact"
  }) */
  AcApiDocContact fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current contact instance to a JSON map.",
    "returns": "A JSON map representation of the contact information.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the contact object.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    // Standardized to use AcJsonUtils for consistency.
    return AcJsonUtils.prettyEncode(toJson());
  }
}