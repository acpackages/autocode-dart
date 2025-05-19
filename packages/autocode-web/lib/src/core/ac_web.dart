import 'dart:io';

import 'package:autocode/autocode.dart';
import 'package:autocode_web/autocode_web.dart';

class AcWeb {
  AcApiDoc acApiDoc;
  final Map<String, AcWebRouteDefinition> _routeDefinitions = {};
  final List<Map<String, dynamic>> _staticFiles = [];
  String urlPrefix = "";

  AcWeb({List<String> paths = const []}) : acApiDoc = AcApiDoc() {
    var hookArgs = AcWebHookCreatedArgs(acWeb: this);
    AcHooks.execute(hookName:AcEnumWebHook.AC_WEB_CREATED,args: [this]);
    staticFiles('./../ApiDocs/Swagger/SwaggerUI', 'swagger');
    get('/swagger/swagger.json', (AcWebRequest req) {
      var acApiSwagger = AcApiSwagger();
      acApiDoc.paths.clear();

      final paths = <String, AcApiDocPath>{};

      for (var routeDefinition in _routeDefinitions.values) {
        var url = routeDefinition.url;
        if (url != '/swagger/swagger.json') {
          paths.putIfAbsent(url, () {
            var pathObj = AcApiDocPath();
            pathObj.url = url;
            return pathObj;
          });

          var acApiDocPath = paths[url]!;
          var acApiDocRoute = routeDefinition.documentation;
          switch (routeDefinition.method.toUpperCase()) {
            case 'CONNECT':
              acApiDocPath.connect = acApiDocRoute;
              break;
            case 'DELETE':
              acApiDocPath.delete = acApiDocRoute;
              break;
            case 'GET':
              acApiDocPath.get = acApiDocRoute;
              break;
            case 'HEAD':
              acApiDocPath.head = acApiDocRoute;
              break;
            case 'OPTIONS':
              acApiDocPath.options = acApiDocRoute;
              break;
            case 'PATCH':
              acApiDocPath.patch = acApiDocRoute;
              break;
            case 'POST':
              acApiDocPath.post = acApiDocRoute;
              break;
            case 'PUT':
              acApiDocPath.put = acApiDocRoute;
              break;
            case 'TRACE':
              acApiDocPath.trace = acApiDocRoute;
              break;
          }
        }
      }

      acApiDoc.paths = paths;
      acApiSwagger.acApiDoc = acApiDoc;
      return AcWebResponse.json(acApiSwagger.generateJson());
    });
  }

  AcWeb addHostUrl({required String url}) {
    var server = AcApiDocServer();
    server.url = url;
    acApiDoc.addServer(server: server);
    return this;
  }

  AcWeb connect({required String url,required dynamic handler, AcApiDocRoute? acApiDocRoute}) =>
      route(url, handler, 'CONNECT', acApiDocRoute);

  AcWeb delete({required String url, required dynamic handler, AcApiDocRoute? acApiDocRoute}) =>
      route(url, handler, 'DELETE', acApiDocRoute);

  AcWeb get({required String url, required dynamic handler, AcApiDocRoute? acApiDocRoute}) =>
      route(url, handler, 'GET', acApiDocRoute);

  AcWeb head({required String url, required dynamic handler, AcApiDocRoute? acApiDocRoute}) =>
      route(url, handler, 'HEAD', acApiDocRoute);

  AcWeb options({required String url, required dynamic handler, AcApiDocRoute? acApiDocRoute}) =>
      route(url, handler, 'OPTIONS', acApiDocRoute);

  AcWeb patch({required String url, required dynamic handler, AcApiDocRoute? acApiDocRoute}) =>
      route(url, handler, 'PATCH', acApiDocRoute);

  AcWeb post({required String url, required dynamic handler, AcApiDocRoute? acApiDocRoute}) =>
      route(url, handler, 'POST', acApiDocRoute);

  AcWeb put({required String url, required dynamic handler, AcApiDocRoute? acApiDocRoute}) =>
      route(url, handler, 'PUT', acApiDocRoute);

  // Register controller class by reflection-like introspection (via mirrors or metadata)
  AcWeb registerController({required Type controllerClass}) {
    var controllerInstance = _instantiate(controllerClass);
    var classRoute = '';

    var classAnnotations = AcWebAnnotations.getAnnotations(controllerClass);
    for (var attr in classAnnotations) {
      if (attr is AcWebRoute) {
        classRoute = attr.path.trimRight('/');
      }
    }

    var methods = AcWebAnnotations.getMethods(controllerClass);

    for (var method in methods) {
      var routeAttrs = AcWebAnnotations.getMethodAnnotations(controllerClass, method);
      for (var attr in routeAttrs) {
        if (attr is AcWebRoute) {
          var fullPath = '$classRoute/${attr.path.trim()}';
          var httpMethod = attr.method.toLowerCase();
          var routeKey = '$httpMethod>$fullPath';
          var acApiDocRoute = _getRouteDocFromHandler(controllerClass, method, null);
          _routeDefinitions[routeKey] = AcWebRouteDefinition.instanceFromJson({
            AcWebRouteDefinition.KEY_URL: fullPath,
            AcWebRouteDefinition.KEY_METHOD: httpMethod,
            AcWebRouteDefinition.KEY_CONTROLLER: controllerClass,
            AcWebRouteDefinition.KEY_HANDLER: method,
            AcWebRouteDefinition.KEY_DOCUMENTATION: acApiDocRoute,
          });
        }
      }
    }

    return this;
  }

  AcWeb route({required String url,required dynamic handler,required String method, AcApiDocRoute? acApiDocRoute}) {
    var routeKey = '${method.toLowerCase()}>' + url;
    var acDocRoute = acApiDocRoute ?? _getRouteDocFromHandler(null, null, handler);
    _routeDefinitions[routeKey] = AcWebRouteDefinition.instanceFromJson({
      AcWebRouteDefinition.KEY_URL: url,
      AcWebRouteDefinition.KEY_METHOD: method.toLowerCase(),
      AcWebRouteDefinition.KEY_HANDLER: handler,
      AcWebRouteDefinition.KEY_DOCUMENTATION: acDocRoute,
    });
    return this;
  }

  AcWebResponse serve() {
    var request = AcWebRequest();
    var uri = Uri.parse(HttpRequest.uri.toString());
    var path = uri.path;

    if (path.startsWith(urlPrefix)) {
      path = path.substring(urlPrefix.length);
    }
    request.url = path;
    request.method = HttpRequest.method.toLowerCase();
    request.headers = HttpRequest.headers;
    request.get = uri.queryParameters;
    // In Dart, to read POST body, you'd do async, here simplified:
    // request.post = ... parse form data or json body
    request.cookies = HttpRequest.cookies;
    request.body = {}; // parse JSON body async in real code

    // Find route handler
    var routeKey = '${request.method}>$path';
    AcWebRouteDefinition? routeDefinition = _routeDefinitions[routeKey];

    if (routeDefinition == null) {
      for (var route in _routeDefinitions.values) {
        if (route.method == request.method && _matchPath(route.url, path)) {
          routeDefinition = route;
          break;
        }
      }
    }

    if (routeDefinition == null) {
      return AcWebResponse.notFound();
    }

    var pathParams = _extractPathParams(routeDefinition.url, path);
    // Call the handler with parameters (in Dart, you'd invoke function with reflection or known signature)
    // Simplified example here:
    var response = routeDefinition.invokeHandler(request, pathParams);

    return response;
  }

  AcWeb staticFiles({required String directory, required String prefix}) {
    _staticFiles.add({'directory': p.normalize(baseDir), 'prefix': prefix});
    return this;
  }

  bool _matchPath(String routePath, String uri) {
    final pattern = RegExp('^' +
        RegExp.escape(routePath)
            .replaceAllMapped(RegExp(r'\\\{(\w+)\\\}'), (m) => '(?<' + m[1]! + '>[^/]+)') +
        r'$');
    return pattern.hasMatch(uri);
  }

  Map<String, String> _extractPathParams(String routePath, String uri) {
    final pattern = RegExp('^' +
        RegExp.escape(routePath)
            .replaceAllMapped(RegExp(r'\\\{(\w+)\\\}'), (m) => '(?<' + m[1]! + '>[^/]+)') +
        r'$');
    final match = pattern.firstMatch(uri);
    if (match == null) return {};
    return {
      for (var name in match.groupNames) name: match.namedGroup(name) ?? '',
    };
  }
}
