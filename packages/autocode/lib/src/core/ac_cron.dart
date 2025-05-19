import 'dart:async';

import 'package:autocode/autocode.dart';
import 'package:intl/intl.dart';

class AcCron {
  static late AcLogger _logger;
  static final Map<String, AcCronJob> _cronJobs = {};
  static Timer? _interval;

  static void init() {
    _logger = AcLogger();
  }

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
              "Executing cron job with id ${job.id} (every). Last execution time is ${last ?? 'never'}");
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
              "Executing cron job with id ${job.id} (daily_at). Last execution time is ${lastExecutionTime ?? 'never'}");
          callback();
          job.lastExecutionTime = now;
        }
      }
    }
  }

  static int _getDurationInSeconds(
      {int days = 0, int hours = 0, int minutes = 0, int seconds = 0}) {
    return (days * 86400) + (hours * 3600) + (minutes * 60) + seconds;
  }

  static String _formatTime(int h, int m, int s) =>
      '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

  static void start() {
    _logger.log("Cron jobs execution started at ${DateTime.now()}");
    _interval = Timer.periodic(Duration(seconds: 1), (_) => _executeCronJobs());
  }

  static void stop() {
    if (_interval != null) {
      _logger.log("Cron jobs execution stopped at ${DateTime.now()}");
      _interval?.cancel();
      _interval = null;
    }
  }
}
