import 'dart:convert';
import 'package:ac_extensions/ac_extensions.dart';
import 'package:ac_web_on_ws/src/models/ac_web_on_ws_params.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_web/ac_web.dart';
import 'package:ac_web_socket/ac_web_socket.dart';

class AcWebOnWs {
  late AcWebSocket socket;
  late AcWeb app;
  final String eventName;
  
  final AcLogger logger = AcLogger(
    logMessages: true,
    logDirectory: 'logs',
    logType: AcEnumLogType.console,
    logFileName: 'ac-web-on-ws.log',
  );

  AcWebOnWs({required this.socket, required this.app, this.eventName = 'web_request'}) {
    _setupWsHandlers();
  }

  void _setupWsHandlers() {
    socket.on(event: eventName, handler: ({data, callback}) async {
      try {
        final requestData = data is String ? jsonDecode(data) : data as Map<String, dynamic>;

        bool continueOperation = true;

        if (continueOperation) {
          final method = (requestData['method'] ?? 'GET').toString().toLowerCase();
          final url = (requestData['url'] ?? '').toString();
          final cleanUrl = url.startsWith('/') ? url.substring(1) : url;

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
            if (callback != null) {
              final response = AcWebResponse.notFound();
              callback(response: _createWsResponseFromAcWebResponse(response));
            }
            return;
          }

          final acWebRequest = _createAcWebRequestFromWsData(requestData, socket);
          acWebRequest.pathParameters = pathParams;
          acWebRequest.internalParams['acWebOnWs'] = AcWebOnWsParams(socket: socket);

          final webResponse = await app.handleWebRequest(acWebRequest, routeDefinition);
          if (callback != null) {
            callback(response: _createWsResponseFromAcWebResponse(webResponse));
          }
        }
      } catch (e, stack) {
        logger.error("Error handling $eventName: $e");
        logger.error(stack);
        if (callback != null) {
          final response = AcWebResponse.internalError(data: e.toString());
          callback(response: _createWsResponseFromAcWebResponse(response));
        }
      }
    });
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

  AcWebRequest _createAcWebRequestFromWsData(Map<String, dynamic> data, AcWebSocket socket) {
    final request = AcWebRequest();
    request.method = (data['method'] ?? 'GET').toString().toUpperCase();
    request.url = (data['url'] ?? '').toString();
    if (request.url.startsWith('/')) {
      request.url = request.url.substring(1);
    }

    final headersMap = data['headers'];
    if (headersMap is Map) {
      headersMap.forEach((k, v) => request.headers[k.toString()] = v);
    }

    final queryMap = data['query'] ?? data['get'] ?? data['queryParams'];
    if (queryMap is Map) {
      queryMap.forEach((k, v) => request.get[k.toString()] = v);
    }

    final postMap = data['post'] ?? data['form'];
    if (postMap is Map) {
      postMap.forEach((k, v) => request.post[k.toString()] = v);
    }

    final body = data['body'] ?? data['data'];
    if (body != null) {
      if (body is Map<String, dynamic>) {
        request.body.addAll(body);
        if (request.post.isEmpty) request.post.addAll(body);
      } else if (body is String) {
        try {
          final decoded = jsonDecode(body);
          if (decoded is Map<String, dynamic>) request.body.addAll(decoded);
        } catch (_) {}
      }
    }

    final cookiesMap = data['cookies'];
    if (cookiesMap is Map) {
      cookiesMap.forEach((k, v) => request.cookies[k.toString()] = v);
    }

    final sessionMap = data['session'];
    if (sessionMap is Map) {
      sessionMap.forEach((k, v) => request.session[k.toString()] = v);
    }

    final filesMap = data['files'];
    if (filesMap is Map) {
      filesMap.forEach((k, v) {
        if (v is Map) {
          request.files[k.toString()] = AcWebFile.instanceFromJson(v.cast<String, dynamic>());
        }
      });
    }

    final pathMap = data['pathParameters'] ?? data['params'];
    if (pathMap is Map) {
      pathMap.forEach((k, v) => request.pathParameters[k.toString()] = v);
    }

    request.headers['x-socket-id'] = socket.id;
    request.headers['x-socket-nsp'] = socket.nsp;

    return request;
  }

  Map<String, dynamic> _createWsResponseFromAcWebResponse(AcWebResponse response) {
    return {
      'status': response.responseCode.value,
      'type': response.responseType.toString().split('.').last,
      'data': response.content,
      'headers': response.headers,
    };
  }
}
