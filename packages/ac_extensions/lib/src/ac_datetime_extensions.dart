// Removed 'dart:core' as it's always implicitly imported.
import 'package:intl/intl.dart';
import 'package:moment_dart/moment_dart.dart';

/* AcDoc({
  "type": "extension",
  "summary": "Adds convenience methods to the core DateTime class.",
  "description": "This extension enhances DateTime with helpful methods for parsing, formatting, manipulation, and comparison.",
  "since": "1.0.0",
  "author": "Gemini (Documenter)",
  "group": "Core Utilities",
  "category": "Date & Time",
  "tags": ["datetime", "extension", "helper"]
}) */
extension AcDateTimeExtensions on DateTime {
  /* AcDoc({
    "type": "method",
    "summary": "Parses a string into a DateTime object.",
    "description": "Converts a string representation of a date into a DateTime object. If a specific 'format' pattern is provided, it uses the 'intl' package. Otherwise, it uses 'moment_dart' for flexible parsing.",
    "remarks": ["This is an instance method but does not use the `this` instance it is called on. It functions like a static method."],
    "since": "1.0.0",
    "params": [
      { "name": "dateString", "description": "The string containing the date and time.", "type": "String" },
      { "name": "format", "description": "Optional parsing pattern (e.g., 'yyyy-MM-dd').", "type": "String", "default_value": "" }
    ],
    "returns": "A new DateTime instance parsed from the string.",
    "returns_type": "DateTime",
    "throws": [
      { "type": "FormatException", "description": "If the date string does not match the provided format or cannot be parsed." }
    ],
    "examples": [
      "DateTime.now().fromFormatted('2025-03-15', format: 'yyyy-MM-dd');"
    ],
    "tags": ["parse", "date", "string", "format"]
  }) */
  DateTime fromFormatted(String dateString, {String format = ""}) {
    if (format.isNotEmpty) {
      final DateFormat inputFormat = DateFormat(format);
      return inputFormat.parse(dateString);
    } else {
      return Moment.parse(dateString);
    }
  }

  /* AcDoc({
    "type": "method",
    "summary": "Adds the specified duration components to this DateTime.",
    "description": "Returns a new DateTime with the specified years, months, days, and other time units added. It uses a manual calculation for year and month additions and the Duration object for smaller units.",
    "since": "1.0.0",
    "params": [
      { "name": "years", "description": "Number of years to add.", "type": "int", "default_value": "0" },
      { "name": "months", "description": "Number of months to add.", "type": "int", "default_value": "0" },
      { "name": "days", "description": "Number of days to add.", "type": "int", "default_value": "0" },
      { "name": "hours", "description": "Number of hours to add.", "type": "int", "default_value": "0" },
      { "name": "minutes", "description": "Number of minutes to add.", "type": "int", "default_value": "0" },
      { "name": "seconds", "description": "Number of seconds to add.", "type": "int", "default_value": "0" },
      { "name": "microseconds", "description": "Number of microseconds to add.", "type": "int", "default_value": "0" }
    ],
    "returns": "A new DateTime instance representing the calculated future date.",
    "returns_type": "DateTime",
    "examples": ["final in_one_year_six_months = DateTime.now().addTime(years: 1, months: 6);"],
    "tags": ["add", "manipulate", "time", "date", "duration"]
  }) */
  DateTime addTime({
    int years = 0,
    int months = 0,
    int days = 0,
    int hours = 0,
    int minutes = 0,
    int seconds = 0,
    int microseconds = 0,
  }) {
    Moment dateTime = Moment(this);
    if (years != 0) {
      dateTime = Moment(DateTime(dateTime.year + years, dateTime.month,
          dateTime.day, dateTime.hour, dateTime.minute, dateTime.second,
          dateTime.millisecond, dateTime.microsecond));
    }
    if (months != 0) {
      int year = dateTime.year;
      int addMonths = (months / 12) as int;
      year += addMonths;
      months = months % 12;
      int month = dateTime.month + months;
      if (month > 12) {
        year++;
        month = month - 12;
      }
      dateTime = Moment(DateTime(year, month, dateTime.day, dateTime.hour,
          dateTime.minute, dateTime.second, dateTime.millisecond,
          dateTime.microsecond));
    }
    if (days != 0) {
      dateTime = dateTime.add(Duration(days: days));
    }
    if (hours != 0) {
      dateTime = dateTime.add(Duration(hours: hours));
    }
    if (minutes != 0) {
      dateTime = dateTime.add(Duration(minutes: minutes));
    }
    if (seconds != 0) {
      dateTime = dateTime.add(Duration(seconds: seconds));
    }
    if (microseconds != 0) {
      dateTime = dateTime.add(Duration(microseconds: microseconds));
    }
    return dateTime;
  }

  /* AcDoc({
    "type": "method",
    "summary": "Formats this DateTime into a string based on a pattern.",
    "description": "Uses the 'moment_dart' formatting syntax to convert the DateTime object into a human-readable string.",
    "since": "1.0.0",
    "params": [
      { "name": "format", "description": "The formatting pattern (e.g., 'YYYY-MM-DD HH:mm').", "type": "String" }
    ],
    "returns": "The formatted date string.",
    "returns_type": "String",
    "examples": ["DateTime.now().format('dddd, MMMM Do YYYY');"],
    "links": ["https://moment-dart.gitbook.io/moment-dart/features/format"],
    "tags": ["format", "string", "display", "pattern"]
  }) */
  String format(String format) {
    Moment moment = Moment(this);
    return moment.format(format);
  }

  /* AcDoc({
    "type": "method",
    "summary": "Checks if this DateTime is identical to another.",
    "description": "Performs a microsecond-precise comparison against another DateTime using the 'moment_dart' `compareTo` method.",
    "since": "1.0.0",
    "params": [
      { "name": "other", "description": "The DateTime to compare against.", "type": "DateTime" }
    ],
    "returns": "A boolean value: `true` if the two DateTime objects are exactly equal, `false` otherwise.",
    "returns_type": "bool",
    "examples": ["final now = DateTime.now(); final alsoNow = DateTime.parse(now.toIso8601String()); now.isSame(alsoNow); // true"],
    "tags": ["compare", "equal", "same", "moment"]
  }) */
  bool isSame(DateTime other) {
    Moment current = Moment(this);
    return current.compareTo(other) == 0;
  }

  /* AcDoc({
    "type": "method",
    "summary": "Subtracts the specified duration components from this DateTime.",
    "description": "Returns a new DateTime with the specified years, months, days, and other time units subtracted. It uses a manual calculation for year and month subtractions and the Duration object for smaller units.",
    "since": "1.0.0",
    "params": [
      { "name": "years", "description": "Number of years to subtract.", "type": "int", "default_value": "0" },
      { "name": "months", "description": "Number of months to subtract.", "type": "int", "default_value": "0" },
      { "name": "days", "description": "Number of days to subtract.", "type": "int", "default_value": "0" },
      { "name": "hours", "description": "Number of hours to subtract.", "type": "int", "default_value": "0" },
      { "name": "minutes", "description": "Number of minutes to subtract.", "type": "int", "default_value": "0" },
      { "name": "seconds", "description": "Number of seconds to subtract.", "type": "int", "default_value": "0" },
      { "name": "microseconds", "description": "Number of microseconds to subtract.", "type": "int", "default_value": "0" }
    ],
    "returns": "A new DateTime instance representing the calculated past date.",
    "returns_type": "DateTime",
    "examples": ["final six_months_ago = DateTime.now().subtractTime(months: 6);"],
    "tags": ["subtract", "manipulate", "time", "date", "duration"]
  }) */
  DateTime subtractTime({
    int years = 0,
    int months = 0,
    int days = 0,
    int hours = 0,
    int minutes = 0,
    int seconds = 0,
    int microseconds = 0,
  }) {
    Moment dateTime = Moment(this);
    if (years != 0) {
      dateTime = Moment(DateTime(dateTime.year - years, dateTime.month,
          dateTime.day, dateTime.hour, dateTime.minute, dateTime.second,
          dateTime.millisecond, dateTime.microsecond));
    }
    if (months != 0) {
      int year = dateTime.year;
      int addMonths = (months / 12) as int;
      year -= addMonths;
      months = months % 12;
      int month = dateTime.month - months;
      if (month < 1) {
        year--;
        month = month + 12;
      }
      dateTime = Moment(DateTime(year, month, dateTime.day, dateTime.hour,
          dateTime.minute, dateTime.second, dateTime.millisecond,
          dateTime.microsecond));
    }
    if (days != 0) {
      dateTime = dateTime.subtract(Duration(days: days));
    }
    if (hours != 0) {
      dateTime = dateTime.subtract(Duration(hours: hours));
    }
    if (minutes != 0) {
      dateTime = dateTime.subtract(Duration(minutes: minutes));
    }
    if (seconds != 0) {
      dateTime = dateTime.subtract(Duration(seconds: seconds));
    }
    if (microseconds != 0) {
      dateTime = dateTime.subtract(Duration(microseconds: microseconds));
    }
    return dateTime;
  }
}