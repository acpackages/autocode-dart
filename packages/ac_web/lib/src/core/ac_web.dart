import 'dart:io';
import 'package:ac_mirrors/ac_mirrors.dart' as ac_mirrors;
import 'package:autocode/autocode.dart'; // Assume this contains your model classes
import 'package:ac_extensions/ac_extensions.dart';
import 'package:ac_web/ac_web.dart'; // Assume this contains request/response and other web classes

// Helper to convert a Symbol like `Symbol("myField")` to the string "myField".
String symbolToName(Symbol symbol) {
  return symbol.toString().split('"')[1];
}

class AcWeb {
  AcApiDoc acApiDoc;
  final Map<String, AcWebRouteDefinition> routeDefinitions = {};
  final List<Map<String, dynamic>> staticFilesRoutes = [];
  AcLogger logger = AcLogger(
    logMessages: true,
    logDirectory: 'logs/ac-web',
    logType: AcEnumLogType.CONSOLE,
    logFileName: 'ac-web.txt',
  );
  String urlPrefix = "";

  AcWeb({List<String> paths = const []}) : acApiDoc = AcApiDoc() {
    AcHooks.execute(hookName: AcEnumWebHook.AC_WEB_CREATED, args: [this]);
    get(
      url: '/swagger/swagger.json',
      handler: (AcWebRequest req) {
        var acApiSwagger = AcApiSwagger();
        acApiDoc.paths.clear();
        final paths = <String, AcApiDocPath>{};
        for (var routeDefinition in routeDefinitions.values) {
          var url = routeDefinition.url;
          if (!url.startsWith("/swagger/")) {
            paths.putIfAbsent(url, () {
              var pathObj = AcApiDocPath();
              pathObj.url = url;
              return pathObj;
            });

            var acApiDocPath = paths[url]!;
            var acApiDocRoute = routeDefinition.documentation;
            switch (routeDefinition.method.toUpperCase()) {
              case 'CONNECT': acApiDocPath.connect = acApiDocRoute; break;
              case 'DELETE': acApiDocPath.delete = acApiDocRoute; break;
              case 'GET': acApiDocPath.get = acApiDocRoute; break;
              case 'HEAD': acApiDocPath.head = acApiDocRoute; break;
              case 'OPTIONS': acApiDocPath.options = acApiDocRoute; break;
              case 'PATCH': acApiDocPath.patch = acApiDocRoute; break;
              case 'POST': acApiDocPath.post = acApiDocRoute; break;
              case 'PUT': acApiDocPath.put = acApiDocRoute; break;
              case 'TRACE': acApiDocPath.trace = acApiDocRoute; break;
            }
          }
        }

        acApiDoc.paths = paths.values.toList();
        acApiSwagger.acApiDoc = acApiDoc;
        return AcWebResponse.json(data: acApiSwagger.generateJson());
      },
    );
    for (var swaggerFileName in AcSwaggerResources.files.keys) {
      get(
        url: '/swagger$swaggerFileName',
        handler: (AcWebRequest req) {
          logger.log("Handling Swagger File : $swaggerFileName");
          var fileContent = AcSwaggerResources.files[swaggerFileName];
          String mimeType = AcFileUtils.getMimeTypeFromPath(swaggerFileName);
          logger.log("Handling Swagger File Mime : $mimeType");
          return AcWebResponse.raw(
            content: fileContent,
            headers: {'Content-Type': mimeType},
          );
        },
      );
    }
  }

  Map<String, String> _extractPathParams(String routePath, String uri) {
    final pattern = RegExp(
      '^' +
          RegExp.escape(routePath).replaceAllMapped(
            RegExp(r'\\\{(\w+)\\\}'),
                (m) => '(?<' + m[1]! + '>[^/]+)',
          ) +
          r'$',
    );
    final match = pattern.firstMatch(uri);
    if (match == null) return {};
    return {
      for (var name in match.groupNames) name: match.namedGroup(name) ?? '',
    };
  }

  /// Generates API documentation by reflecting on a controller method's parameters and metadata.
  AcApiDocRoute _getRouteDocFromMethodMirror({
    required ac_mirrors.AcMethodMirror methodMirror,
    AcApiDocRoute? acApiDocRoute,
  }) {
    acApiDocRoute ??= AcApiDocRoute();
    for (var param in methodMirror.parameters) {
      for (var meta in param.metadata) {
        var key = symbolToName(param.simpleName);
        if (meta is AcWebValueFromPath) {
          acApiDocRoute.addParameter(parameter: AcApiDocParameter(name: key, required: true, inValue: "path"));
        } else if (meta is AcWebValueFromQuery) {
          acApiDocRoute.addParameter(parameter: AcApiDocParameter(name: key, required: true, inValue: "query"));
        } else if (meta is AcWebValueFromBody) {
          var schema = AcApiDocUtils.getApiModelRefFromClass(type: param.type, acApiDoc: acApiDoc);
          var content = AcApiDocContent(encoding: "application/json", schema: schema);
          acApiDocRoute.requestBody = AcApiDocRequestBody()..addContent(content: content);
        }
      }
    }
    for (var meta in methodMirror.metadata) {
      if (meta is AcWebRouteMeta) {
        for (var tag in meta.tags) {
          acApiDocRoute.addTag(tag: tag);
        }
        if (meta.summary?.isNotEmpty ?? false) acApiDocRoute.summary = meta.summary!;
        if (meta.description?.isNotEmpty ?? false) acApiDocRoute.description = meta.description!;
      }
    }
    return acApiDocRoute;
  }

  bool _matchPath(String routePath, String uri) {
    final pattern = RegExp(
      '^' +
          RegExp.escape(routePath).replaceAllMapped(
            RegExp(r'\\\{(\w+)\\\}'),
                (m) => '(?<' + m[1]! + '>[^/]+)',
          ) +
          r'$',
    );
    return pattern.hasMatch(uri);
  }

  Future<AcWebResponse> handleWebRequest(
      AcWebRequest request,
      AcWebRouteDefinition routeDefinition,
      ) async {
    request.pathParameters = _extractPathParams(
      routeDefinition.url,
      request.url,
    );

    // Case 1: Handler is a method on a registered controller.
    if (routeDefinition.controller != null && routeDefinition.handler is String) {
      final controllerClassMirror = ac_mirrors.acReflectClass(routeDefinition.controller!);
      // Create a new instance of the controller for each request.
      final controllerInstance = controllerClassMirror.newInstance('', []);
      final controllerInstanceMirror = ac_mirrors.acReflect(controllerInstance);

      final methodName = Symbol(routeDefinition.handler as String);
      final methodMirror = controllerClassMirror.instanceMembers[methodName] as ac_mirrors.AcMethodMirror;

      final positionalArgs = <dynamic>[];
      final namedArgs = <Symbol, dynamic>{};

      for (final parameter in methodMirror.parameters) {
        dynamic argValue;
        bool valueSet = false;

        if (parameter.type == AcWebRequest) {
          argValue = request;
          valueSet = true;
        } else {
          for (final meta in parameter.metadata) {
            final key = symbolToName(parameter.simpleName);
            if (meta is AcWebValueFromPath && request.pathParameters.containsKey(key)) {
              argValue = request.pathParameters[key]; valueSet = true; break;
            } else if (meta is AcWebValueFromQuery && request.get.containsKey(key)) {
              argValue = request.get[key]; valueSet = true; break;
            } else if (meta is AcWebValueFromForm && request.post.containsKey(key)) {
              argValue = request.post[key]; valueSet = true; break;
            } else if (meta is AcWebValueFromHeader && request.headers.containsKey(key)) {
              argValue = request.headers[key]; valueSet = true; break;
            } else if (meta is AcWebValueFromCookie && request.cookies.containsKey(key)) {
              argValue = request.cookies[key]; valueSet = true; break;
            } else if (meta is AcWebValueFromBody) {
              final paramType = parameter.type;
              final object = ac_mirrors.acReflectClass(paramType).newInstance('', []);
              AcJsonUtils.setInstancePropertiesFromJsonData(instance: object, jsonData: request.body);
              argValue = object; valueSet = true; break;
            }
          }
        }
        if (!valueSet) {
          argValue = null;
        }
        if(parameter.isNamed){
          namedArgs[parameter.simpleName] = argValue;
        } else {
          positionalArgs.add(argValue);
        }
      }
      return await controllerInstanceMirror.invoke(methodName, positionalArgs, namedArgs);

    }
    // Case 2: Handler is a simple closure. Parameter injection is not supported.
    else if (routeDefinition.handler is Function) {
      try {
        return await (routeDefinition.handler as Function)(request);
      } catch (e) {
        return AcWebResponse.internalError(data: e.toString());
      }
    }

    return AcWebResponse.notFound();
  }

  /// Registers a controller, reflecting on its methods to create routes.
  /// This is the recommended way to define routes for automatic documentation.
  AcWeb registerController({required Type controllerClass}) {
    final classMirror = ac_mirrors.acReflectClass(controllerClass);
    String classRoute = '';

    for (var meta in classMirror.metadata) {
      if (meta is AcWebRoute) {
        classRoute = meta.path.trimRight();
      }
    }

    for (var member in classMirror.instanceMembers.values) {
      if (member is! ac_mirrors.AcMethodMirror) continue;

      for (var meta in member.metadata) {
        if (meta is AcWebRoute) {
          final fullPath = '$classRoute/${meta.path.trim()}'.replaceAll('//', '/');
          final httpMethod = meta.method.toLowerCase();
          final routeKey = '$httpMethod>$fullPath';

          final acApiDocRoute = _getRouteDocFromMethodMirror(methodMirror: member);

          routeDefinitions[routeKey] = AcWebRouteDefinition.instanceFromJson({
            'url': fullPath,
            'method': httpMethod,
            'controller': controllerClass,
            'handler': symbolToName(member.simpleName),
            'documentation': acApiDocRoute,
          });
        }
      }
    }
    return this;
  }

  /// Generic route registration. For handlers that are closures, `acApiDocRoute`
  /// should be provided manually for documentation.
  AcWeb route({
    required String url,
    required Function handler,
    required String method,
    AcApiDocRoute? acApiDocRoute,
  }) {
    var routeKey = '${method.toLowerCase()}>$url';
    // Reflection on arbitrary closures is not supported for doc generation.
    // Provide the documentation object manually.
    routeDefinitions[routeKey] = AcWebRouteDefinition.instanceFromJson({
      AcWebRouteDefinition.KEY_URL: url,
      AcWebRouteDefinition.KEY_METHOD: method.toLowerCase(),
      AcWebRouteDefinition.KEY_HANDLER: handler,
      AcWebRouteDefinition.KEY_DOCUMENTATION: acApiDocRoute ?? AcApiDocRoute(),
    });
    return this;
  }

  // --- Standard HTTP method helpers ---
  AcWeb addHostUrl({required String url}) {
    acApiDoc.addServer(server: AcApiDocServer(url: url));
    return this;
  }
  AcWeb connect({required String url, required Function handler, AcApiDocRoute? acApiDocRoute}) => route(url: url, handler: handler, method: 'CONNECT', acApiDocRoute: acApiDocRoute);
  AcWeb delete({required String url, required Function handler, AcApiDocRoute? acApiDocRoute}) => route(url: url, handler: handler, method: 'DELETE', acApiDocRoute: acApiDocRoute);
  AcWeb get({required String url, required Function handler, AcApiDocRoute? acApiDocRoute}) => route(url: url, handler: handler, method: 'GET', acApiDocRoute: acApiDocRoute);
  AcWeb head({required String url, required Function handler, AcApiDocRoute? acApiDocRoute}) => route(url: url, handler: handler, method: 'HEAD', acApiDocRoute: acApiDocRoute);
  AcWeb options({required String url, required Function handler, AcApiDocRoute? acApiDocRoute}) => route(url: url, handler: handler, method: 'OPTIONS', acApiDocRoute: acApiDocRoute);
  AcWeb patch({required String url, required Function handler, AcApiDocRoute? acApiDocRoute}) => route(url: url, handler: handler, method: 'PATCH', acApiDocRoute: acApiDocRoute);
  AcWeb post({required String url, required Function handler, AcApiDocRoute? acApiDocRoute}) => route(url: url, handler: handler, method: 'POST', acApiDocRoute: acApiDocRoute);
  AcWeb put({required String url, required Function handler, AcApiDocRoute? acApiDocRoute}) => route(url: url, handler: handler, method: 'PUT', acApiDocRoute: acApiDocRoute);
  AcWeb trace({required String url, required Function handler, AcApiDocRoute? acApiDocRoute}) => route(url: url, handler: handler, method: 'TRACE', acApiDocRoute: acApiDocRoute);

  AcWeb staticFiles({required String directory, required String prefix}) {
    // Logic for serving static files would go here.
    return this;
  }
}
