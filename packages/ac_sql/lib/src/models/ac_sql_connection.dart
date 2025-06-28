import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

/* AcDoc({
  "summary": "Represents the configuration for a database connection.",
  "description": "This class holds all the necessary parameters for establishing a connection to a database, such as hostname, port, credentials, the target database name, and any additional options.",
  "example": "final connectionConfig = AcSqlConnection(\n  hostname: 'localhost',\n  port: 3306,\n  username: 'dev_user',\n  password: 'password123',\n  database: 'my_app_db'\n);"
}) */
@AcReflectable()
class AcSqlConnection {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyPort = 'port';
  static const String keyHostname = 'hostname';
  static const String keyUsername = 'username';
  static const String keyPassword = 'password';
  static const String keyDatabase = 'database';
  static const String keyOptions = 'options';

  /* AcDoc({"summary": "The port number for the database connection."}) */
  @AcBindJsonProperty(key: keyPort)
  int port = 0;

  /* AcDoc({"summary": "The hostname or IP address of the database server."}) */
  @AcBindJsonProperty(key: keyHostname)
  String hostname = "";

  /* AcDoc({"summary": "The username for authenticating with the database."}) */
  @AcBindJsonProperty(key: keyUsername)
  String username = "";

  /* AcDoc({"summary": "The password for authenticating with the database."}) */
  @AcBindJsonProperty(key: keyPassword)
  String password = "";

  /* AcDoc({"summary": "The name of the specific database to connect to."}) */
  @AcBindJsonProperty(key: keyDatabase)
  String database = "";

  /* AcDoc({
    "summary": "A list of additional connection options.",
    "description": "Can hold any extra key-value pairs or flags required by the specific database driver."
  }) */
  @AcBindJsonProperty(key: keyOptions)
  List<dynamic> options = [];

  /* AcDoc({
    "summary": "Creates a database connection configuration.",
    "params": [
      {"name": "port", "description": "The connection port number."},
      {"name": "hostname", "description": "The server hostname or IP address."},
      {"name": "username", "description": "The authentication username."},
      {"name": "password", "description": "The authentication password."},
      {"name": "database", "description": "The name of the database."},
      {"name": "options", "description": "A list of additional options."}
    ]
  }) */
  AcSqlConnection({
    this.port = 0,
    this.hostname = "",
    this.username = "",
    this.password = "",
    this.database = "",
    this.options = const [],
  });

  /* AcDoc({
    "summary": "Creates a new AcSqlConnection instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the connection configuration."}
    ],
    "returns": "A new, populated AcSqlConnection instance.",
    "returns_type": "AcSqlConnection"
  }) */
  factory AcSqlConnection.instanceFromJson({required Map<String, dynamic> jsonData}) {
    var instance = AcSqlConnection();
    return instance.fromJson(jsonData: jsonData);
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "An instance method that uses reflection-based utilities to set the properties of this object from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the connection properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcSqlConnection"
  }) */
  AcSqlConnection fromJson({Map<String, dynamic> jsonData = const {}}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current connection configuration to a JSON map.",
    "returns": "A JSON map representation of the connection configuration.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the connection.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    // Standardized to use AcJsonUtils for consistency with other classes.
    return AcJsonUtils.prettyEncode(toJson());
  }
}
// import 'dart:convert';
// import 'package:ac_mirrors/ac_mirrors.dart';
// import 'package:autocode/autocode.dart';
// @AcReflectable()
// class AcSqlConnection {
//   static const String KEY_CONNECTION_PORT = 'port';
//   static const String KEY_CONNECTION_HOSTNAME = 'hostname';
//   static const String KEY_CONNECTION_USERNAME = 'username';
//   static const String KEY_CONNECTION_PASSWORD = 'password';
//   static const String KEY_CONNECTION_DATABASE = 'database';
//   static const String KEY_CONNECTION_OPTIONS = 'options';
//
//   int port = 0;
//   String hostname = "";
//   String username = "";
//   String password = "";
//   String database = "";
//   List<dynamic> options = [];
//
//   static AcSqlConnection instanceFromJson({required Map<String, dynamic> jsonData}) {
//     var instance = AcSqlConnection();
//     return instance.fromJson(jsonData: jsonData);
//   }
//
//   AcSqlConnection fromJson({Map<String, dynamic> jsonData = const {}}) {
//     AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
//     return this;
//   }
//
//   Map<String, dynamic> toJson() {
//     return AcJsonUtils.getJsonDataFromInstance(instance: this);
//   }
//
//   @override
//   String toString() {
//     return const JsonEncoder.withIndent('  ').convert(toJson());
//   }
// }