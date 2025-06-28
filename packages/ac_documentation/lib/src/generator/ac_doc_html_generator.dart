import 'dart:io';
import 'package:ac_documentation/ac_documentation.dart';

/* AcDoc({
  "description": "Generates HTML documentation from a list of AcDoc metadata objects.",
  "type": "development",
  "author": "AcDocs System"
}) */
class AcDocHtmlGenerator {
  /* AcDoc({
    "description": "Writes HTML documentation to a file at the specified output path.",
    "params": [
      {"name": "acDocs", "description": "List of parsed AcDoc metadata objects."},
      {"name": "outputPath", "description": "Path where the HTML file should be written."}
    ]
  }) */
  static void generateHtmlFile({required List<AcDoc> acDocs, required outputPath}) {
    File(outputPath).writeAsStringSync(generateHtmlString(acDocs: acDocs));
  }

  /* AcDoc({
    "description": "Generates an HTML string representation of the given documentation metadata.",
    "params": [
      {"name": "acDocs", "description": "List of AcDoc instances to render as HTML."}
    ],
    "returns": "HTML string of rendered documentation."
  }) */
  static String generateHtmlString({required List<AcDoc> acDocs,bool generateOnlyBody = false}) {
    final buffer = StringBuffer();
    if(!generateOnlyBody) {
      buffer.writeln('<!DOCTYPE html>');
      buffer.writeln('<html lang="en">');
      buffer.writeln('<head>');
      buffer.writeln('<meta charset="UTF-8">');
      buffer.writeln(
          '<meta name="viewport" content="width=device-width, initial-scale=1.0">');
      buffer.writeln('<title>Documentation</title>');
      buffer.writeln('<style>');
      buffer.writeln(
          'body { font-family: Arial; padding: 2rem; background: #f9f9f9; }');
      buffer.writeln('h2 { margin-top: 2rem; color: #333; }');
      buffer.writeln('h3 { margin-top: 1.5rem; color: #555; }');
      buffer.writeln(
          'section { margin-bottom: 2rem; padding: 1rem; background: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }');
      buffer.writeln(
          'pre { background: #eee; padding: 0.5rem; border-radius: 4px; overflow-x: auto; }');
      buffer.writeln('</style>');
      buffer.writeln('</head>');
      buffer.writeln('<body>');
    }
    final grouped = <String, List<AcDoc>>{};
    for (final doc in acDocs) {
      final scope = doc.targetType ?? 'unknown';
      grouped.putIfAbsent(scope, () => []).add(doc);
    }

    for (final entry in grouped.entries) {
      buffer.writeln('<h2>${entry.key.toUpperCase()}</h2>');
      for (final doc in entry.value) {
        buffer.writeln('<section>');
        buffer.writeln('<h3>${doc.targetName ?? 'Unnamed'} ${doc.enclosingClass != null ? 'in ${doc.enclosingClass}' : ''}</h3>');
        if (doc.description != null) buffer.writeln('<p><strong>Description:</strong> ${doc.description}</p>');
        if (doc.examples != null) buffer.writeln('<p><strong>Example:</strong></p><pre>${doc.examples}</pre>');
        if (doc.author != null) buffer.writeln('<p><strong>Author:</strong> ${doc.author}</p>');
        if (doc.deprecated != null) {
          buffer.writeln('<p><strong>Deprecated:</strong> ${doc.deprecated!.message ?? ''}');
          if (doc.deprecated!.since != null) buffer.write(' (since ${doc.deprecated!.since})');
          buffer.writeln('</p>');
        }
        buffer.writeln('</section>');
      }
    }
    if(!generateOnlyBody) {
      buffer.writeln('</body>');
      buffer.writeln('</html>');
    }
    return buffer.toString();
  }
}
