import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:ac_sql/ac_sql.dart';
import 'package:ac_web/ac_web.dart';
import 'package:autocode/autocode.dart'; // Assuming your Dart package imports

/* AcDoc({
  "summary": "Represents a standardized response from a web API.",
  "description": "This class extends `AcResult` to provide a standard structure for API responses. While it adds no new properties of its own, it serves as a specific type to encapsulate the success state, message, and data payload returned by an API endpoint. This ensures consistency across all web API calls.",
  "example": "Future<AcWebApiResponse> fetchUserData(int userId) async {\n  final response = AcWebApiResponse();\n  try {\n    // ... fetch user data from a service ...\n    final user = await userApiService.fetch(userId);\n    response.setSuccess(value: user.toJson(), message: 'User found.');\n  } catch (e) {\n    response.setFailure(message: 'User not found or an error occurred.');\n  }\n  return response;\n}"
}) */
@AcReflectable()
class AcWebApiResponse extends AcResult {
  static const String keyData = 'data';

  dynamic data;
  /* AcDoc({
    "summary": "Creates a new instance of a web API response.",
    "description": "Initializes an empty response object, which can then be populated with success or failure details using methods inherited from `AcResult`."
  }) */
  AcWebApiResponse();

  AcWebResponse toWebResponse() {
    return AcWebResponse.json(data: this.toJson());
  }

  AcWebApiResponse setFromSqlDaoResult({
    required AcSqlDaoResult result,
    String? message,
    AcLogger? logger,
  }) {
    setFromResult(result: result,message: message,logger: logger);
    Map<String,dynamic> sqlData = {};
    sqlData["rows"] = result.rows;
    if(result.affectedRowsCount!=null && result.affectedRowsCount! > 0){
      sqlData["affectedRowsCount"] = result.affectedRowsCount;
    }
    if(result.lastInsertedId!=null && result.lastInsertedId! > 0){
      sqlData["lastInsertedId"] = result.lastInsertedId;
    }
    if(result.totalRows > 0){
      sqlData["totalRows"] = result.totalRows;
    }
    data = sqlData;
    return this;
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String,dynamic> result = AcJsonUtils.getJsonDataFromInstance(instance: this);
    if(result.containsKey(AcResult.keyLog) && log.isEmpty){
      result.remove(AcResult.keyLog);
    }
    if(result.containsKey(AcResult.keyOtherDetails) && otherDetails.isEmpty){
      result.remove(AcResult.keyOtherDetails);
    }
    return result;
  }
}