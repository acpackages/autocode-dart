import 'package:autocode/autocode.dart';

/* AcDoc({
  "description": "Represents metadata about an exception or error that a method may throw.",
  "type": "development",
  "author": "AcDocs System"
}) */
class AcThrows {
  static const String keyType = "type";
  static const String keyDescription = "description";
  static const String keyDetails = "details";

  @AcBindJsonProperty(key: AcThrows.keyType)
  /* AcDoc({"description": "The type of exception thrown, e.g., 'IOException'."}) */
  late String type;

  /* AcDoc({"description": "Brief description of why this exception is thrown."}) */
  late String description;

  @AcBindJsonProperty(key: AcThrows.keyDetails)
  /* AcDoc({"description": "Optional detailed information or guidance on the exception."}) */
  String? details;

  /* AcDoc({"description": "Constructs a new AcThrows instance."}) */
  AcThrows();

  /* AcDoc({"description": "Creates an AcThrows instance from a JSON map."}) */
  factory AcThrows.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcThrows();
    instance.fromJson(jsonData:jsonData);
    return instance;
  }

  /* AcDoc({"description": "Populates this AcThrows instance from a JSON map."}) */
  AcThrows fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  /* AcDoc({"description": "Converts this AcThrows instance to a JSON map."}) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({"description": "Returns a pretty-printed JSON string of this throw metadata."}) */
  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
