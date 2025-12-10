import 'dart:convert';
import 'dart:math';

extension AcMapExtensions on Map<String, dynamic> {

  Map<K, V> castMap<K, V>() {
    return Map<K, V>.fromEntries(
      entries.map((e) => MapEntry(e.key as K, e.value as V)),
    );
  }

  Map<String, Map<String, dynamic>> changes(Map other) {
    final result = <String, Map<String, dynamic>>{};

    other.forEach((key, newValue) {
      if (!containsKey(key)) {
        result[key] = {'old': null, 'new': newValue, 'change': 'add'};
      } else if (this[key] != newValue) {
        result[key] = {'old': this[key], 'new': newValue, 'change': 'modify'};
      }
    });

    forEach((key, oldValue) {
      if (!other.containsKey(key)) {
        result[key] = {'old': oldValue, 'new': null, 'change': 'remove'};
      }
    });

    return result;
  }

  Map<String, dynamic> deepClone() =>
      jsonDecode(jsonEncode(this)) as Map<String, dynamic>;

  void copyFrom(Map source) => source.forEach((k, v) => this[k] = v);

  void copyTo(Map destination) => forEach((k, v) => destination[k] = v);

  Map<String, dynamic> filter(bool Function(dynamic key, dynamic value) test) {
    final result = <String, dynamic>{};
    forEach((k, v) {
      if (test(k, v)) result[k] = v;
    });
    return result;
  }

  dynamic get(dynamic key) => containsKey(key) ? this[key] : null;

  bool getBool(dynamic key) =>
      containsKey(key) && this[key] is bool ? this[key] as bool : false;

  double getDouble(dynamic key, {int round = 0}) {
    double value = 0;
    if (containsKey(key) && this[key] != null) {
      value = double.tryParse(this[key].toString()) ?? 0;
    }
    if (round > 0) {
      final mod = pow(10.0, round);
      value = ((value * mod).round().toDouble() / mod);
    }
    return value;
  }

  int getInt(dynamic key) {
    if (containsKey(key) && this[key] != null) {
      return int.tryParse(this[key].toString()) ?? 0;
    }
    return 0;
  }

  List<T> getList<T>(dynamic key, {bool growable = true}) {
    final raw = this[key];
    if (raw is List) {
      try {
        return raw.cast<T>();
      } catch (_) {
        return <T>[...raw]; // fallback: shallow copy
      }
    }
    return List.empty(growable: growable);
  }

  Map<K, V> getMap<K, V>(dynamic key) {
    final raw = this[key];
    if (raw is Map) {
      return raw.cast<K, V>();
    }
    return {};
  }

  String getString(dynamic key,{String defaultValue = ''}) =>
      containsKey(key) && this[key] != null ? this[key].toString() : defaultValue;

  Map<String, dynamic> merge(Map<String, dynamic> other) {
    other.forEach((k, v) => this[k] = v);
    return this;
  }

  bool isSame(Map other) => jsonEncode(this) == jsonEncode(other);

  void put(String key, dynamic value) => this[key] = value;

  Map<String, dynamic> toNestedMap({Function? valueExtractor}) {
    final Map<String, dynamic> result = {};

    for (final entry in entries) {
      final key = entry.key;
      final value = valueExtractor != null ? valueExtractor(entry.value) : entry
          .value;

      // Extract keys and indices: items[0][name] → [items, 0, name]
      final regex = RegExp(r'([^\[\]\.]+)|\[(.*?)\]');
      final matches = regex.allMatches(key);
      final parts = matches.map((m) => m.group(1) ?? m.group(2)!).toList();

      dynamic current = result;
      for (int i = 0; i < parts.length; i++) {
        final part = parts[i];
        final isLast = i == parts.length - 1;

        // Determine if current part is an array index
        final index = int.tryParse(part);

        if (index != null && current is List) {
          // Current is a list, and part is numeric index
          if (index >= current.length) {
            // Extend the list if needed
            current.addAll(List.filled(index - current.length + 1, null));
          }

          if (isLast) {
            current[index] = value;
          } else {
            // If next is not set or not a Map/List, create structure
            if (current[index] == null) {
              final nextPart = parts[i + 1];
              current[index] = int.tryParse(nextPart) != null
                  ? <dynamic>[]
                  : <String, dynamic>{};
            }
            current = current[index];
          }
        } else if (index == null && current is Map<String, dynamic>) {
          // Map key
          if (isLast) {
            current[part] = value;
          } else {
            final nextPart = parts[i + 1];
            final isNextIndex = int.tryParse(nextPart) != null;
            if (current[part] == null) {
              current[part] = isNextIndex
                  ? <dynamic>[]
                  : <String, dynamic>{};
            }
            current = current[part];
          }
        } else if (index != null && current is Map<String, dynamic>) {
          // Example: starting directly with a numeric key inside map (rare)
          current[index.toString()] = value;
        } else {
          throw StateError('Unexpected structure for key: $key');
        }
      }
    }

    return result;
  }

  String toQueryString() => Uri(queryParameters: this).query;

  List<T> toValuesList<T>() => values.map((e) => e as T).toList();
}
