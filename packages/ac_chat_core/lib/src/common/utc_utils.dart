/// Canonical UTC parsing and formatting utilities for the ac_chat ecosystem.
///
/// Ensures all in-memory timestamps have [DateTime.isUtc] == true and all wire
/// representations end in 'Z'.
library ac_chat_utc_utils;

/// Parses any dynamic timestamp representation into a guaranteed UTC [DateTime].
///
/// Supported input types:
/// - [int]: epoch milliseconds (parsed with `isUtc: true`)
/// - [String]: ISO-8601 string (parsed and converted to UTC)
/// - [DateTime]: converted to UTC
/// - Dynamic objects with `toDate()` (such as Cloud Firestore `Timestamp`)
/// - Null / invalid: returns current UTC time [DateTime.now().toUtc()]
DateTime parseUtc(dynamic value) {
  if (value == null) {
    return DateTime.now().toUtc();
  }

  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
  }

  if (value is DateTime) {
    return value.isUtc ? value : value.toUtc();
  }

  if (value is String) {
    if (value.trim().isEmpty) return DateTime.now().toUtc();
    try {
      final parsed = DateTime.parse(value);
      return parsed.isUtc ? parsed : parsed.toUtc();
    } catch (_) {
      final asInt = int.tryParse(value);
      if (asInt != null) {
        return DateTime.fromMillisecondsSinceEpoch(asInt, isUtc: true);
      }
      return DateTime.now().toUtc();
    }
  }

  // Handle Firestore Timestamp or similar types via duck-typing `toDate()`
  try {
    final dynamic dynamicVal = value;
    final dynamic dateResult = dynamicVal.toDate();
    if (dateResult is DateTime) {
      return dateResult.isUtc ? dateResult : dateResult.toUtc();
    }
  } catch (_) {}

  return DateTime.now().toUtc();
}

/// Formats a [DateTime] into a strict UTC ISO-8601 wire string ending in 'Z'.
String formatUtcIso(DateTime dateTime) {
  final utc = dateTime.isUtc ? dateTime : dateTime.toUtc();
  final iso = utc.toIso8601String();
  if (iso.endsWith('Z')) return iso;
  if (iso.contains('+')) {
    return '${iso.split('+').first}Z';
  }
  return '${iso}Z';
}

/// Returns current timestamp in UTC.
DateTime nowUtc() => DateTime.now().toUtc();

/// Parses any dynamic timestamp into UTC [DateTime], returning `null` if input is null or empty.
DateTime? parseUtcOrNull(dynamic value) {
  if (value == null) return null;
  if (value is String && value.trim().isEmpty) return null;
  return parseUtc(value);
}
