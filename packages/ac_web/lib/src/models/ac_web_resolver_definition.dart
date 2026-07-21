import '../ac_web_internal.dart';
import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import '../api-docs/models/ac_api_doc_operation.dart';

/* AcDoc({
  "summary": "Represents the definition of a single web API route.",
  "description": "This class encapsulates all the necessary information to define an API endpoint, including its URL path, HTTP method, the controller and handler function that process requests, and its associated API documentation.",
  "example": "final userRoute = AcWebResolverDefinition()\n  ..url = '/api/users/{id}'\n  ..method = 'GET'\n  ..controller = UserController()\n  ..handler = (UserController c, AcWebRequest r) => c.getUserById(r)\n  ..documentation = AcApiDocRoute(summary: 'Gets a single user by their ID.');"
}) */
@AcReflectable()
class AcWebResolverDefinition {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyPrefix = 'controller';
  static const String keyResolver = 'resolver';
  static const String keyMethod = 'method';
  static const String keyInterceptors = 'interceptors';

  @AcBindJsonProperty(key: keyPrefix)
  String prefix = "";

  @AcBindJsonProperty(key: keyResolver)
  dynamic resolver;

  @AcBindJsonProperty(key: keyMethod)
  AcEnumHttpMethod method = AcEnumHttpMethod.get;

  @AcBindJsonProperty(key: keyInterceptors)
  List<String> interceptors = [];

  AcWebResolverDefinition({this.method = AcEnumHttpMethod.get,this.prefix = '',this.resolver,this.interceptors = const []}){}

  factory AcWebResolverDefinition.instanceFromJson(Map<String, dynamic> jsonData) {
    final instance = AcWebResolverDefinition();
    instance.fromJson(jsonData);
    return instance;
  }

  AcWebResolverDefinition fromJson(Map<String, dynamic> jsonData) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
    return this;
  }

  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  @override
  String toString() {
    // Standardized to use AcJsonUtils for consistency.
    return AcJsonUtils.prettyEncode(toJson());
  }
}