import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
@AcReflectable()
class AcDDView {
  static const String KEY_VIEW_NAME = "view_name";
  static const String KEY_VIEW_COLUMNS = "view_columns";
  static const String KEY_VIEW_QUERY = "view_query";

  @AcBindJsonProperty(key: AcDDView.KEY_VIEW_NAME)
  String viewName = "";

  @AcBindJsonProperty(key: AcDDView.KEY_VIEW_QUERY)
  String viewQuery = "";

  @AcBindJsonProperty(key: AcDDView.KEY_VIEW_COLUMNS)
  Map<String, AcDDViewColumn> viewColumns = {};

  static AcDDView instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcDDView();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  static AcDDView getInstance(
    String viewName, {
    String dataDictionaryName = "default",
  }) {
    final result = AcDDView();
    final acDataDictionary = AcDataDictionary.getInstance(
      dataDictionaryName: dataDictionaryName,
    );

    if (acDataDictionary.views.containsKey(viewName)) {
      result.fromJson(jsonData: acDataDictionary.views[viewName]);
    }

    return result;
  }

  AcDDView fromJson({required Map<String, dynamic> jsonData}) {
    Map<String,dynamic> json = Map.from(jsonData);
    if (json.containsKey(KEY_VIEW_COLUMNS) &&
        json[KEY_VIEW_COLUMNS] is Map) {
      final columns = jsonData[KEY_VIEW_COLUMNS] as Map;
      columns.forEach((columnName, columnData) {
        viewColumns[columnName] = AcDDViewColumn.instanceFromJson(
          jsonData: columnData,
        );
      });
      json.remove(KEY_VIEW_COLUMNS);
    }
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: json,
    );
    return this;
  }

  static String getDropViewStatement({required String viewName, String databaseType = AcEnumSqlDatabaseType.UNKNOWN}) {
    return 'DROP VIEW IF EXISTS $viewName;';
  }

  String getCreateViewStatement({String databaseType = AcEnumSqlDatabaseType.UNKNOWN}) {
    return 'CREATE VIEW $viewName AS $viewQuery;';
  }

  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
