import 'dart:convert';
import 'package:ac_documentation/ac_documentation.dart';

/* AcDoc({
  "description": "Parses documentation blocks (/* AcDoc({...}) */) from any programming language file and attaches metadata like class/method/field context.",
  "type": "development",
  "author": "AcDocs System"
}) */
class AcDocParser {
  /* AcDoc({
    "description": "Parses AcDoc blocks from a source file string and returns a list of AcDoc models with scope metadata.",
    "params": {
      "content": "Raw source code content to parse."
    },
    "returns": {
      "type": "List<AcDoc>",
      "description": "List of parsed documentation models with target and context info."
    }
  }) */
  static List<AcDoc> parseFromSource(String content) {
    print(content);
    final docRegex = RegExp(r'/\*+\s*AcDoc\((\{.*?\})\)\s*\*+/', multiLine: true, dotAll: true);
    final matches = docRegex.allMatches(content);
    final docs = <AcDoc>[];

    final lines = content.split('\n');
    final lineOffsets = _computeLineOffsets(content);

    for (final match in matches) {
      final jsonStr = match.group(1);
      if (jsonStr == null) continue;

      try {
        final doc = AcDoc.instanceFromJson(jsonData: json.decode(jsonStr));

        final matchLine = _getLineFromOffset(match.start, lineOffsets);
        final forwardContext = lines.skip(matchLine).take(10);
        final backwardContext = lines.take(matchLine).toList().reversed;

        doc.enclosingClass = _findEnclosingClass(backwardContext);
        final target = _findTarget(forwardContext);
        doc.targetType = target['type'];
        doc.targetName = target['name'];

        docs.add(doc);
      } catch (e) {
        print(e);
        continue;
      }
    }

    return docs;
  }

  /* AcDoc({
    "description": "Computes line start offsets so a byte offset can be mapped to line number.",
    "params": {
      "content": "Raw content of the source file."
    },
    "returns": {
      "type": "List<int>",
      "description": "List of byte offsets for each line start."
    }
  }) */
  static List<int> _computeLineOffsets(String content) {
    final offsets = <int>[];
    int offset = 0;
    for (final line in content.split('\n')) {
      offsets.add(offset);
      offset += line.length + 1; // +1 for newline
    }
    return offsets;
  }

  /* AcDoc({
    "description": "Returns the line number that contains a given character offset.",
    "params": {
      "offset": "Byte offset to map.",
      "offsets": "Precomputed line offsets list."
    },
    "returns": {
      "type": "int",
      "description": "Line number (zero-based index) corresponding to the offset."
    }
  }) */
  static int _getLineFromOffset(int offset, List<int> offsets) {
    for (int i = 0; i < offsets.length; i++) {
      if (offsets[i] > offset) return i - 1;
    }
    return offsets.length - 1;
  }

  /* AcDoc({
    "description": "Finds the closest enclosing class from lines above a documentation block.",
    "params": {
      "reversedLines": "Lines above the block, in reverse order."
    },
    "returns": {
      "type": "String?",
      "description": "Class name if found, otherwise null."
    }
  }) */
  static String? _findEnclosingClass(Iterable<String> reversedLines) {
    for (final line in reversedLines) {
      final trimmed = line.trim();
      if (_isLineComment(trimmed)) continue;
      final classMatch = RegExp(r'^class\s+(\w+)').firstMatch(trimmed);
      if (classMatch != null) {
        return classMatch.group(1);
      }
    }
    return null;
  }

  /* AcDoc({
    "description": "Analyzes upcoming lines to detect whether a class, method, or field follows the documentation block.",
    "params": {
      "lines": "Lines following the AcDoc block."
    },
    "returns": {
      "type": "Map<String, String?>",
      "description": "Map containing 'type' and 'name' of the target element."
    }
  }) */
  static Map<String, String?> _findTarget(Iterable<String> lines) {
    for (final line in lines) {
      final trimmed = line.trim();
      if (_isLineComment(trimmed) || trimmed.isEmpty) continue;

      if (RegExp(r'^class\s+(\w+)').hasMatch(trimmed)) {
        final name = RegExp(r'^class\s+(\w+)').firstMatch(trimmed)?.group(1);
        return {'type': 'class', 'name': name};
      }

      if (RegExp(r'\w+\s+\w+\s*\([^)]*\)\s*(\{|=>|;)?').hasMatch(trimmed)) {
        final name = RegExp(r'\b(\w+)\s*\(').firstMatch(trimmed)?.group(1);
        return {'type': 'method', 'name': name};
      }

      if (RegExp(r'\w+\s+\w+\s*=\s*').hasMatch(trimmed)) {
        final name = RegExp(r'\b(\w+)\s*=').firstMatch(trimmed)?.group(1);
        return {'type': 'field', 'name': name};
      }
    }
    return {'type': null, 'name': null};
  }

  /* AcDoc({
    "description": "Determines whether a line is a comment and should be ignored during context scanning.",
    "params": {
      "line": "Line of code to evaluate."
    },
    "returns": {
      "type": "bool",
      "description": "True if the line is a comment or empty, otherwise false."
    }
  }) */
  static bool _isLineComment(String line) {
    return line.startsWith('//') || line.startsWith('#') || line.startsWith('/*') || line.startsWith('*');
  }
}
