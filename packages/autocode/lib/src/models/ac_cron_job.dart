import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
/* AcDoc({
"author": "Sanket Patel",
"summary": "Represents a single scheduled cron job.",
"description": "A model class that holds all metadata for a scheduled task, including its unique ID, execution schedule (e.g., 'every' or 'daily_at'), duration parameters, the callback function to execute, and tracking for its last execution time.",
"example": "final job = AcCronJob('job123', 'every', {'seconds': 30}, () => print('Task running!'));"
}) */

@AcReflectable()
class AcCronJob {
  /* AcDoc({"description": "Key for the callback function during serialization."}) */
  static const String keyCallback = "callback";

  /* AcDoc({"description": "Key for the duration settings during serialization."}) */
  static const String keyDuration = "duration";

  /* AcDoc({"description": "Key for the execution type during serialization."}) */
  static const String keyExecution = "execution";

  /* AcDoc({"description": "Key for the unique job ID during serialization."}) */
  static const String keyId = "id";

  /* AcDoc({"description": "Key for the last execution time during serialization."}) */
  static const String keyLastExecutionTime = "lastExecutionTime";

  /* AcDoc({
"summary": "Unique identifier for the cron job."
}) */
  late String id;

  /* AcDoc({
"summary": "Execution type, e.g., 'every' or 'daily_at'."
}) */
  late String execution;

  /* AcDoc({
"summary": "Map specifying the schedule interval (e.g., {'days': 1})."
}) */
  late Map<String, int> duration;

  /* AcDoc({
"summary": "The function to be executed by the cron job.",
"description": "This field holds the actual code to be run. It is marked to be skipped during JSON serialization to avoid trying to serialize a function."
}) */
  @AcBindJsonProperty(key: AcCronJob.keyCallback, skipInToJson: true)
  Function callback;

  /* AcDoc({
"summary": "The last time the cron job was executed.",
"description": "This is used by the cron scheduler to determine when the job should run next. It is updated automatically after each execution."
}) */
  @AcBindJsonProperty(key: AcCronJob.keyLastExecutionTime)
  DateTime? lastExecutionTime;

  /* AcDoc({
"summary": "Creates a new instance of a cron job.",
"params": [
{"name": "id", "description": "The unique identifier for the job."},
{"name": "execution", "description": "The execution mode ('every' or 'daily_at')."},
{"name": "duration", "description": "A map of time units for the schedule."},
{"name": "callback", "description": "The function to execute when the job runs."}
]
}) */
  AcCronJob(this.id, this.execution, this.duration, this.callback);
}
