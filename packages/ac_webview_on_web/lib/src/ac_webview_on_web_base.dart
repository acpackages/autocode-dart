import 'dart:async';
import 'dart:convert';
import 'package:ac_extensions/ac_extensions.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_web/ac_web.dart';
import 'package:ac_webview/ac_webview.dart';
import 'ac_webview_on_web_interceptor_result.dart';

class AcWebviewOnWeb {
  final AcWeb app;
  final AcWebview webview;
  final String actionName;
  Future<AcWebviewOnWebInterceptorResult> Function(AcWebviewOnWebInterceptorArgs args)? interceptor;
  final AcLogger logger = AcLogger(
    logMessages: true,
    logDirectory: 'logs',
    logType: AcEnumLogType.console,
    logFileName: 'ac-webview-on-web.log',
  );

  AcWebviewOnWeb({required this.webview,required this.app, this.actionName = 'webRequest', this.interceptor}) {
    webview.onAction(
      name: actionName,
      callback: (AcWebviewChannelAction channelAction) async {
        try {
          logger.log('[AcWebviewOnWeb]: Received message: $channelAction');
          Map<String,dynamic> requestData = channelAction.data!;
          bool continueOperation = true;
          bool waitingForResponse = false;
          if (interceptor != null) {
            logger.log('[AcWebviewOnWeb]: Calling interceptor...');
            void callbackFunction(Map<String,dynamic> actionResponse) {
              channelAction.response = actionResponse;
              waitingForResponse = false;
            }
            waitingForResponse = true;
            var interceptorResult = await interceptor!(AcWebviewOnWebInterceptorArgs(
              actionName: actionName,
              requestData: requestData,
              callback: callbackFunction,
            ));
            logger.log('[AcWebviewOnWeb]: Interceptor result: isSuccess=${interceptorResult.isSuccess()}, continueOperation=${interceptorResult.continueOperation}');

            if (interceptorResult.isSuccess()) {
              if (interceptorResult.continueOperation == false) {
                continueOperation = false;
              }
              else{
                waitingForResponse = false;
              }
            } else {
              waitingForResponse = false;
              continueOperation = false;
              channelAction.response = interceptorResult.toJson();
            }
          }

          if (continueOperation) {
            logger.log('[AcWebviewOnWeb]: Proceeding with request handling...');
            final method = (requestData['method'] ?? 'GET').toString().toLowerCase();
            final url = (requestData['url'] ?? '').toString();
            final cleanUrl = url.startsWith('/') ? url.substring(1) : url;

            // Find the route definition
            AcWebRouteDefinition? routeDefinition;
            Map<String, String> pathParams = {};

            for (var entry in app.routeDefinitions.values) {
              final routeMethod = entry.method.toLowerCase();
              final routePath = entry.url;
              final cleanRoutePath = routePath.startsWith('/') ? routePath.substring(1) : routePath;
              if (routeMethod.equalsIgnoreCase(method)) {
                if (cleanRoutePath == cleanUrl) {
                  routeDefinition = entry;
                  break;
                } else {
                  // Try pattern matching for path parameters
                  final extracted = _extractPathParams(cleanRoutePath, cleanUrl);
                  if (extracted != null) {
                    routeDefinition = entry;
                    pathParams = extracted;
                    break;
                  }
                }
              }
            }

            if (routeDefinition == null) {
              logger.error("Route not found: $method>$url");
              final response = AcWebResponse.notFound();
              channelAction.response = _createChannelResponseFromAcWebResponse(response);
            }
            else{
              logger.log("[AcWebviewOnWeb]: Creating web request");
              final acWebRequest = _createAcWebRequestFromChannelData(requestData);
              acWebRequest.pathParameters = pathParams;
              logger.log("[AcWebviewOnWeb]: Handling web request");
              final webResponse = await app.handleWebRequest(acWebRequest, routeDefinition);
              logger.log("[AcWebviewOnWeb]: Generating web response");
              channelAction.response = _createChannelResponseFromAcWebResponse(webResponse);
            }

          }

          while(waitingForResponse){
            logger.log("[AcWebviewOnWeb]: Waiting for operation to complete");
            await Future.delayed(Duration(microseconds: 500));
          }

        } catch (e, stack) {
          logger.error("Error handling message: $e");
          logger.error(stack);
          final response = AcWebResponse.internalError(data: e.toString());
          channelAction.response = _createChannelResponseFromAcWebResponse(response);
        }
        logger.log("[AcWebviewOnWeb]: Returning channel action");
        return channelAction;
      },
    );
  }

  Map<String, String>? _extractPathParams(String routePath, String uri) {
    try {
      final pattern = RegExp(
        '^' +
            RegExp.escape(routePath).replaceAllMapped(
              RegExp(r'\\\{(\w+)\\\}'),
              (m) => '(?<' + m[1]! + '>[^/]+)',
            ) +
            r'$',
      );
      final match = pattern.firstMatch(uri);
      if (match == null) return null;
      return {
        for (var name in match.groupNames) name: match.namedGroup(name) ?? '',
      };
    } catch (e) {
      return null;
    }
  }

  AcWebRequest _createAcWebRequestFromChannelData(Map<String, dynamic> data) {
    final request = AcWebRequest();
    request.method = (data['method'] ?? 'GET').toString().toUpperCase();
    request.url = (data['url'] ?? '').toString();
    if (request.url.startsWith('/')) {
      request.url = request.url.substring(1);
    }

    // Headers
    final headersMap = data['headers'];
    if (headersMap is Map) {
      headersMap.forEach((k, v) => request.headers[k.toString()] = v);
    }

    // Query Parameters (GET)
    final queryMap = data['query'] ?? data['get'] ?? data['queryParams'];
    if (queryMap is Map) {
      queryMap.forEach((k, v) => request.get[k.toString()] = v);
    }

    // Form Fields (POST)
    final postMap = data['post'] ?? data['form'];
    if (postMap is Map) {
      postMap.forEach((k, v) => request.post[k.toString()] = v);
    }

    // Body (JSON)
    final body = data['body'] ?? data['data'];
    if (body != null) {
      if (body is Map<String, dynamic>) {
        request.body.addAll(body);
        if (request.post.isEmpty) {
          request.post.addAll(body);
        }
      } else if (body is String) {
        try {
          final decoded = jsonDecode(body);
          if (decoded is Map<String, dynamic>) {
            request.body.addAll(decoded);
          }
        } catch (_) {}
      }
    }

    // Cookies
    final cookiesMap = data['cookies'];
    if (cookiesMap is Map) {
      cookiesMap.forEach((k, v) => request.cookies[k.toString()] = v);
    }

    // Session
    final sessionMap = data['session'];
    if (sessionMap is Map) {
      sessionMap.forEach((k, v) => request.session[k.toString()] = v);
    }

    // Files
    final filesMap = data['files'];
    if (filesMap is Map) {
      filesMap.forEach((k, v) {
        if (v is Map) {
          request.files[k.toString()] = AcWebFile.instanceFromJson(v.cast<String, dynamic>());
        }
      });
    }

    // Path Parameters (can be overridden by data)
    final pathMap = data['pathParameters'] ?? data['params'];
    if (pathMap is Map) {
      pathMap.forEach((k, v) => request.pathParameters[k.toString()] = v);
    }

    return request;
  }

  Map<String, dynamic> _createChannelResponseFromAcWebResponse(AcWebResponse response) {
    return {
      'status': response.responseCode.value,
      'type': response.responseType.toString().split('.').last,
      'data': response.content,
      'headers': response.headers,
    };
  }
}

class AcWebviewOnWebInterceptorArgs {
  final String actionName;
  final Map<String, dynamic> requestData;
  final Function callback;
  AcWebviewOnWebInterceptorArgs({required this.actionName, required this.requestData,required this.callback});
}
