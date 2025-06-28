import 'package:autocode/autocode.dart';

/* AcDoc({
  "description": "Represents licensing metadata for a documented item.",
  "type": "development",
  "author": "AcDocs System"
}) */
class AcLicense {
  static const String keyName = "name";
  static const String keyIdentifier = "identifier";

  /* AcDoc({"description": "Full name of the license, e.g., 'MIT License'."}) */
  late String name;

  @AcBindJsonProperty(key: AcLicense.keyIdentifier)
  /* AcDoc({"description": "Short identifier of the license, e.g., 'MIT', 'GPL-3.0'."}) */
  String? identifier;

  /* AcDoc({"description": "URL to the full license text or documentation."}) */
  String? url;

  /* AcDoc({"description": "Path to a local license file if applicable."}) */
  String? file;

  /* AcDoc({"description": "Whether the license is compatible with SPDX standards."}) */
  bool? spdxCompatible;

  /* AcDoc({"description": "Whether this license is approved for use in production."}) */
  bool? approvedForUse;

  /* AcDoc({"description": "Description of allowed or required modifications under this license."}) */
  String? modifications;

  /* AcDoc({"description": "Scope or limitation of this license, e.g., 'project', 'module'."}) */
  String? scope;

  /* AcDoc({"description": "Legal jurisdiction or region where this license is applicable."}) */
  String? jurisdiction;

  /* AcDoc({"description": "Constructs a new AcLicense instance."}) */
  AcLicense();

  /* AcDoc({"description": "Creates an instance of AcLicense from JSON data."}) */
  factory AcLicense.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcLicense();
    instance.fromJson(jsonData:jsonData);
    return instance;
  }

  /* AcDoc({"description": "Populates this instance from a JSON map."}) */
  AcLicense fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  /* AcDoc({"description": "Converts this instance into a JSON map."}) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({"description": "Returns a pretty-printed JSON string of the license object."}) */
  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
