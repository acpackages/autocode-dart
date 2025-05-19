import 'package:autocode/autocode.dart';

class AcCronJob {
  static const String KEY_CALLBACK = "callback";
  static const String KEY_DURATION = "duration";
  static const String KEY_EXECUTION = "execution";
  static const String KEY_ID = "id";
  static const String KEY_LAST_EXECUTION_TIME = "last_execution_time";

  late String id;
  late String execution;
  late Map<String, int> duration;

  @AcBindJsonProperty(key: AcCronJob.KEY_CALLBACK, skipInToJson: true)
  dynamic callback;

  @AcBindJsonProperty(key: AcCronJob.KEY_LAST_EXECUTION_TIME)
  DateTime? lastExecutionTime;

  AcCronJob(this.id, this.execution, this.duration, this.callback);
}
