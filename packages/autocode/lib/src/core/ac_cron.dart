import 'dart:async';
import 'package:autocode/autocode.dart';
import 'package:intl/intl.dart';
/* AcDoc({
  "description": "A lightweight cron scheduler to run periodic and time-specific tasks.",
  "author": "Sanket Patel",
  "type": "utility"
}) */
class AcCron {
  /* AcDoc({"description": "Logger instance used for internal logging."}) */
  static late AcLogger _logger;

  /* AcDoc({"description": "Registry of all active cron jobs keyed by their unique IDs."}) */
  static final Map<String, AcCronJob> _cronJobs = {};

  /* AcDoc({"description": "Periodic timer used to execute registered cron jobs."}) */
  static Timer? _interval;

  /* AcDoc({"description": "Initializes the cron scheduler by setting up the logger."}) */
  static void init() {
    _logger = AcLogger();
  }

  /* AcDoc({
    "description": "Schedules a recurring cron job to run every specified interval.",
    "params": [
      {"name": "callbackFunction", "description": "The function to execute."},
      {"name": "days", "description": "Interval in days."},
      {"name": "hours", "description": "Interval in hours."},
      {"name": "minutes", "description": "Interval in minutes."},
      {"name": "seconds", "description": "Interval in seconds."}
    ],
    "returns": "A unique job ID as a string."
  }) */
  static String every({required Function callbackFunction,int days = 0, int hours = 0, int minutes = 0, int seconds = 0}) {
    final id = Autocode.uniqueId();
    final job = AcCronJob(id, 'every', {
      'days': days,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
    }, callbackFunction);
    _cronJobs[id] = job;
    _logger.log(
        "Registered cron job with id $id for every $days days, $hours hours, $minutes minutes, $seconds seconds");
    return id;
  }

  /* AcDoc({
    "description": "Schedules a cron job to run daily at the specified time.",
    "params": [
      {"name": "callbackFunction", "description": "The function to execute."},
      {"name": "hours", "description": "Target hour (0-23)."},
      {"name": "minutes", "description": "Target minute (0-59)."},
      {"name": "seconds", "description": "Target second (0-59)."}
    ],
    "returns": "A unique job ID as a string."
  }) */
  static String dailyAt({required Function callbackFunction,int hours = 0, int minutes = 0, int seconds = 0}) {
    final id = Autocode.uniqueId();
    final job = AcCronJob(id, 'daily_at', {
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
    }, callbackFunction);
    _cronJobs[id] = job;
    _logger.log(
        "Registered cron job with id $id to execute daily at $hours:$minutes:$seconds");
    return id;
  }

  /* AcDoc({"description": "Checks and executes eligible cron jobs according to their schedule."}) */
  static void _executeCronJobs() {
    final now = DateTime.now();
    for (final job in _cronJobs.values) {
      final executionMode = job.execution;
      final duration = job.duration;
      final callback = job.callback;
      final lastExecutionTime = job.lastExecutionTime;

      if (executionMode == 'every') {
        final interval = _getDurationInSeconds(
          days: duration['days'] ?? 0,
          hours: duration['hours'] ?? 0,
          minutes: duration['minutes'] ?? 0,
          seconds: duration['seconds'] ?? 0,
        );
        final last = lastExecutionTime;
        if (last == null || now.difference(last).inSeconds >= interval) {
          _logger.log(
              "Executing cron job with id \${job.id} (every). Last execution time is \${last ?? 'never'}");
          callback();
          job.lastExecutionTime = now;
        }
      } else if (executionMode == 'daily_at') {
        final targetTime = DateFormat('HH:mm:ss').format(now);
        final expectedTime = _formatTime(
          duration['hours'] ?? 0,
          duration['minutes'] ?? 0,
          duration['seconds'] ?? 0,
        );
        if (targetTime == expectedTime) {
          _logger.log(
              "Executing cron job with id \${job.id} (daily_at). Last execution time is \${lastExecutionTime ?? 'never'}");
          callback();
          job.lastExecutionTime = now;
        }
      }
    }
  }

  /* AcDoc({
    "description": "Converts the provided time interval into seconds.",
    "params": [
      {"name": "days", "description": "Number of days."},
      {"name": "hours", "description": "Number of hours."},
      {"name": "minutes", "description": "Number of minutes."},
      {"name": "seconds", "description": "Number of seconds."}
    ],
    "returns": "Total duration in seconds."
  }) */
  static int _getDurationInSeconds(
      {int days = 0, int hours = 0, int minutes = 0, int seconds = 0}) {
    return (days * 86400) + (hours * 3600) + (minutes * 60) + seconds;
  }

  /* AcDoc({
    "description": "Formats a time from hours, minutes, and seconds into HH:mm:ss format.",
    "params": [
      {"name": "h", "description": "Hour."},
      {"name": "m", "description": "Minute."},
      {"name": "s", "description": "Second."}
    ],
    "returns": "Formatted time string."
  }) */
  static String _formatTime(int h, int m, int s) =>
      '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

  /* AcDoc({"description": "Starts the periodic execution of all registered cron jobs."}) */
  static void start() {
    _logger.log("Cron jobs execution started at \${DateTime.now()}");
    _interval = Timer.periodic(Duration(seconds: 1), (_) => _executeCronJobs());
  }

  /* AcDoc({"description": "Stops the execution of cron jobs and clears the timer."}) */
  static void stop() {
    if (_interval != null) {
      _logger.log("Cron jobs execution stopped at \${DateTime.now()}");
      _interval?.cancel();
      _interval = null;
    }
  }
}
