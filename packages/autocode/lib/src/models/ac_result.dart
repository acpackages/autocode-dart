import 'package:autocode/autocode.dart';

class AcResult {
  static const int CODE_NOTHING_EXECUTED = 0;
  static const int CODE_SUCCESS = 1;
  static const int CODE_FAILURE = -1;
  static const int CODE_EXCEPTION = -2;

  static const String KEY_CODE = 'code';
  static const String KEY_EXCEPTION = 'exception';
  static const String KEY_LOG = 'log';
  static const String KEY_MESSAGE = 'message';
  static const String KEY_OTHER_DETAILS = 'other_details';
  static const String KEY_PREVIOUS_RESULT = 'previous_result';
  static const String KEY_STACK_TRACE = 'stack_trace';
  static const String KEY_STATUS = 'status';
  static const String KEY_VALUE = 'value';

  AcLogger? logger;
  int code = CODE_NOTHING_EXECUTED;
  dynamic exception;
  List<dynamic> log = [];
  String message = 'Nothing executed';

  @AcBindJsonProperty(key: AcResult.KEY_OTHER_DETAILS)
  List<dynamic> otherDetails = [];

  @AcBindJsonProperty(key: AcResult.KEY_STACK_TRACE)
  dynamic stackTrace;

  String status = 'failure';
  dynamic value;

  AcResult();

  factory AcResult.instanceFromJson({required Map<String, dynamic> jsonData}) {
    var instance = AcResult();
    return instance.fromJson(jsonData:jsonData);
  }

  AcResult fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this,jsonData: jsonData);
    return this;
  }

  bool isException() => status == 'failure' && code == CODE_EXCEPTION;
  bool isFailure() => status == 'failure';
  bool isSuccess() => status == 'success';

  AcResult appendResultLog({required AcResult result}) {
    log.addAll(result.log);
    return this;
  }

  AcResult prependResultLog({required AcResult result}) {
    log.insertAll(0, result.log);
    return this;
  }

  AcResult setFromResult({required AcResult result, String? message, AcLogger? logger}) {
    status = result.status;
    this.message = result.message;
    code = result.code;
    // No direct equivalent to PHP's dynamic property setting
    // You might consider explicitly modeling `previousResult`

    if (isException()) {
      exception = result.exception;
      this.message = result.message;
    } else if (isSuccess()) {
      value = result.value;
    }
    return this;
  }

  AcResult setSuccess({dynamic value, String? message, AcLogger? logger}) {
    status = 'success';
    code = CODE_SUCCESS;

    if (value != null) {
      this.value = value;
    }
    if (message != null) {
      this.message = message;
      logger?.success(this.message);
      this.logger?.success(this.message);
    }
    return this;
  }

  AcResult setFailure({dynamic value, String? message, AcLogger? logger}) {
    status = 'failure';
    code = CODE_FAILURE;

    if (message != null) {
      this.message = message;
      logger?.error(this.message);
      this.logger?.error(this.message);
    }
    return this;
  }

  AcResult setException({required dynamic exception,String? message,
        AcLogger? logger,
        bool logException = false,
        StackTrace? stackTrace}) {
    code = CODE_EXCEPTION;
    this.exception = exception;
    this.stackTrace = stackTrace ?? '';
    this.message = (message ?? exception?.toString())!;

    if (logException) {
      if (logger != null) logger.error([exception?.toString(), this.stackTrace]);
      this.logger?.error([exception?.toString(), this.stackTrace]);
    }

    return this;
  }

  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  @override
  String toString() => AcJsonUtils.prettyEncode(toJson());
}
