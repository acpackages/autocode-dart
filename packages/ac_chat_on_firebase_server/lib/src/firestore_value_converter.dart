/// Converts plain Dart values to Firestore REST API typed-value maps and back.
///
/// Firestore REST API represents every field value as a typed object, e.g.:
///   `{ "stringValue": "hello" }`
///   `{ "timestampValue": "2024-01-01T00:00:00Z" }`
/// This utility handles the encoding so callers can work with plain Dart maps.
class FirestoreValueConverter {
  FirestoreValueConverter._();

  /// Converts a plain Dart [value] to a Firestore REST typed-value map.
  static Map<String, dynamic> encode(dynamic value) {
    if (value == null) {
      return {'nullValue': null};
    } else if (value is bool) {
      return {'booleanValue': value};
    } else if (value is int) {
      return {'integerValue': value.toString()};
    } else if (value is double) {
      return {'doubleValue': value};
    } else if (value is String) {
      return {'stringValue': value};
    } else if (value is DateTime) {
      return {'timestampValue': value.toUtc().toIso8601String()};
    } else if (value is List) {
      return {
        'arrayValue': {
          'values': value.map(encode).toList(),
        },
      };
    } else if (value is Map) {
      return {
        'mapValue': {
          'fields': _encodeFields(Map<String, dynamic>.from(value)),
        },
      };
    }
    // Fallback: treat as string
    return {'stringValue': value.toString()};
  }

  /// Encodes a plain Dart [map] to Firestore REST `fields` format.
  static Map<String, dynamic> encodeFields(Map<String, dynamic> map) =>
      _encodeFields(map);

  static Map<String, dynamic> _encodeFields(Map<String, dynamic> map) {
    return {for (final e in map.entries) e.key: encode(e.value)};
  }

  /// Decodes a Firestore REST `fields` map back to a plain Dart map.
  static Map<String, dynamic> decodeFields(Map<String, dynamic> fields) {
    return {for (final e in fields.entries) e.key: _decode(e.value)};
  }

  static dynamic _decode(dynamic value) {
    if (value is! Map) return value;
    final map = Map<String, dynamic>.from(value);
    if (map.containsKey('nullValue')) return null;
    if (map.containsKey('booleanValue')) return map['booleanValue'] as bool;
    if (map.containsKey('integerValue')) {
      return int.parse(map['integerValue'].toString());
    }
    if (map.containsKey('doubleValue')) return (map['doubleValue'] as num).toDouble();
    if (map.containsKey('stringValue')) return map['stringValue'] as String;
    if (map.containsKey('timestampValue')) {
      return DateTime.parse(map['timestampValue'] as String);
    }
    if (map.containsKey('arrayValue')) {
      final arr = map['arrayValue'] as Map?;
      final values = arr?['values'] as List? ?? [];
      return values.map(_decode).toList();
    }
    if (map.containsKey('mapValue')) {
      final mv = map['mapValue'] as Map?;
      final fields = mv?['fields'] as Map? ?? {};
      return decodeFields(Map<String, dynamic>.from(fields));
    }
    return value;
  }
}