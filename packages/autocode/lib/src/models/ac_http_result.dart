import 'package:ac_mirrors/ac_mirrors.dart';
import '../../autocode.dart';

@AcReflectable()
class AcHttpResult extends AcResult {
  dynamic data;
  AcEnumHttpResponseCode responseCode = AcEnumHttpResponseCode.unknown;

  AcHttpResult();

  factory AcHttpResult.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcHttpResult();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  @override
  AcHttpResult fromJson({Map<String, dynamic> jsonData = const {}}) {
    super.fromJson(jsonData: jsonData);
    if (jsonData.containsKey('data')) {
      data = jsonData['data'];
    }
    responseCode = AcJsonUtils.deserializeValue<AcEnumHttpResponseCode>(
      jsonData['responseCode'] ?? jsonData['response_code'],
      enumValues: AcEnumHttpResponseCode.values,
      defaultValue: responseCode,
    )!;
    return this;
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map['data'] = AcJsonUtils.serializeValue(data);
    map['responseCode'] = AcJsonUtils.serializeValue(responseCode);
    return map;
  }
}