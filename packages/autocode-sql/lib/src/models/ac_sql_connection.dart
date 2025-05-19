import 'dart:convert';
import 'package:autocode/autocode.dart';

class AcSqlConnection {
  static const String KEY_CONNECTION_PORT = 'port';
  static const String KEY_CONNECTION_HOSTNAME = 'hostname';
  static const String KEY_CONNECTION_USERNAME = 'username';
  static const String KEY_CONNECTION_PASSWORD = 'password';
  static const String KEY_CONNECTION_DATABASE = 'database';
  static const String KEY_CONNECTION_OPTIONS = 'options';

  int port = 0;
  String hostname = "";
  String username = "";
  String password = "";
  String database = "";
  List<dynamic> options = [];

  static AcSqlConnection instanceFromJson({required Map<String, dynamic> jsonData}) {
    var instance = AcSqlConnection();
    return instance.fromJson(jsonData: jsonData);
  }

  AcSqlConnection fromJson({Map<String, dynamic> jsonData = const {}}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  @override
  String toString() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }
}