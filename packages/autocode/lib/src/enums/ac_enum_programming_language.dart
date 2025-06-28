/* AcDoc({
  "description": "Enumeration representing various programming languages supported by the system.",
  "author": "Sanket Patel",
  "type": "development"
}) */
enum AcEnumProgrammingLanguage {
  /* AcDoc({"description": "TypeScript programming language."}) */
  typescript('typescript'),

  /* AcDoc({"description": "JavaScript programming language."}) */
  javascript('javascript'),

  /* AcDoc({"description": "Dart programming language."}) */
  dart('dart'),

  /* AcDoc({"description": "PHP programming language."}) */
  php('php'),

  /* AcDoc({"description": "C# programming language."}) */
  csharp('csharp'),

  /* AcDoc({"description": "Java programming language."}) */
  java('java'),

  /* AcDoc({"description": "Python programming language."}) */
  python('python'),

  /* AcDoc({"description": "Go programming language."}) */
  go('go'),

  /* AcDoc({"description": "Kotlin programming language."}) */
  kotlin('kotlin'),

  /* AcDoc({"description": "Swift programming language."}) */
  swift('swift'),

  /* AcDoc({"description": "Ruby programming language."}) */
  ruby('ruby'),

  /* AcDoc({"description": "Rust programming language."}) */
  rust('rust'),

  /* AcDoc({"description": "C programming language."}) */
  c('c'),

  /* AcDoc({"description": "C++ programming language."}) */
  cpp('cpp'),

  /* AcDoc({"description": "Objective-C programming language."}) */
  objectivec('objectivec'),

  /* AcDoc({"description": "Scala programming language."}) */
  scala('scala'),

  /* AcDoc({"description": "Perl programming language."}) */
  perl('perl'),

  /* AcDoc({"description": "Haskell programming language."}) */
  haskell('haskell'),

  /* AcDoc({"description": "SQL query language."}) */
  sql('sql'),

  /* AcDoc({"description": "Shell scripting language."}) */
  shell('shell'),

  /* AcDoc({"description": "YAML configuration format."}) */
  yaml('yaml'),

  /* AcDoc({"description": "JSON data format."}) */
  json('json');

  /* AcDoc({"description": "The string representation of the programming language."}) */
  final String value;

  /* AcDoc({"description": "Constructor that assigns a string value to the enum variant."}) */
  const AcEnumProgrammingLanguage(this.value);

  /* AcDoc({
    "description": "Returns the enum value that matches the given string.",
    "params": [{"name": "value", "description": "The string value to match."}],
    "returns": "The matching enum value, or null if no match is found."
  }) */
  static AcEnumProgrammingLanguage? fromValue(String value) {
    try {
      return AcEnumProgrammingLanguage.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }

  /* AcDoc({
    "description": "Checks if this enum's value matches the provided string.",
    "params": [{"name": "other", "description": "The string to compare with."}],
    "returns": "true if the string matches, otherwise false."
  }) */
  bool equals(String other) => value == other;

  /* AcDoc({"description": "Returns the programming language as a string."}) */
  @override
  String toString() => value;
}
