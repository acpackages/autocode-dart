/* AcDoc({
  "description": "Enumeration of different SQL-related entities such as tables, views, triggers, and more.",
  "author": "Sanket Patel",
  "type": "development"
}) */
enum AcEnumSqlEntity {
  /* AcDoc({"description": "Represents a SQL function entity."}) */
  function('function'),

  /* AcDoc({"description": "Represents a relationship entity in SQL such as foreign keys."}) */
  relationship('relationship'),

  /* AcDoc({"description": "Represents a stored procedure in SQL."}) */
  storedProcedure('stored_procedure'),

  /* AcDoc({"description": "Represents a table entity in SQL."}) */
  table('table'),

  /* AcDoc({"description": "Represents a SQL trigger."}) */
  trigger('trigger'),

  /* AcDoc({"description": "Represents a view entity in SQL."}) */
  view('view'),

  /* AcDoc({"description": "Represents an index used to speed up queries."}) */
  index_('index'),

  /* AcDoc({"description": "Represents a schema in a SQL database."}) */
  schema('schema'),

  /* AcDoc({"description": "Represents a sequence object for generating numeric values."}) */
  sequence('sequence'),

  /* AcDoc({"description": "Represents a constraint entity like primary key or check constraint."}) */
  constraint('constraint'),

  /* AcDoc({"description": "Represents a column in a SQL table."}) */
  column('column'),

  /* AcDoc({"description": "Represents an entire SQL database."}) */
  database('database'),

  /* AcDoc({"description": "Represents a user-defined type (UDT)."}) */
  userDefinedType('user_defined_type'),

  /* AcDoc({"description": "Represents a synonym, which is an alias for another object."}) */
  synonym('synonym'),

  /* AcDoc({"description": "Represents a SQL role."}) */
  role('role'),

  /* AcDoc({"description": "Represents a SQL rule object."}) */
  rule('rule'),

  /* AcDoc({"description": "Represents a default value object in SQL."}) */
  defaultValue('default'),

  /* AcDoc({"description": "Represents a partition function used in table partitioning."}) */
  partitionFunction('partition_function'),

  /* AcDoc({"description": "Represents a partition scheme for mapping partitions to filegroups."}) */
  partitionScheme('partition_scheme');

  /* AcDoc({"description": "The string representation of the SQL entity."}) */
  final String value;

  /* AcDoc({"description": "Constructor that assigns a string value to the enum variant."}) */
  const AcEnumSqlEntity(this.value);

  /* AcDoc({
    "description": "Returns the enum value that matches the given string.",
    "params": [{"name": "value", "description": "The string value to match."}],
    "returns": "The matching enum value, or null if no match is found."
  }) */
  static AcEnumSqlEntity? fromValue(String value) {
    try {
      return AcEnumSqlEntity.values.firstWhere((e) => e.value == value);
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

  /* AcDoc({"description": "Returns the SQL entity as a string."}) */
  @override
  String toString() => value;
}
