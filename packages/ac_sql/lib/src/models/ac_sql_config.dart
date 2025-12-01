import 'package:ac_mirrors/annotations.dart';
import 'package:autocode/autocode.dart';

@AcReflectable()
class AcSqlConfig {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyCascadeDeleteDestinationRows = 'cascadeDeleteDestinationRows';
  static const String keyCascadeDeleteSourceRows = 'cascadeDeleteSourceRows';

  @AcBindJsonProperty(key: keyCascadeDeleteDestinationRows)
  final  bool cascadeDeleteDestinationRows;

  @AcBindJsonProperty(key: keyCascadeDeleteSourceRows)
  final bool cascadeDeleteSourceRows;

  @AcBindJsonProperty(key: keyCascadeDeleteSourceRows)
  final AcSqliteConfig sqliteConfig;

  const AcSqlConfig({
    this.cascadeDeleteDestinationRows = false,
    this.cascadeDeleteSourceRows = false,
    this.sqliteConfig = const AcSqliteConfig()
  });

    factory AcSqlConfig.instanceFromJson({required Map<String, dynamic> jsonData}) {
    var instance = AcSqlConfig();
    return instance.fromJson(jsonData: jsonData);
  }

  AcSqlConfig fromJson({Map<String, dynamic> jsonData = const {}}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  @override
  String toString() {
    // Standardized to use AcJsonUtils for consistency with other classes.
    return AcJsonUtils.prettyEncode(toJson());
  }
}

@AcReflectable()
class AcSqliteConfig {
  // 🔑 JSON keys (follow lowerCamelCase naming convention)
  static const String keyForeignKeys = 'foreignKeys';
  static const String keyJournalMode = 'journalMode';
  static const String keySynchronous = 'synchronous';
  static const String keyTempStore = 'tempStore';
  static const String keyCacheSize = 'cacheSize';
  static const String keyBusyTimeout = 'busyTimeout';
  static const String keyAutoVacuum = 'autoVacuum';
  static const String keyRecursiveTriggers = 'recursiveTriggers';
  static const String keyCaseSensitiveLike = 'caseSensitiveLike';
  static const String keySecureDelete = 'secureDelete';
  static const String keyLockingMode = 'lockingMode';
  static const String keyWalAutoCheckpoint = 'walAutoCheckpoint';
  static const String keyJournalSizeLimit = 'journalSizeLimit';

  // ⚙️ Configuration fields
  @AcBindJsonProperty(key: keyForeignKeys)
  final bool foreignKeys;

  @AcBindJsonProperty(key: keyJournalMode)
  final String journalMode;

  @AcBindJsonProperty(key: keySynchronous)
  final String synchronous;

  @AcBindJsonProperty(key: keyTempStore)
  final String tempStore;

  @AcBindJsonProperty(key: keyCacheSize)
  final int cacheSize;

  @AcBindJsonProperty(key: keyBusyTimeout)
  final int busyTimeout;

  @AcBindJsonProperty(key: keyAutoVacuum)
  final String autoVacuum;

  @AcBindJsonProperty(key: keyRecursiveTriggers)
  final bool recursiveTriggers;

  @AcBindJsonProperty(key: keyCaseSensitiveLike)
  final bool caseSensitiveLike;

  @AcBindJsonProperty(key: keySecureDelete)
  final bool secureDelete;

  @AcBindJsonProperty(key: keyLockingMode)
  final String lockingMode;

  @AcBindJsonProperty(key: keyWalAutoCheckpoint)
  final int walAutoCheckpoint;

  @AcBindJsonProperty(key: keyJournalSizeLimit)
  final int journalSizeLimit;

  const AcSqliteConfig({
    this.foreignKeys = true,
    this.journalMode = 'WAL', // Write-Ahead Logging
    this.synchronous = 'NORMAL', // Balanced durability and performance
    this.tempStore = 'MEMORY', // Store temporary data in memory
    this.cacheSize = -65536, // ~64MB cache (negative means KB)
    this.busyTimeout = 5000, // 5 seconds
    this.autoVacuum = 'INCREMENTAL',
    this.recursiveTriggers = true,
    this.caseSensitiveLike = false,
    this.secureDelete = false,
    this.lockingMode = 'NORMAL',
    this.walAutoCheckpoint = 10000,
    this.journalSizeLimit = -2,
  });

  // 🧩 Factory + JSON serialization
  factory AcSqliteConfig.instanceFromJson({required Map<String, dynamic> jsonData}) {
    var instance = AcSqliteConfig();
    return instance.fromJson(jsonData: jsonData);
  }

  AcSqliteConfig fromJson({Map<String, dynamic> jsonData = const {}}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  @override
  String toString() => AcJsonUtils.prettyEncode(toJson());

  /// Generate the SQL PRAGMA statements for this configuration.
  List<String> toPragmaStatements() => [
    'PRAGMA foreign_keys = ${foreignKeys ? "ON" : "OFF"};',
    'PRAGMA journal_mode = $journalMode;',
    'PRAGMA synchronous = $synchronous;',
    'PRAGMA temp_store = $tempStore;',
    'PRAGMA cache_size = $cacheSize;',
    'PRAGMA busy_timeout = $busyTimeout;',
    'PRAGMA auto_vacuum = $autoVacuum;',
    'PRAGMA recursive_triggers = ${recursiveTriggers ? "ON" : "OFF"};',
    'PRAGMA case_sensitive_like = ${caseSensitiveLike ? "ON" : "OFF"};',
    'PRAGMA secure_delete = ${secureDelete ? "ON" : "OFF"};',
    'PRAGMA locking_mode = $lockingMode;',
    'PRAGMA wal_autocheckpoint = $walAutoCheckpoint;',
    'PRAGMA journal_size_limit = $journalSizeLimit;',
  ];
}