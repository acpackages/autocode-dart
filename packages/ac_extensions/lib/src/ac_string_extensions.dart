import 'dart:convert';
import 'dart:math';

extension AcStringExtensions on String {
  List<String> words() {
    return trim()
        .replaceAll(RegExp(r'[_\-\.\s]+'), ' ')
        .split(' ')
        .expand((word) => RegExp(r'[A-Z]?[a-z]+|[0-9]+|[A-Z]+(?![a-z])')
        .allMatches(word)
        .map((m) => m.group(0)!))
        .toList();
  }

  String charAt(int index) => substring(index, index + 1);

  bool equalsIgnoreCase(String anotherString) =>
      anotherString.toLowerCase() == toLowerCase();

  void forEachChar(void Function(String char) action) {
    for (int i = 0; i < length; i++) {
      action(charAt(i));
    }
  }

  String getExtension() =>
      contains('.') ? split('.').last : '';

  bool isAlpha() => RegExp(r'^[a-zA-Z]+$').hasMatch(this);

  bool isAlphaNumeric() => RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);

  bool isNumeric() => RegExp(r'^-?[0-9]+$').hasMatch(this);

  bool isJson() {
    try {
      jsonDecode(this);
      return true;
    } catch (_) {
      return false;
    }
  }

  int countOccurrencesOf(String match) =>
      split(match).length - 1;

  List<dynamic> toJsonList({bool growable = true}) {
    final result = List.empty(growable: growable);
    try {
      final decoded = jsonDecode(this);
      if (decoded is List) {
        return List<dynamic>.from(decoded);
      } else if (decoded is Map) {
        return decoded.values.toList();
      }
    } catch (_) {}
    return result;
  }

  Map<String, dynamic> toJsonMap() {
    try {
      final decoded = jsonDecode(this);
      return decoded is Map<String, dynamic> ? decoded : {};
    } catch (_) {
      return {};
    }
  }

  bool regexMatch(String pattern, Map<String, String> matches) {
    final regExpVar = RegExp(r'\{([a-zA-Z_][a-zA-Z0-9_]*)\}');
    final groupMatches = regExpVar.allMatches(pattern).map((e) => e.group(1)!).toList();
    String escaped = RegExp.escape(pattern).replaceAllMapped(RegExp(r'\\\{|\}'), (m) {
      return m.group(0) == '\\{' ? '{' : '}';
    });
    String regexString = escaped.replaceAllMapped(regExpVar, (_) => r'([^/]+)');
    final regex = RegExp('^$regexString\$');
    final rawMatches = regex.firstMatch(this);
    if (rawMatches == null) return false;
    for (int i = 0; i < groupMatches.length; i++) {
      matches[groupMatches[i]] = rawMatches.group(i + 1) ?? '';
    }
    return true;
  }

  String toCamelCase() {
    final _words = words().map((w) => w.toLowerCase()).toList();
    return _words.asMap().entries.map((entry) {
      if (entry.key == 0) return entry.value;
      return entry.value[0].toUpperCase() + entry.value.substring(1);
    }).join();
  }

  String toCamelSnakeCase() {
    final _words = words().map((w) => w.toLowerCase()).toList();
    return _words.asMap().entries.map((entry) {
      if (entry.key == 0) return entry.value;
      return entry.value[0].toUpperCase() + entry.value.substring(1);
    }).join('_');
  }

  String toCapitalCase() =>
      words().map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase()).join(' ');

  String toCapitalSnakeCase() =>
      words().map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase()).join('_');

  String toCobolCase() => words().map((w) => w.toUpperCase()).join('-');

  String toDotCase() => words().map((w) => w.toLowerCase()).join('.');

  String toKebabCase() => words().map((w) => w.toLowerCase()).join('-');

  String toPascalCase() =>
      words().map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase()).join();

  String toPascalSnakeCase() =>
      words().map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase()).join('_');

  String toScreamingSnakeCase() => words().map((w) => w.toUpperCase()).join('_');

  String toSentenceCase() {
    final s = toLowerCase().trim();
    return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
  }

  String toSnakeCase() => words().map((w) => w.toLowerCase()).join('_');

  String toTrainCase() =>
      words().map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase()).join('-');

  String padWithChar({
    required String char,
    required int toLength,
  }) {
    String result = this;
    if (toLength > 0) {
      int currentLength = result.length;
      if (currentLength < toLength) {
        result = char * (toLength - currentLength) + result;
      }
    }
    return result;
  }
}
