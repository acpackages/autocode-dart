import 'package:ac_mirrors/ac_mirrors.dart';
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

  @override
  AcWebviewOnWebInterceptorResult fromJson({Map<String, dynamic> jsonData = const {}}) {
    super.fromJson(jsonData: jsonData);
    continueOperation = AcJsonUtils.deserializeValue<bool>(
      jsonData[keyContinueOperation] ?? jsonData['continue_operation'],
      defaultValue: continueOperation,
    );
    if (jsonData.containsKey(keyWebResponse) || jsonData.containsKey('web_response')) {
      final wr = jsonData[keyWebResponse] ?? jsonData['web_response'];
      if (wr is Map<String, dynamic>) {
        webResponse = wr;
      } else if (wr is Map) {
        webResponse = wr.cast<String, dynamic>();
      }
    }
    return this;
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = super.toJson();
    if (continueOperation != null) {
      result[keyContinueOperation] = continueOperation;
    }
    if (webResponse != null) {
      result[keyWebResponse] = AcJsonUtils.serializeValue(webResponse);
    }
    return result;
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
