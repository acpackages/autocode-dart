/* AcDoc({
  "description": "Manages the current runtime environment and configuration settings.",
  "author": "Sanket Patel",
  "type": "utility"
}) */
import 'dart:convert';
import 'dart:io';

import 'package:autocode/autocode.dart';

class AcEnvironment {
  /* AcDoc({
    "description": "Defines the current application environment. Default is 'local'."
  }) */

  static String envFilePath = "_env.json";


  static AcEnumEnvironment environment = AcEnumEnvironment.local;

  /* AcDoc({
    "description": "Stores configuration values for the current environment."
  }) */
  static Map<String, dynamic> config = {};

  /* AcDoc({
    "description": "Checks if the environment is 'development'.",
    "returns": "True if environment is development, false otherwise."
  }) */
  static bool isDevelopment() => environment == AcEnumEnvironment.development;

  /* AcDoc({
    "description": "Checks if the environment is 'local'.",
    "returns": "True if environment is local, false otherwise."
  }) */
  static bool isLocal() => environment == AcEnumEnvironment.local;

  /* AcDoc({
    "description": "Checks if the environment is 'production'.",
    "returns": "True if environment is production, false otherwise."
  }) */
  static bool isProduction() => environment == AcEnumEnvironment.production;

  /* AcDoc({
    "description": "Checks if the environment is 'staging'.",
    "returns": "True if environment is staging, false otherwise."
  }) */
  static bool isStaging() => environment == AcEnumEnvironment.staging;

  static init({AcEnumEnvironment? environment,Map<AcEnumEnvironment,dynamic> configs = const {}}) async{
    if(environment != null){
      AcEnvironment.environment=environment;
    }
    if(configs.containsKey(environment)){
      AcEnvironment.config=configs[environment];
    }
    await _initFromJsonFile();
  }

  static _initFromJsonFile() async{
    File envFile = File(envFilePath);
    if(envFile.existsSync()){
      String envJsonString = envFile.readAsStringSync();
      try {
        Map<String,dynamic> configJson = jsonDecode(envJsonString);
        AcEnvironment.config = configJson;
      }
      catch(ex){
        //
      }
    }
  }
}
