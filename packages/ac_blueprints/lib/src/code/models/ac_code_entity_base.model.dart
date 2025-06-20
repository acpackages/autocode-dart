import 'package:autocode/autocode.dart';

class AcCodeEntityBase {
  static const String KEY_NAME = "name";
  static const String KEY_FILE_PATH = "file_path";
  static const String KEY_LINE_NUMBER = "line_number";
  static const String KEY_COLUMN_NUMBER = "column_number";

  @AcBindJsonProperty(key: KEY_NAME)
  String name = "";

  @AcBindJsonProperty(key: KEY_FILE_PATH)
  String filePath = "";

  @AcBindJsonProperty(key: KEY_LINE_NUMBER)
  int lineNumber = 0;

  @AcBindJsonProperty(key: KEY_COLUMN_NUMBER)
  int columnNumber = 0;

  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
