import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_web/ac_web.dart';
/* AcDoc({
  "summary": "Automatically generates RESTful API endpoints from a data dictionary.",
  "description": "This class provides a fluent builder pattern to automatically create a full set of CRUD (Create, Read, Update, Delete) and other API routes for tables defined in an `AcDataDictionary`. It inspects the dictionary and registers the necessary routes with a provided `AcWeb` instance, dramatically speeding up API development.",
  "example": "final app = AcWeb();\n\n// Create and configure the auto-API generator.\nAcDataDictionaryAutoApi(acWeb: app, dataDictionaryName: 'main_db')\n  .excludeTable(tableName: 'internal_logs') // Exclude a specific table\n  .includeTable(tableName: 'users', delete: false) // Include 'users' but disable the delete route\n  .generate(); // Generate all configured routes."
}) */
class AcDataDictionaryAutoApi {
  /* AcDoc({"summary": "The `AcWeb` server instance where the generated routes will be registered."}) */
  late AcWeb acWeb;

  /* AcDoc({"summary": "The name of the data dictionary to use for generating APIs."}) */
  String dataDictionaryName = '';

  /* AcDoc({"summary": "A map of tables and their specific operations to exclude from generation."}) */
  Map<String, Map<String, bool>> excludeTables = {};

  /* AcDoc({"summary": "A map of tables and their specific operations to explicitly include in generation."}) */
  Map<String, Map<String, bool>> includeTables = {};

  /* AcDoc({"summary": "A global URL prefix to apply to all generated routes."}) */
  String urlPrefix = '';

  /* AcDoc({"summary": "The loaded data dictionary instance."}) */
  late AcDataDictionary acDataDictionary;

  /* AcDoc({"summary": "The logger instance for the generator."}) */
  AcLogger logger = AcLogger(logType: AcEnumLogType.console,logMessages: true);

  /* AcDoc({
    "summary": "Creates a new instance of the automatic API generator.",
    "params": [
      {"name": "acWeb", "description": "The `AcWeb` instance to register routes on."},
      {"name": "dataDictionaryName", "description": "The data dictionary to use. Defaults to 'default'."}
    ]
  }) */
  AcDataDictionaryAutoApi({
    required this.acWeb,
    this.dataDictionaryName = 'default',
  }) {
    acDataDictionary = AcDataDictionary.getInstance(
      dataDictionaryName: dataDictionaryName,
    );
  }

  /* AcDoc({
    "summary": "Specifies a table and its operations to exclude from API generation.",
    "description": "If no specific operations (delete, insert, etc.) are set to true, the entire table will be excluded. If specific operations are set to true, only those will be excluded.",
    "returns": "The current instance, for a fluent interface.",
    "returns_type": "AcDataDictionaryAutoApi"
  }) */
  AcDataDictionaryAutoApi excludeTable({
    required String tableName,
    bool? delete,
    bool? insert,
    bool? save,
    bool? select,
    bool? selectDistinct,
    bool? selectRow,
    bool? update,
  }) {
    if (delete == null &&
        insert == null &&
        save == null &&
        select == null &&
        selectDistinct == null &&
        selectRow == null &&
        update == null) {
      delete = true;
      insert = true;
      save = true;
      select = true;
      selectDistinct = true;
      selectRow = true;
      update = true;
    } else {
      delete ??= false;
      insert ??= false;
      save ??= false;
      select ??= false;
      selectDistinct ??= false;
      selectRow ??= false;
      update ??= false;
    }
    excludeTables[tableName] = {
      'delete': delete,
      'insert': insert,
      'save': save,
      'select': select,
      'select_distinct': selectDistinct,
      'select_row': selectRow,
      'update': update,
    };
    return this;
  }

  /* AcDoc({
    "summary": "Specifies a table and its operations to include in API generation.",
    "description": "If `includeTables` is used, only the tables added via this method will have APIs generated. If no specific operations (delete, insert, etc.) are set to true, all operations for the table will be included.",
    "returns": "The current instance, for a fluent interface.",
    "returns_type": "AcDataDictionaryAutoApi"
  }) */
  AcDataDictionaryAutoApi includeTable({
    required String tableName,
    bool? delete,
    bool? insert,
    bool? save,
    bool? select,
    bool? selectDistinct,
    bool? selectRow,
    bool? update,
  }) {
    if (delete == null &&
        insert == null &&
        save == null &&
        select == null &&
        selectDistinct == null &&
        selectRow == null &&
        update == null) {
      delete = true;
      insert = true;
      save = true;
      select = true;
      selectDistinct = true;
      selectRow = true;
      update = true;
    } else {
      delete ??= false;
      insert ??= false;
      save ??= false;
      select ??= false;
      selectDistinct ??= false;
      selectRow ??= false;
      update ??= false;
    }
    includeTables[tableName] = {
      'delete': delete,
      'insert': insert,
      'save': save,
      'select': select,
      'select_distinct': selectDistinct,
      'select_row': selectRow,
      'update': update,
    };
    return this;
  }

  /* AcDoc({
    "summary": "Generates all configured API routes.",
    "description": "This method iterates through all tables in the data dictionary, applies the include/exclude rules, and then delegates the creation of each specific API route (delete, insert, etc.) to specialized helper classes.",
    "returns": "The current instance, for a fluent interface.",
    "returns_type": "AcDataDictionaryAutoApi"
  }) */
  AcDataDictionaryAutoApi generate() {
    logger.log(
      "Generating apis for tables in data dictionary $dataDictionaryName...",
    );
    if (includeTables.isEmpty && excludeTables.isEmpty) {
      logger.log("No include & exclude tables specified!");
    }
    for (final acDDTable in AcDataDictionary.getTables(dataDictionaryName: dataDictionaryName).values) {
      bool continueOperation = false;
      bool delete = true;
      bool insert = true;
      bool save = true;
      bool select = true;
      bool selectDistinct = true;
      bool selectRow = true;
      bool update = true;
      logger.log("Checking table ${acDDTable.tableName} for auto data dictionary...");
      if (includeTables.isEmpty && excludeTables.isEmpty) {
        continueOperation = true;
      } else if (includeTables.isNotEmpty) {
        if (includeTables.containsKey(acDDTable.tableName)) {
          continueOperation = true;
          logger.log(
            "Include tables list contains table ${acDDTable.tableName}",
          );
          final options = includeTables[acDDTable.tableName]!;
          delete = options['delete']!;
          insert = options['insert']!;
          save = options['save']!;
          select = options['select']!;
          selectDistinct = options['select_distinct']!;
          selectRow = options['select_row']!;
          update = options['update']!;
        } else {
          logger.log(
            "Include tables list does not contains table ${acDDTable.tableName}",
          );
        }
      } else if (!excludeTables.containsKey(acDDTable.tableName)) {
        logger.log(
          "Exclude tables list does not contain table ${acDDTable.tableName}",
        );
        continueOperation = true;
      } else if (excludeTables.containsKey(acDDTable.tableName)) {
        continueOperation = true;
        final options = excludeTables[acDDTable.tableName]!;
        delete = !options['delete']!;
        insert = !options['insert']!;
        save = !options['save']!;
        select = !options['select']!;
        selectDistinct = !options['select_distinct']!;
        selectRow = !options['select_row']!;
        update = !options['update']!;
      }

      if (continueOperation) {
        logger.log("Generating apis for table ${acDDTable.tableName}...");
        bool apiAdded = false;

        if (delete) {
          logger.log(
            "Generating delete api for table ${acDDTable.tableName}...",
          );
          AcDataDictionaryAutoDelete(
            acDDTable: acDDTable,
            acDataDictionaryAutoApi: this,
          );
          apiAdded = true;
          logger.log("Generated delete api for table ${acDDTable.tableName}!");
        }
        if (insert) {
          logger.log(
            "Generating insert api for table ${acDDTable.tableName}...",
          );
          AcDataDictionaryAutoInsert(
            acDDTable: acDDTable,
            acDataDictionaryAutoApi: this,
          );
          apiAdded = true;
          logger.log("Generated insert api for table ${acDDTable.tableName}!");
        }
        if (save) {
          logger.log("Generating save api for table ${acDDTable.tableName}...");
          AcDataDictionaryAutoSave(
            acDDTable: acDDTable,
            acDataDictionaryAutoApi: this,
          );
          apiAdded = true;
          logger.log("Generated save api for table ${acDDTable.tableName}!");
        }
        if (select) {
          logger.log(
            "Generating select api for table ${acDDTable.tableName}...",
          );
          AcDataDictionaryAutoSelect(
            acDDTable: acDDTable,
            acDataDictionaryAutoApi: this,
            includeSelectRow: selectRow
          );
          apiAdded = true;
          logger.log("Generated select api for table ${acDDTable.tableName}!");
        }
        if (selectDistinct) {
          logger.log(
            "Generating select distinct apis for fields ins table ${acDDTable.tableName}...",
          );
          for (final distinctColumn in acDDTable.getSelectDistinctColumns()) {
            logger.log(
              "Generating select distinct api for field ${distinctColumn.columnName} in table ${acDDTable.tableName}...",
            );
            AcDataDictionaryAutoSelectDistinct(
              acDDTable: acDDTable,
              acDDTableColumn: distinctColumn,
              acDataDictionaryAutoApi: this,
            );
            apiAdded = true;
            logger.log(
              "Generated select distinct apis for field ${distinctColumn.columnName} in table ${acDDTable.tableName}!",
            );
          }
          logger.log(
            "Generated select distinct apis for table ${acDDTable.tableName}!",
          );
        }
        if (update) {
          logger.log(
            "Generating update api for table ${acDDTable.tableName}...",
          );
          AcDataDictionaryAutoUpdate(
            acDDTable: acDDTable,
            acDataDictionaryAutoApi: this,
          );
          apiAdded = true;
          logger.log("Generated update api for table ${acDDTable.tableName}!");
        }

        if (apiAdded) {
          final tag =
              AcApiDocTag()
                ..name = acDDTable.tableName
                ..description =
                    'Database operations for table ${acDDTable.tableName}';
          acWeb.acApiDoc.addTag(tag: tag);
        }
      }
      else{
        logger.log("Skipping apis for table ${acDDTable.tableName}!");
      }
    }
    logger.log(
      "Generated apis for tables in data dictionary $dataDictionaryName!",
    );
    return this;
  }
}
