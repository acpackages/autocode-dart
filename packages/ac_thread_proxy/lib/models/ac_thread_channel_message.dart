import 'package:ac_mirrors/annotations.dart';
import 'package:autocode/autocode.dart';

@AcReflectable()
class AcThreadChannelMessage {
  String key = "";
  int id = -1;
  dynamic data = null;
  bool isResponse = false;
  dynamic response = null;
  bool isError = false;
  dynamic error = null;
  String? stackTrace;

  AcThreadChannelMessage({
    this.key = "",
    this.id = -1,
    this.data,
    this.isResponse = false,
    this.response,
    this.isError = false,
    this.error,
    this.stackTrace,
  });

  factory AcThreadChannelMessage.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcThreadChannelMessage();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  AcThreadChannelMessage fromJson({required Map<String, dynamic> jsonData}) {
    Map<String, dynamic> json = Map.from(jsonData);
    if (json.containsKey('key')) {
      key = json['key']?.toString() ?? "";
    }
    if (json.containsKey('id')) {
      id = json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? -1;
    }
    if (json.containsKey('data')) {
      data = json['data'];
    }
    if (json.containsKey('is_response')) {
      isResponse = json['is_response'] == true;
    }
    if (json.containsKey('response')) {
      response = json['response'];
    }
    if (json.containsKey('is_error')) {
      isError = json['is_error'] == true;
    }
    if (json.containsKey('error')) {
      error = json['error'];
    }
    if (json.containsKey('stack_trace')) {
      stackTrace = json['stack_trace']?.toString();
    }
    return this;
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'id': id,
      'data': data,
      'is_response': isResponse,
      'response': response,
      'is_error': isError,
      'error': error,
      'stack_trace': stackTrace,
    };
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}