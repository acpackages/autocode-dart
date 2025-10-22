import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';

/* AcDoc({
  "summary": "A base class for a high-level database service.",
  "description": "This class orchestrates database interactions by combining a data dictionary instance, a specific DAO implementation (like `AcMysqlDao`), event handling, and global connection settings. It serves as a primary entry point for application logic to interact with the database in a structured way.",
  "example": "// Prerequisite: Configure the global database settings first.\nAcSqlDatabase.databaseType = AcEnumSqlDatabaseType.mysql;\nAcSqlDatabase.sqlConnection = AcSqlConnection(database: 'my_app_db');\n\n// Now, create an instance of the database service.\nfinal dbService = AcSqlDbBase(dataDictionaryName: 'main_schema');\n\n// The `dao` is now automatically configured as an AcMysqlDao.\nfinal result = await dbService.dao?.checkTableExist(tableName: 'users');"
}) */
class AcSqlDbBase {
  /* AcDoc({"summary": "The loaded data dictionary instance for schema awareness."}) */
  late AcDataDictionary acDataDictionary;

  /* AcDoc({
    "summary": "The active Data Access Object (DAO) for executing queries.",
    "description": "This is instantiated based on the `databaseType` and provides the concrete implementation for all database operations."
  }) */
  AcBaseSqlDao? dao;

  /* AcDoc({"summary": "The type of SQL database, used to select the correct DAO."}) */
  AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown;

  /* AcDoc({"summary": "The name of the currently active data dictionary."}) */
  String dataDictionaryName = "default";

  /* AcDoc({"summary": "The event handler for this database service instance."}) */
  late AcEvents events;

  /* AcDoc({"summary": "The logger for logging operations within this service."}) */
  late AcLogger logger;

  /* AcDoc({"summary": "The connection configuration used by the DAO."}) */
  AcSqlConnection? sqlConnection;

  /* AcDoc({
    "summary": "Initializes the database service.",
    "description": "Creates a new database service instance, automatically configuring it based on the global `AcSqlDatabase` settings. It selects the appropriate DAO (e.g., `AcMysqlDao`) based on the globally set `databaseType`.\n\nNote: This constructor requires `AcSqlDatabase.sqlConnection` to be set beforehand to avoid a runtime error.",
    "params": [
      {"name": "dataDictionaryName", "description": "The name of the data dictionary to load initially. Defaults to 'default'."}
    ]
  }) */
  AcSqlDbBase({String dataDictionaryName = "default"}) {
    databaseType = AcSqlDatabase.databaseType;
    sqlConnection = AcSqlDatabase.sqlConnection;
    useDataDictionary(dataDictionaryName: dataDictionaryName);
    logger = AcLogger(logType: AcEnumLogType.print_, logMessages: false);
    events = AcEvents(); // Initialized to prevent LateInitializationError.

    if (databaseType == AcEnumSqlDatabaseType.mysql) {
      dao = AcMysqlDao();
      // The force-unwrap `!` implies AcSqlDatabase.sqlConnection must be configured before creating this class.
      dao?.setSqlConnection(sqlConnection: sqlConnection!);
    }
    else if (databaseType == AcEnumSqlDatabaseType.sqlite) {
      dao = AcSqliteDao();
      dao?.setSqlConnection(sqlConnection: sqlConnection!);
    }
    // Other database types like SQLite or PostgreSQL could be handled here.
  }

  /* AcDoc({
    "summary": "Switches the active data dictionary for this service instance.",
    "description": "Loads or re-loads the data dictionary with the specified name, allowing the service to work with different database schemas dynamically.",
    "params": [
      {"name": "dataDictionaryName", "description": "The name of the data dictionary to load and use."}
    ]
  }) */
  void useDataDictionary({String dataDictionaryName = "default"}) {
    this.dataDictionaryName = dataDictionaryName;
    acDataDictionary = AcDataDictionary.getInstance(
      dataDictionaryName: this.dataDictionaryName,
    );
  }
}
// import 'package:autocode/autocode.dart';
// import 'package:ac_data_dictionary/ac_data_dictionary.dart';
// import 'package:ac_sql/ac_sql.dart';
//
// class AcSqlDbBase {
//   late AcDataDictionary acDataDictionary;
//   AcBaseSqlDao? dao;
//   AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown;
//   String dataDictionaryName = "default";
//   late AcEvents events;
//   late AcLogger logger;
//   AcSqlConnection? sqlConnection;
//
//   AcSqlDbBase({String dataDictionaryName = "default"}) {
//     databaseType = AcSqlDatabase.databaseType;
//     sqlConnection = AcSqlDatabase.sqlConnection;
//     useDataDictionary(dataDictionaryName: dataDictionaryName);
//     logger = AcLogger(logType: AcEnumLogType.print_, logMessages: true);
//     if (databaseType == AcEnumSqlDatabaseType.mysql) {
//       dao = AcMysqlDao();
//       dao?.setSqlConnection(sqlConnection: sqlConnection!);
//     }
//   }
//
//   void useDataDictionary({String dataDictionaryName = "default"}) {
//     this.dataDictionaryName = dataDictionaryName;
//     acDataDictionary = AcDataDictionary.getInstance(
//       dataDictionaryName: dataDictionaryName,
//     );
//   }
// }
