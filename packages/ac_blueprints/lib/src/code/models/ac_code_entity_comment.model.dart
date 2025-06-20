import 'package:ac_blueprints/ac_blueprints.dart';
import 'package:autocode/autocode.dart';

class AcCodeEntityComment extends AcCodeEntityBase {
  static const String KEY_TEXT = "text";
  static const String KEY_IS_DOC = "is_doc";

  @AcBindJsonProperty(key: KEY_TEXT)
  String text = "";

  @AcBindJsonProperty(key: KEY_IS_DOC)
  bool isDoc = false;

  AcCodeEntityComment();

  factory AcCodeEntityComment.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcCodeEntityComment();
    instance.fromJson(jsonData:jsonData);
    return instance;
  }

  AcCodeEntityComment fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData:jsonData);
    return this;
  }
}
