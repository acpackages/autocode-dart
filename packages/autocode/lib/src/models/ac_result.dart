import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

/* AcDoc({
  "description": "Represents a standardized result model for operations, including status, messages, exceptions, and optional metadata.",
  "author": "Sanket Patel"
}) */
@AcReflectable()
class AcResult {
  /* AcDoc({ "description": "Code indicating nothing was executed." }) */
  static const int codeNothingExecuted = 0;

  /* AcDoc({ "description": "Code indicating success." }) */
  static const int codeSuccess = 1;

  /* AcDoc({ "description": "Code indicating failure." }) */
  static const int codeFailure = -1;

  /* AcDoc({ "description": "Code indicating an exception occurred." }) */
  static const int codeException = -2;

  static const String keyCode = 'code';
  static const String keyException = 'exception';
  static const String keyLog = 'log';
  static const String keyMessage = 'message';
  static const String keyOtherDetails = 'other_details';
  static const String keyPreviousResult = 'previous_result';
  static const String keyStackTrace = 'stack_trace';
  static const String keyStatus = 'status';
  static const String keyValue = 'value';

  AcLogger? logger;

  /* AcDoc({ "description": "Result code representing status of operation." }) */
  int code = codeNothingExecuted;

  /* AcDoc({ "description": "Captured exception object if any." }) */
  dynamic exception;

  /* AcDoc({ "description": "Log entries associated with the result." }) */
  List<dynamic> log = [];

  /* AcDoc({ "description": "Message describing the result." }) */
  String message = 'Nothing executed';

  /* AcDoc({ "description": "Additional metadata or debug information." }) */
  @AcBindJsonProperty(key: keyOtherDetails)
  List<dynamic> otherDetails = [];

  /* AcDoc({ "description": "Stack trace if an exception was thrown." }) */
  @AcBindJsonProperty(key: keyStackTrace)
  dynamic stackTrace;

  /* AcDoc({ "description": "Status of the result: 'success' or 'failure'." }) */
  String status = 'failure';

  /* AcDoc({ "description": "Value associated with a successful result." }) */
  dynamic value;

  AcResult();

  /* AcDoc({ "description": "Factory to create an AcResult from JSON." }) */
  factory AcResult.instanceFromJson({required Map<String, dynamic> jsonData}) {
    var instance = AcResult();
    return instance.fromJson(jsonData: jsonData);
  }

  /* AcDoc({ "description": "Populates this instance from JSON." }) */
  AcResult fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  /* AcDoc({ "description": "Returns true if result represents an exception." }) */
  bool isException() => status == 'failure' && code == codeException;

  /* AcDoc({ "description": "Returns true if result represents a failure." }) */
  bool isFailure() => status == 'failure';

  /* AcDoc({ "description": "Returns true if result represents success." }) */
  bool isSuccess() => status == 'success';

  /* AcDoc({ "description": "Appends another result's log to this one." }) */
  AcResult appendResultLog({required AcResult result}) {
    log.addAll(result.log);
    return this;
  }

  /* AcDoc({ "description": "Prepends another result's log to this one." }) */
  AcResult prependResultLog({required AcResult result}) {
    log.insertAll(0, result.log);
    return this;
  }

  /* AcDoc({ "description": "Copies relevant properties from another result." }) */
  AcResult setFromResult({required AcResult result, String? message, AcLogger? logger}) {
    status = result.status;
    this.message = result.message;
    code = result.code;

    if (isException()) {
      exception = result.exception;
      this.message = result.message;
    } else if (isSuccess()) {
      value = result.value;
    }

    return this;
  }

  /* AcDoc({ "description": "Sets this result as success with optional value and message." }) */
  AcResult setSuccess({dynamic value, String? message, AcLogger? logger}) {
    status = 'success';
    code = codeSuccess;

    if (value != null) this.value = value;
    if (message != null) {
      this.message = message;
      logger?.success(this.message);
      this.logger?.success(this.message);
    }

    return this;
  }

  /* AcDoc({ "description": "Sets this result as failure with optional value and message." }) */
  AcResult setFailure({dynamic value, String? message, AcLogger? logger}) {
    status = 'failure';
    code = codeFailure;

    if (message != null) {
      this.message = message;
      logger?.error(this.message);
      this.logger?.error(this.message);
    }

    return this;
  }

  /* AcDoc({ "description": "Sets this result as an exception with optional stack trace and message." }) */
  AcResult setException({
    required dynamic exception,
    String? message,
    AcLogger? logger,
    bool logException = false,
    StackTrace? stackTrace,
  }) {
    code = codeException;
    this.exception = exception;
    this.stackTrace = stackTrace ?? '';
    this.message = (message ?? exception?.toString())!;

    if (logException) {
      logger?.error([exception?.toString(), this.stackTrace]);
      this.logger?.error([exception?.toString(), this.stackTrace]);
    }

    return this;
  }

  /* AcDoc({ "description": "Converts this result into a JSON-compatible map." }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({ "description": "Returns a formatted JSON string of this result." }) */
  @override
  String toString() => AcJsonUtils.prettyEncode(toJson());
}
