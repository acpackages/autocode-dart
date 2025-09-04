/* AcDoc({
  "description": "Enumeration of different SQL-related entities such as tables, views, triggers, and more.",
  "author": "Sanket Patel",
  "type": "development"
}) */
enum AcEnumSqlEntity {
  /* AcDoc({"description": "Represents a SQL function entity."}) */
  function('FUNCTION'),

  /* AcDoc({"description": "Represents a relationship entity in SQL such as foreign keys."}) */
  relationship('RELATIONSHIP'),

  /* AcDoc({"description": "Represents a stored procedure in SQL."}) */
  storedProcedure('STORED_PROCEDURE'),

  /* AcDoc({"description": "Represents a table entity in SQL."}) */
  table('TABLE'),

  /* AcDoc({"description": "Represents a SQL trigger."}) */
  trigger('TRIGGER'),

  /* AcDoc({"description": "Represents a view entity in SQL."}) */
  view('VIEW'),

  /* AcDoc({"description": "Represents an index used to speed up queries."}) */
  index_('INDEX'),

  /* AcDoc({"description": "Represents a schema in a SQL database."}) */
  schema('SCHEMA'),

  /* AcDoc({"description": "Represents a sequence object for generating numeric values."}) */
  sequence('SEQUENCE'),

  /* AcDoc({"description": "Represents a constraint entity like primary key or check constraint."}) */
  constraint('CONSTRAINT'),

  /* AcDoc({"description": "Represents a column in a SQL table."}) */
  column('COLUMN'),

  /* AcDoc({"description": "Represents an entire SQL database."}) */
  database('DATABASE'),

  /* AcDoc({"description": "Represents a user-defined type (UDT)."}) */
  userDefinedType('USER_DEFINED_TYPE'),

  /* AcDoc({"description": "Represents a synonym, which is an alias for another object."}) */
  synonym('SYNONYM'),

  /* AcDoc({"description": "Represents a SQL role."}) */
  role('ROLE'),

  /* AcDoc({"description": "Represents a SQL rule object."}) */
  rule('RULE'),

  /* AcDoc({"description": "Represents a default value object in SQL."}) */
  defaultValue('DEFAULT'),

  /* AcDoc({"description": "Represents a partition function used in table partitioning."}) */
  partitionFunction('PARTITION_FUNCTION'),

  /* AcDoc({"description": "Represents a partition scheme for mapping partitions to filegroups."}) */
  partitionScheme('PARTITION_SCHEME');

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
