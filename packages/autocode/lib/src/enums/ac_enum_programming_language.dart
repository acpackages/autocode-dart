/* AcDoc({
  "description": "Enumeration representing various programming languages supported by the system.",
  "author": "Sanket Patel",
  "type": "development"
}) */
enum AcEnumProgrammingLanguage {
  /* AcDoc({"description": "TypeScript programming language."}) */
  typescript('TYPESCRIPT'),

  /* AcDoc({"description": "JavaScript programming language."}) */
  javascript('JAVASCRIPT'),

  /* AcDoc({"description": "Dart programming language."}) */
  dart('DART'),

  /* AcDoc({"description": "PHP programming language."}) */
  php('PHP'),

  /* AcDoc({"description": "C# programming language."}) */
  csharp('CSHARP'),

  /* AcDoc({"description": "Java programming language."}) */
  java('JAVA'),

  /* AcDoc({"description": "Python programming language."}) */
  python('PYTHON'),

  /* AcDoc({"description": "Go programming language."}) */
  go('GO'),

  /* AcDoc({"description": "Kotlin programming language."}) */
  kotlin('KOTLIN'),

  /* AcDoc({"description": "Swift programming language."}) */
  swift('SWIFT'),

  /* AcDoc({"description": "Ruby programming language."}) */
  ruby('RUBY'),

  /* AcDoc({"description": "Rust programming language."}) */
  rust('RUST'),

  /* AcDoc({"description": "C programming language."}) */
  c('C'),

  /* AcDoc({"description": "C++ programming language."}) */
  cpp('CPP'),

  /* AcDoc({"description": "Objective-C programming language."}) */
  objectivec('OBJECTIVEC'),

  /* AcDoc({"description": "Scala programming language."}) */
  scala('SCALA'),

  /* AcDoc({"description": "Perl programming language."}) */
  perl('PERL'),

  /* AcDoc({"description": "Haskell programming language."}) */
  haskell('HASKELL'),

  /* AcDoc({"description": "SQL query language."}) */
  sql('SQL'),

  /* AcDoc({"description": "Shell scripting language."}) */
  shell('SHELL'),

  /* AcDoc({"description": "YAML configuration format."}) */
  yaml('YAML'),

  /* AcDoc({"description": "JSON data format."}) */
  json('JSON');

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
      return AcEnumProgrammingLanguage.values.firstWhere(
        (e) => e.value == value,
      );
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
