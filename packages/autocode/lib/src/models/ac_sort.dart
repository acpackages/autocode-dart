import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import '../enums/ac_enum_sort_order.dart';

@AcReflectable()
class AcSort {
  static const String keyKey = "key";
  static const String keyOrder = "order";

  String key = '';
  AcEnumSortOrder order = AcEnumSortOrder.none;

  AcSort();

  factory AcSort.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcSort();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  factory AcSort.instanceWithValues({
    required String key,
    required AcEnumSortOrder order,
  }) {
    return AcSort()
      ..key = key
      ..order = order;
  }

  AcSort clone() {
    return AcSort.instanceFromJson(jsonData: toJson());
  }

  AcSort fromJson({Map<String, dynamic> jsonData = const {}}) {
    key = AcJsonUtils.deserializeValue<String>(
      jsonData[keyKey] ?? jsonData['key'],
      defaultValue: key,
    )!;
    order = AcJsonUtils.deserializeValue<AcEnumSortOrder>(
      jsonData[keyOrder] ?? jsonData['order'],
      enumValues: AcEnumSortOrder.values,
      defaultValue: order,
    )!;
    return this;
  }

  Map<String, dynamic> toJson() {
    return {
      keyKey: key,
      keyOrder: AcJsonUtils.serializeValue(order),
    };
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}