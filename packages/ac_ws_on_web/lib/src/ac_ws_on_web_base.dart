import 'dart:async';
import 'dart:convert';
import 'package:ac_extensions/ac_extensions.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_web/ac_web.dart';
import 'package:ac_ws_server/ac_ws_server.dart';

class AcWsOnWeb {
  final AcWsSocket socket;
  final AcWeb app;
  final String eventName;
  final AcLogger logger = AcLogger(
    logMessages: true,
    logDirectory: 'logs',
    logType: AcEnumLogType.console,
    logFileName: 'ac-ws-on-web.log',
  );

  AcWsOnWeb(this.socket, this.app, {this.eventName = 'web_request'}) {
    _setupWsHandlers();
  }

  void _setupWsHandlers() {
    this.socket.on(eventName, (data, [ack]) async {
      print("Handling $eventName from socket ${socket.id}: $data");
      logger.log("Handling $eventName from socket ${socket.id}: $data");
      try {
        final requestData = data is String ? jsonDecode(data) : data as Map<String, dynamic>;
        print(data);
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
          if (ack != null) {
            final response = AcWebResponse.notFound();
            ack(_createWsResponseFromAcWebResponse(response));
          }
          return;
        }

        final acWebRequest = _createAcWebRequestFromWsData(requestData, socket);
        acWebRequest.pathParameters = pathParams;

        final webResponse = await app.handleWebRequest(acWebRequest, routeDefinition);

        if (ack != null) {
          ack(_createWsResponseFromAcWebResponse(webResponse));
        }
      } catch (e, stack) {
        logger.error("Error handling $eventName: $e");
        logger.error(stack);
        if (ack != null) {
          final response = AcWebResponse.internalError(data: e.toString());
          ack(_createWsResponseFromAcWebResponse(response));
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

  AcWebRequest _createAcWebRequestFromWsData(Map<String, dynamic> data, AcWsSocket socket) {
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
        // If post is empty, populate it from body as well for compatibility
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

    // Pass socket info as extra data
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
