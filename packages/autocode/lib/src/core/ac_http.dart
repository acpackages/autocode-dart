import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../autocode.dart';

typedef AcHttpRequestInterceptor = ({String url,Map<String, dynamic>? queryParams,dynamic data,Map<String, String>? headers});

class AcHttp {
  String baseUrl = '';

  AcHttpRequestInterceptor Function({
  required String url,
  Map<String, dynamic>? queryParams,
  dynamic data,
  Map<String, String>? headers,
  })? requestInterceptor;

  final http.Client _client = http.Client();

  Future<AcHttpResult> request({
    required String url,
    AcEnumHttpMethod method = AcEnumHttpMethod.get,
    Map<String, dynamic>? queryParams,
    dynamic data,
    Map<String, String>? headers,
  }) async {
    final result = AcHttpResult();

    try {
      if (requestInterceptor != null) {
        final intercepted = requestInterceptor!(
          url: url,
          queryParams: queryParams,
          data: data,
          headers: headers,
        );

        url = intercepted.url;
        queryParams = intercepted.queryParams;
        data = intercepted.data;
        headers = intercepted.headers;
      }

      url = processUrl(
        url: url,
        queryParams: queryParams,
      );

      final hasFormData = method != AcEnumHttpMethod.get && method != AcEnumHttpMethod.delete && data != null;

      late http.Response httpResponse;

      if (hasFormData) {
        final multipartRequest = http.MultipartRequest(
          method.name.toUpperCase(),
          Uri.parse(url),
        );

        if (headers != null) {
          multipartRequest.headers.addAll(headers);
        }

        await convertObjectToFormData(
        request: multipartRequest,
        data: data,
        );

        final streamedResponse =
            await multipartRequest.send();

        httpResponse =
            await http.Response.fromStream(
          streamedResponse,
        );
      } else {
        switch (method) {
          case AcEnumHttpMethod.get:
            httpResponse = await _client.get(
              Uri.parse(url),
              headers: headers,
            );
            break;

          case AcEnumHttpMethod.delete:
            httpResponse = await _client.delete(
              Uri.parse(url),
              headers: headers,
            );
            break;

          case AcEnumHttpMethod.post:
            httpResponse = await _client.post(
              Uri.parse(url),
              headers: headers,
              body:data
            );
            break;

          default:
            throw Exception(
              'Unsupported request type',
            );
        }
      }

      result.responseCode = AcEnumHttpResponseCode.fromValue(httpResponse.statusCode)!;
      if(result.responseCode == AcEnumHttpResponseCode.ok){
        result.setSuccess();
      }
      try {
        result.data = jsonDecode(httpResponse.body);
      } catch (_) {
        result.data = httpResponse.body;
      }
    } catch (e,stack) {
      result.setException(exception: e,stackTrace: stack);
    }

    return result;
  }

  Future<AcHttpResult> get({
    required String url,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) {
    return request(
      url: url,
      method: AcEnumHttpMethod.get,
      queryParams: queryParams,
      headers: headers,
    );
  }

  Future<AcHttpResult> post({
    required String url,
    Map<String, dynamic>? queryParams,
    dynamic data,
    Map<String, String>? headers,
  }) {
    return request(
      url: url,
      method: AcEnumHttpMethod.post,
      queryParams: queryParams,
      data: data,
      headers: headers,
    );
  }

  Future<AcHttpResult> put({
    required String url,
    Map<String, dynamic>? queryParams,
    dynamic data,
    Map<String, String>? headers,
  }) {
    return request(
      url: url,
      method: AcEnumHttpMethod.put,
      queryParams: queryParams,
      data: data,
      headers: headers,
    );
  }

  Future<AcHttpResult> delete({
    required String url,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) {
    return request(
      url: url,
      method: AcEnumHttpMethod.delete,
      queryParams: queryParams,
      headers: headers,
    );
  }

  Future<void> convertObjectToFormData({
    required http.MultipartRequest request,
    required dynamic data,
    String? parentKey,
  }) async {
    if (data == null) {
      return;
    }

    if (data is Map) {
      for (final entry in data.entries) {
        final key = entry.key.toString();
        final value = entry.value;

        final formKey = parentKey != null
            ? '$parentKey[$key]'
            : key;

        final isFileType =
            value is File ||
                value is Uint8List ||
                value is http.MultipartFile;

        if ((value is Map || value is List) &&
            !isFileType &&
            value != null) {
          final isEmpty = value is Map
              ? value.isEmpty
              : (value as List).isEmpty;

          if (!isEmpty) {
            await convertObjectToFormData(
              request: request,
              data: value,
              parentKey: formKey,
            );
          } else {
            request.fields[formKey] = '';
          }
        } else {
          await _appendValue(
            request: request,
            key: formKey,
            value: value,
          );
        }
      }
    } else if (data is List) {
      for (int i = 0; i < data.length; i++) {
        final value = data[i];
        final formKey = '$parentKey[$i]';

        final isFileType =
            value is File ||
                value is Uint8List ||
                value is http.MultipartFile;

        if ((value is Map || value is List) &&
            !isFileType &&
            value != null) {
          final isEmpty = value is Map
              ? value.isEmpty
              : (value as List).isEmpty;

          if (!isEmpty) {
            await convertObjectToFormData(
              request: request,
              data: value,
              parentKey: formKey,
            );
          } else {
            request.fields[formKey] = '';
          }
        } else {
          await _appendValue(
            request: request,
            key: formKey,
            value: value,
          );
        }
      }
    }
  }

  Future<void> _appendValue({
    required http.MultipartRequest request,
    required String key,
    required dynamic value,
  }) async {
    if (value is File) {
      request.files.add(
        await http.MultipartFile.fromPath(
          key,
          value.path,
        ),
      );
    } else if (value is Uint8List) {
      request.files.add(
        http.MultipartFile.fromBytes(
          key,
          value,
        ),
      );
    } else if (value is http.MultipartFile) {
      request.files.add(value);
    } else {
      request.fields[key] =
      value != null ? value.toString() : '';
    }
  }

  String processUrl({
    required String url,
    Map<String, dynamic>? queryParams,
  }) {
    if (queryParams != null) {
      final queryParts = <String>[];

      queryParams.forEach((key, value) {
        queryParts.add('$key=$value');
      });

      if (queryParts.isNotEmpty) {
        if (!url.contains('?')) {
          url += '?';
        } else if (!url.endsWith('&') &&
            !url.endsWith('?')) {
          url += '&';
        }

        url += queryParts.join('&');
      }
    }

    if (baseUrl.isNotEmpty &&
        !url.startsWith('http')) {
      url = baseUrl + url;
    }

    return url;
  }

  Future<String> getFileContentAsBase64FromUrl({
    required String url,
  }) async {
    final response = await _client.get(
      Uri.parse(url),
    );

    return base64Encode(
      response.bodyBytes,
    );
  }
}