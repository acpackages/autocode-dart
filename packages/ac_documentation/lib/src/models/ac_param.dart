import 'package:autocode/autocode.dart';

/* AcDoc({
  "description": "Represents metadata about a parameter used in functions or methods.",
  "type": "development",
  "author": "AcDocs System"
}) */
class AcParam {
  static const String keyName = "name";
  static const String keyDescription = "description";
  static const String keyType = "type";

  @AcBindJsonProperty(key: AcParam.keyName)
  /* AcDoc({"description": "The name of the parameter."}) */
  late String name;

  /* AcDoc({"description": "The description explaining the parameter's purpose."}) */
  late String description;

  @AcBindJsonProperty(key: AcParam.keyType)
  /* AcDoc({"description": "The type of the parameter, if available (e.g., 'String', 'int')."}) */
  String? type;

  /* AcDoc({"description": "Constructs a new AcParam instance."}) */
  AcParam();

  /* AcDoc({"description": "Creates an AcParam instance from a JSON map."}) */
  factory AcParam.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcParam();
    instance.fromJson(jsonData:jsonData);
    return instance;
  }

  /* AcDoc({"description": "Populates this AcParam instance from a JSON map."}) */
  AcParam fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  /* AcDoc({"description": "Converts this AcParam instance to a JSON map."}) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({"description": "Returns a pretty-printed JSON string of this parameter."}) */
  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
