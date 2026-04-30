import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:ac_web/ac_web.dart';
import 'package:autocode/autocode.dart';

@AcReflectable()
class AcWebviewOnWebInterceptorResult extends AcResult {
  static const String keyContinueOperation = 'continueOperation';
  static const String keyWebResponse = 'webResponse';

  @AcBindJsonProperty(key: keyContinueOperation)
  bool? continueOperation;

  Map<String, dynamic>? webResponse;

  AcWebviewOnWebInterceptorResult({
    bool? continueOperation,
    Map<String, dynamic>? webResponse,
  }) {
    if (continueOperation != null) {
      this.continueOperation = continueOperation;
    }
    if (webResponse != null) {
      this.webResponse = webResponse;
    }
  }

  factory AcWebviewOnWebInterceptorResult.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    var instance = AcWebviewOnWebInterceptorResult();
    return instance.fromJson(jsonData: jsonData);
  }

  AcWebviewOnWebInterceptorResult fromJson({Map<String, dynamic> jsonData = const {}}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
    return this;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = AcJsonUtils.getJsonDataFromInstance(
      instance: this,
    );
    return result;
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
