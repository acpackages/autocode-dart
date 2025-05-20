import 'package:autocode/autocode.dart';
import 'package:autocode_data_dictionary/autocode_data_dictionary.dart';
import 'package:autocode_web/autocode_web.dart';

class AcDataDictionaryAutoApi {
  late AcWeb acWeb;
  String dataDictionaryName = '';
  Map<String, Map<String, bool>> excludeTables = {};
  Map<String, Map<String, bool>> includeTables = {};
  String pathForDelete = 'delete';
  String pathForInsert = 'add';
  String pathForSave = 'save';
  String pathForSelect = 'get';
  String pathForSelectDistinct = 'unique';
  String pathForUpdate = 'update';
  String urlPrefix = '';
  late AcDataDictionary acDataDictionary;
  AcLogger logger = AcLogger(logType: AcEnumLogType.CONSOLE);

  AcDataDictionaryAutoApi({required this.acWeb, this.dataDictionaryName = 'default'}) {
    acDataDictionary = AcDataDictionary.getInstance(dataDictionaryName: dataDictionaryName);
  }

  AcDataDictionaryAutoApi excludeTable({required String tableName,bool? delete,bool? insert,bool? save,bool? select,bool? selectDistinct,bool? update}) {
    if (delete == null && insert == null && save == null && select == null && selectDistinct == null && update == null) {
      delete = true;
      insert = true;
      save = true;
      select = true;
      selectDistinct = true;
      update = true;
    } else {
      delete ??= false;
      insert ??= false;
      save ??= false;
      select ??= false;
      selectDistinct ??= false;
      update ??= false;
    }
    excludeTables[tableName] = {
      'delete': delete,
      'insert': insert,
      'save': save,
      'select': select,
      'select_distinct': selectDistinct,
      'update': update,
    };
    return this;
  }

  AcDataDictionaryAutoApi includeTable({required String tableName,bool? delete,bool? insert,bool? save,bool? select,bool? selectDistinct,bool? update}) {
    if (delete == null && insert == null && save == null && select == null && selectDistinct == null && update == null) {
      delete = true;
      insert = true;
      save = true;
      select = true;
      selectDistinct = true;
      update = true;
    } else {
      delete ??= false;
      insert ??= false;
      save ??= false;
      select ??= false;
      selectDistinct ??= false;
      update ??= false;
    }
    includeTables[tableName] = {
      'delete': delete,
      'insert': insert,
      'save': save,
      'select': select,
      'select_distinct': selectDistinct,
      'update': update,
    };
    return this;
  }

  AcDataDictionaryAutoApi generate() {
    logger.log("Generating apis for tables in data dictionary $dataDictionaryName...");
    for (final acDDTable in AcDataDictionary.getTables(dataDictionaryName: dataDictionaryName).values) {

      bool continueOperation = false;
      bool delete = true;
      bool insert = true;
      bool save = true;
      bool select = true;
      bool selectDistinct = true;
      bool update = true;

      if (includeTables.isNotEmpty && excludeTables.isNotEmpty) {
        continueOperation = true;
      } else if (includeTables.isNotEmpty && includeTables.containsKey(acDDTable.tableName)) {
        continueOperation = true;
        final options = includeTables[acDDTable.tableName]!;
        delete = options['delete']!;
        insert = options['insert']!;
        save = options['save']!;
        select = options['select']!;
        selectDistinct = options['select_distinct']!;
        update = options['update']!;
      } else if (!excludeTables.containsKey(acDDTable.tableName)) {
        continueOperation = true;
      } else if (excludeTables.containsKey(acDDTable.tableName)) {
        continueOperation = true;
        final options = excludeTables[acDDTable.tableName]!;
        delete = !options['delete']!;
        insert = !options['insert']!;
        save = !options['save']!;
        select = !options['select']!;
        selectDistinct = !options['select_distinct']!;
        update = !options['update']!;
      }

      if (continueOperation) {
        logger.log("Generating apis for table ${acDDTable.tableName}...");
        bool apiAdded = false;

        if (delete) {
          logger.log("Generating delete api for table ${acDDTable.tableName}...");
          AcDataDictionaryAutoDelete(acDDTable: acDDTable, acDataDictionaryAutoApi: this);
          apiAdded = true;
          logger.log("Generated delete api for table ${acDDTable.tableName}!");
        }
        if (insert) {
          logger.log("Generating insert api for table ${acDDTable.tableName}...");
          AcDataDictionaryAutoInsert(acDDTable: acDDTable, acDataDictionaryAutoApi: this);
          apiAdded = true;
          logger.log("Generated insert api for table ${acDDTable.tableName}!");
        }
        if (save) {
          logger.log("Generating save api for table ${acDDTable.tableName}...");
          AcDataDictionaryAutoSave(acDDTable: acDDTable, acDataDictionaryAutoApi: this);
          apiAdded = true;
          logger.log("Generated save api for table ${acDDTable.tableName}!");
        }
        if (select) {
          logger.log("Generating select api for table ${acDDTable.tableName}...");
          AcDataDictionaryAutoSelect(acDDTable: acDDTable, acDataDictionaryAutoApi: this);
          apiAdded = true;
          logger.log("Generated select api for table ${acDDTable.tableName}!");
        }
        if (selectDistinct) {
          logger.log("Generating select distinct apis for fields ins table ${acDDTable.tableName}...");
          for (final distinctColumn in acDDTable.getSelectDistinctColumns()) {
            logger.log("Generating select distinct api for field ${distinctColumn.columnName} in table ${acDDTable.tableName}...");
            AcDataDictionaryAutoSelectDistinct(
              acDDTable: acDDTable,
              acDDTableColumn: distinctColumn,
              acDataDictionaryAutoApi: this,
            );
            apiAdded = true;
            logger.log("Generated select distinct apis for field ${distinctColumn.columnName} in table ${acDDTable.tableName}!");
          }
          logger.log("Generated select distinct apis for table ${acDDTable.tableName}!");
        }
        if (update) {
          logger.log("Generating update api for table ${acDDTable.tableName}...");
          AcDataDictionaryAutoUpdate(acDDTable: acDDTable, acDataDictionaryAutoApi: this);
          apiAdded = true;
          logger.log("Generated update api for table ${acDDTable.tableName}!");
        }

        if (apiAdded) {
          final tag = AcApiDocTag()
            ..name = acDDTable.tableName
            ..description = 'Database operations for table ${acDDTable.tableName}';
          acWeb.acApiDoc.addTag(tag:tag);
        }
      }
    }
    logger.log("Generated apis for tables in data dictionary $dataDictionaryName!");
    return this;
  }
}
