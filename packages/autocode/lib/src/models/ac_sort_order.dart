import 'package:ac_mirrors/annotations.dart';
import '../../autocode.dart';
import '../enums/ac_enum_sort_order.dart';

@AcReflectable()
class AcSortOrder {
  static const String keySortOrders = "sortOrders";

  @AcBindJsonProperty(skipInFromJson: true, skipInToJson: true)
  final AcEvents events = AcEvents();

  List<AcSort> sortOrders = [];

  AcSortOrder();

  factory AcSortOrder.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcSortOrder();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  AcSortOrder addSort({
    required String key,
    required AcEnumSortOrder order,
    bool removeIfExist = true,
  }) {
    if (removeIfExist) {
      sortOrders.removeWhere((item) => item.key == key);
    }
    if (order != AcEnumSortOrder.none) {
      sortOrders.add(AcSort.instanceWithValues(key: key, order: order));
    }
    events.execute(key: 'change', args: [{'key': key, 'order': order, 'removeIfExist': removeIfExist}]);
    return this;
  }

  AcSortOrder removeSort({required String key}) {
    sortOrders.removeWhere((item) => item.key == key);
    events.execute(key: 'change', args: [{'key': key}]);
    return this;
  }

  AcSortOrder clone() {
    return AcSortOrder.instanceFromJson(jsonData: toJson());
  }

  AcSortOrder fromJson({required Map<String, dynamic> jsonData}) {
    final Map<String, dynamic> json = Map.from(jsonData);

    if (json.containsKey(keySortOrders)) {
      final rawList = json[keySortOrders] as List;
      sortOrders = rawList
          .whereType<Map<String, dynamic>>()
          .map((e) => AcSort.instanceFromJson(jsonData: e))
          .toList();
      json.remove(keySortOrders);
    }

    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: json,
    );
    return this;
  }

  String on({required String event, required Function callback}) {
    return events.subscribe(event: event, callback: callback);
  }

  void off({String? event, Function? callback, String? subscriptionId}) {
    // events.unsubscribe(key: event, callback: callback, subscriptionId: subscriptionId);
  }

  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}