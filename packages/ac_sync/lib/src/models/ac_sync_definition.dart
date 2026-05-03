import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

@AcReflectable()
class AcSyncDefinition {
  static const String keyDefinitionName = 'definitionName';
  static const String keyExcludeTables = 'excludeTables';
  static const String keyIncludeTables = 'includeTables';

  String definitionName = "";
  List<String> excludeTables = List.empty(growable: true);
  List<String> includeTables = List.empty(growable: true);

  AcSyncDefinition({
    this.definitionName = "",
    this.excludeTables = const [],
    this.includeTables = const [],
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