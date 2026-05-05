import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'ac_sync_table_definition.dart';

@AcReflectable()
class AcSyncDefinition {
  static const String keyDefinitionName = 'definitionName';
  static const String keyTableDefinitions = 'tableDefinitions';

  String definitionName = "";
  List<AcSyncTableDefinition> tableDefinitions = List.empty(growable: true);

  AcSyncDefinition({
    this.definitionName = "",
    this.tableDefinitions = const [],
  });

  factory AcSyncDefinition.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    var instance = AcSyncDefinition();
    return instance.fromJson(jsonData: jsonData);
  }

  AcSyncDefinition fromJson({Map<String, dynamic> jsonData = const {}}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
    if (jsonData.containsKey(keyTableDefinitions)) {
      var list = jsonData[keyTableDefinitions] as List<dynamic>;
      tableDefinitions = list.map((item) => AcSyncTableDefinition.instanceFromJson(jsonData: item)).toList();
    }
    return this;
  }

  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  @override
  String toString() {
    // Standardized to use AcJsonUtils for consistency with other classes.
    return AcJsonUtils.prettyEncode(toJson());
  }


}