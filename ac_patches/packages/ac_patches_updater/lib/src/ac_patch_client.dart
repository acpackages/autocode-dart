import 'dart:convert';
import 'dart:io';
import 'package:ac_patches_core/ac_patches_core.dart';
import 'package:http/http.dart' as http;

class AcPatchClient {
  final String serverUrl;
  final http.Client _httpClient;

  AcPatchClient({
    required String serverUrl,
    http.Client? httpClient,
  })  : serverUrl = serverUrl.endsWith('/')
            ? serverUrl.substring(0, serverUrl.length - 1)
            : serverUrl,
        _httpClient = httpClient ?? http.Client();

  /// Queries the server to check for an available patch.
  Future<AcPatchCheckResponse> checkForUpdate(AcPatchCheckRequest request) async {
    final uri = Uri.parse('$serverUrl/api/v1/patch/check');
    final response = await _httpClient.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return AcPatchCheckResponse.fromJson(json);
    } else {
      return AcPatchCheckResponse.noUpdate();
    }
  }

  /// Downloads the ACP1 patch archive from [downloadUrl] and saves it to [targetFile].
  Future<void> downloadPatch({
    required String downloadUrl,
    required File targetFile,
  }) async {
    final uri = Uri.parse(downloadUrl.startsWith('http') ? downloadUrl : '$serverUrl$downloadUrl');
    final response = await _httpClient.get(uri);

    if (response.statusCode == 200) {
      await targetFile.writeAsBytes(response.bodyBytes, flush: true);
    } else {
      throw HttpException('Failed to download patch: HTTP ${response.statusCode}');
    }
  }

  /// Reports a telemetry event to the server.
  Future<void> reportEvent(AcPatchReportRequest request) async {
    try {
      final uri = Uri.parse('$serverUrl/api/v1/patch/report');
      await _httpClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );
    } catch (_) {
      // Telemetry failures should never disrupt the application
    }
  }
}
