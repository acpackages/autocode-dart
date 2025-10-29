import 'dart:convert';
import 'dart:io';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

/* AcDoc({
  "summary": "Represents a deserialized incoming HTTP request.",
  "description": "This class encapsulates all the components of an HTTP request, including headers, path and query parameters, cookies, session data, and the request body. It is typically created by a web server framework from a raw request to provide a structured and easily accessible object.",
  "example": "// An AcWebRequest object is typically created by the server, not manually.\n// It might be used in a route handler like this:\n\nvoid handleUserRequest(AcWebRequest request) {\n  // Access path parameter: e.g., /users/{id}\n  final userId = request.pathParameters['id'];\n\n  // Access query parameter: e.g., /users?sort=asc\n  final sortBy = request.queryParameters['sort'];\n\n  // Access JSON body from a POST/PUT request\n  final userName = request.body['name'];\n\n  print('Fetching user \$userId, sorting by \$sortBy...');\n}"
}) */
@AcReflectable()
class AcWebFile {
  static const String keyCharset = 'charset';
  static const String keyContentText = 'contentText';
  static const String keyContentStream = 'contentStream';
  static const String keyFileName = 'filename';
  static const String keyMimeType = 'mimeType';

  @AcBindJsonProperty(key: keyCharset)
  String? charset;

  @AcBindJsonProperty(key: keyContentText)
  Stream<String>? contentText;

  @AcBindJsonProperty(key: keyContentStream)
  Stream<List<int>>? contentStream;

  @AcBindJsonProperty(key: keyFileName)
  String? fileName;

  @AcBindJsonProperty(key: keyMimeType)
  String? mimeType;

  AcWebFile();

  factory AcWebFile.instanceFromJson(Map<String, dynamic> jsonData) {
    final instance = AcWebFile();
    instance.fromJson(jsonData);
    return instance;
  }

  AcWebFile fromJson(Map<String, dynamic> jsonData) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
    return this;
  }

  void setContentType({required ContentType contentType}){
    charset = contentType.charset;
    mimeType = contentType.mimeType;
  }

  Future<AcResult<File>> writeTo({required String path,Encoding encoding = utf8}) async {
    AcResult<File> result = AcResult();
    try{
      File file=File(path);
      await file.create(recursive: true);
      if(contentText != null){
        IOSink sink = file.openWrite(encoding: encoding);
        await for (String item in contentText!) {
          sink.write(item);
        }
        await sink.flush();
        await sink.close();
      }
      else if(contentStream != null){
        IOSink sink = file.openWrite();
        await for (List<int> item in contentStream!) {
          sink.add(item);
        }
        await sink.flush();
        await sink.close();
      }
      result.setSuccess(value: file);
    }
    catch(ex,stack){
      result.setException(exception: ex,stackTrace: stack);
    }
    return result;
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
