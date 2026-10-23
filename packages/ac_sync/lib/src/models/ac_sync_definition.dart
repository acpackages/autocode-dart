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
    definitionName = AcJsonUtils.deserializeValue<String>(
      jsonData[keyDefinitionName] ?? jsonData['definition_name'],
      defaultValue: definitionName,
    )!;
    if (jsonData.containsKey(keyTableDefinitions) || jsonData.containsKey('table_definitions')) {
      tableDefinitions = AcJsonUtils.deserializeList<AcSyncTableDefinition>(
        jsonData[keyTableDefinitions] ?? jsonData['table_definitions'],
        fromJson: (json) => AcSyncTableDefinition.instanceFromJson(jsonData: json),
      );
    }
    return this;
  }

  Map<String, dynamic> toJson() {
    return {
      keyDefinitionName: definitionName,
      keyTableDefinitions: AcJsonUtils.serializeValue(tableDefinitions),
    };
  }

  @override
  String toString() {
    // Standardized to use AcJsonUtils for consistency with other classes.
    return AcJsonUtils.prettyEncode(toJson());
  }


}