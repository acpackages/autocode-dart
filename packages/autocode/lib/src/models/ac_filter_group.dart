import 'package:ac_extensions/ac_extensions.dart';
import 'package:ac_mirrors/annotations.dart';
import '../../autocode.dart';

/// Represents a group of filters and/or nested filter groups joined by AND/OR
@AcReflectable()
class AcFilterGroup {
  static const String keyFilters = "filters";
  static const String keyFilterGroups = "filterGroups";
  static const String keyOperator = "operator";

  @AcBindJsonProperty(skipInFromJson: true, skipInToJson: true)
  final AcEvents events = AcEvents();

  List<AcFilter> filters = [];
  List<AcFilterGroup> filterGroups = [];
  AcEnumLogicalOperator operator = AcEnumLogicalOperator.and;

  AcFilterGroup();

  factory AcFilterGroup.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcFilterGroup();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  factory AcFilterGroup.instanceWithValues({
    required AcEnumLogicalOperator operator,
    required List<AcFilter> filters,
  }) {
    return AcFilterGroup()
      ..operator = operator
      ..filters = filters;
  }

  AcFilterGroup addFilter({
    required String key,
    required AcEnumConditionOperator operator,
    required dynamic value,
  }) {
    final filter = AcFilter.instanceWithValues(
      key: key,
      operator: operator,
      value: value,
    );
    return addFilterModel(filter: filter);
  }

  AcFilterGroup addFilterModel({required AcFilter filter}) {
    filters.add(filter);
    events.execute(key: 'change', args: [{'filter': filter}]);
    return this;
  }

  AcFilterGroup addFilterGroupModel({required AcFilterGroup filterGroup}) {
    filterGroups.add(filterGroup);
    events.execute(key: 'change', args: [{'filterGroup': filterGroup}]);
    return this;
  }

  AcFilterGroup clear() {
    filters.clear();
    filterGroups.clear();
    events.execute(key: 'change', args: [{}]);
    return this;
  }

  AcFilterGroup clone() {
    return AcFilterGroup.instanceFromJson(jsonData: toJson());
  }

  AcFilterGroup fromJson({required Map<String, dynamic> jsonData}) {
    if (jsonData.containsKey(keyFilters) || jsonData.containsKey('filters')) {
      filters = AcJsonUtils.deserializeList<AcFilter>(
        jsonData[keyFilters] ?? jsonData['filters'],
        fromJson: (json) => AcFilter.instanceFromJson(jsonData: json),
      );
    }

    if (jsonData.containsKey(keyFilterGroups) || jsonData.containsKey('filterGroups') || jsonData.containsKey('filter_groups')) {
      filterGroups = AcJsonUtils.deserializeList<AcFilterGroup>(
        jsonData[keyFilterGroups] ?? jsonData['filterGroups'] ?? jsonData['filter_groups'],
        fromJson: (json) => AcFilterGroup.instanceFromJson(jsonData: json),
      );
    }

    operator = AcJsonUtils.deserializeValue<AcEnumLogicalOperator>(
      jsonData[keyOperator] ?? jsonData['operator'],
      enumValues: AcEnumLogicalOperator.values,
      defaultValue: operator,
    )!;
    return this;
  }

  bool hasFilters() => filters.isNotEmpty || filterGroups.any((g) => g.hasFilters());

  AcFilterGroup setFilter({
    required String key,
    required AcEnumConditionOperator operator,
    required dynamic value,
  }) {
    final existing = filters.cast<AcFilter?>().firstWhere(
          (f) => f?.key == key,
      orElse: () => null,
    );

    if (existing != null) {
      existing
        ..operator = operator
        ..value = value;
      events.execute(key: 'change', args: [{'key': key, 'operator': operator, 'value': value}]);
    } else {
      addFilter(key: key, operator: operator, value: value);
    }
    return this;
  }

  String on({required String event, required Function callback}) {
    return events.subscribe(event: event, callback: callback);
  }

  void off({String? event, Function? callback, String? subscriptionId}) {
    // events.unsubscribe(key: event, callback: callback, subscriptionId: subscriptionId);
  }

  Map<String, dynamic> toJson() {
    return {
      keyFilters: AcJsonUtils.serializeValue(filters),
      keyFilterGroups: AcJsonUtils.serializeValue(filterGroups),
      keyOperator: AcJsonUtils.serializeValue(operator),
    };
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}