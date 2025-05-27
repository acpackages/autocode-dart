import 'dart:io';
import 'dart:mirrors';
import 'package:autocode/autocode.dart';
import 'package:autocode_extensions/autocode_extensions.dart';
import 'package:autocode_web/autocode_web.dart';

class AcWeb {
  AcApiDoc acApiDoc;
  final Map<String, AcWebRouteDefinition> routeDefinitions = {};
  final List<Map<String, dynamic>> staticFilesRoutes = [];
  AcLogger logger = AcLogger(logMessages: true, logDirectory: 'logs/ac-web',logType: AcEnumLogType.CONSOLE,logFileName: 'ac-web.txt');
  String urlPrefix = "";

  AcWeb({List<String> paths = const []}) : acApiDoc = AcApiDoc() {
    AcHooks.execute(hookName:AcEnumWebHook.AC_WEB_CREATED,args: [this]);
    get(url:'/swagger/swagger.json', handler:(AcWebRequest req) {
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

      acApiDoc.paths = paths.values.toList();
      acApiSwagger.acApiDoc = acApiDoc;
      return AcWebResponse.json(data:acApiSwagger.generateJson());
    });
    for(var swaggerFileName in AcSwaggerResources.files.keys){
      get(url:'/swagger$swaggerFileName', handler:(AcWebRequest req) {
        logger.log("Handling Swagger File : $swaggerFileName");
        var fileContent =  AcSwaggerResources.files[swaggerFileName];
        String mimeType = AcFileUtils.getMimeTypeFromPath(swaggerFileName);
        logger.log("Handling Swagger File Mime : $mimeType");
        return AcWebResponse.raw(content: fileContent,headers: {'Content-Type':mimeType});
      });
    }
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

  AcApiDocRoute _getRouteDocFromHandlerReflection({
    required Function handler,
    AcApiDocRoute? acApiDocRoute,
  }) {
    acApiDocRoute ??= AcApiDocRoute();
    ClosureMirror closureMirror = reflect(handler) as ClosureMirror;
    MethodMirror functionMirror = closureMirror.function;
    for (var param in functionMirror.parameters) {
      var metadata = param.metadata;

      for (var meta in metadata) {
        var instance = meta.reflectee;
        var key = param.simpleName.toString();

        if (instance is AcWebValueFromPath) {
          var parameter = AcApiDocParameter();
          parameter.name = key;
          parameter.required = true;
          parameter.inValue = "path";
          acApiDocRoute.addParameter(parameter: parameter);
        } else if (instance is AcWebValueFromQuery) {
          var parameter = AcApiDocParameter();
          parameter.name = key;
          parameter.required = true;
          parameter.inValue = "query";
          acApiDocRoute.addParameter(parameter: parameter);
        } else if (instance is AcWebValueFromForm) {
          // Empty block as in original logic
        } else if (instance is AcWebValueFromBody) {
          var typeMirror = param.type;
          var typeName = MirrorSystem.getName(typeMirror.simpleName);

          var schema = AcApiDocUtils.getApiModelRefFromClass(
            type: typeMirror.reflectedType,
            acApiDoc: acApiDoc,
          );
          var content = AcApiDocContent();
          content.encoding = "application/json";
          content.schema = schema;

          var requestBody = AcApiDocRequestBody();
          requestBody.addContent(content: content);

          acApiDocRoute.requestBody = requestBody;
        } else if (instance is AcWebRouteMeta) {
          for (var tag in instance.tags) {
            acApiDocRoute.addTag(tag: tag);
          }
          if (instance.summary?.isNotEmpty ?? false) {
            acApiDocRoute.summary = instance.summary!;
          }
          if (instance.description?.isNotEmpty ?? false) {
            acApiDocRoute.description = instance.description!;
          }
        }
      }
    }
    return acApiDocRoute;
  }

  bool _matchPath(String routePath, String uri) {
    final pattern = RegExp('^' +
        RegExp.escape(routePath)
            .replaceAllMapped(RegExp(r'\\\{(\w+)\\\}'), (m) => '(?<' + m[1]! + '>[^/]+)') +
        r'$');
    return pattern.hasMatch(uri);
  }

  AcWeb addHostUrl({required String url}) {
    var server = AcApiDocServer();
    server.url = url;
    acApiDoc.addServer(server: server);
    return this;
  }

  AcWeb connect({required String url,required Function handler, AcApiDocRoute? acApiDocRoute}) =>
      route(url:url, handler:handler, method: 'CONNECT', acApiDocRoute:acApiDocRoute);

  AcWeb delete({required String url, required Function handler, AcApiDocRoute? acApiDocRoute}) =>
      route(url:url, handler:handler, method: 'DELETE', acApiDocRoute:acApiDocRoute);

  AcWeb get({required String url, required Function handler, AcApiDocRoute? acApiDocRoute}) =>
      route(url:url, handler:handler, method: 'GET', acApiDocRoute:acApiDocRoute);

  Future<AcWebResponse> handleWebRequest(AcWebRequest request,AcWebRouteDefinition routeDefinition) async {
    AcWebResponse webResponse = AcWebResponse.notFound();
    ClosureMirror? method;
    final args = <dynamic>[];
    request.pathParameters = _extractPathParams(routeDefinition.url, request.url);
    ClosureMirror closureMirror = reflect(routeDefinition.handler) as ClosureMirror;
    MethodMirror functionMirror = closureMirror.function;
    for (final parameter in functionMirror.parameters) {
      var valueSet = false;
      final paramName = MirrorSystem.getName(parameter.simpleName);
      if (parameter.type.reflectedType == AcWebRequest) {
        args.add(request);
        valueSet = true;
      } else {
        for (var meta in parameter.metadata) {
          final instance = meta.reflectee;
          final key = paramName;
          if (instance is AcWebValueFromPath && request.pathParameters.containsKey(key)) {
            args.add(request.pathParameters[key]);
            valueSet = true;
          } else if (instance is AcWebValueFromQuery && request.get.containsKey(key)) {
            args.add(request.get[key]);
            valueSet = true;
          } else if (instance is AcWebValueFromForm && request.post.containsKey(key)) {
            args.add(request.post[key]);
            valueSet = true;
          } else if (instance is AcWebValueFromHeader && request.headers.containsKey(key)) {
            args.add(request.headers[key]);
            valueSet = true;
          } else if (instance is AcWebValueFromCookie && request.cookies.containsKey(key)) {
            args.add(request.cookies[key]);
            valueSet = true;
          } else if (instance is AcWebValueFromBody) {
            final paramType = parameter.type.reflectedType;
            final object = reflectClass(paramType).newInstance(Symbol(''), []);
            AcJsonUtils.setInstancePropertiesFromJsonData(
                instance: object, jsonData: request.body);
            args.add(object);
            valueSet = true;
          }
        }
      }

      if (!valueSet) {
        args.add(null); // Dart has no default value reflection
      }
    }
    if (routeDefinition.controller != null) {
      var controllerMirror = reflectClass(routeDefinition.controller!).newInstance(Symbol(''), []);
      var methodMirror = controllerMirror.type.instanceMembers[Symbol(routeDefinition.handler)]!;
      // webResponse = controllerMirror.invoke(Symbol(routeDefinition.handler), args).;
    } else {
      var closureMirror = reflect(routeDefinition.handler) as ClosureMirror;
      webResponse = await Function.apply(routeDefinition.handler, args);
    }
    return webResponse;
  }

  AcWeb head({required String url, required Function handler, AcApiDocRoute? acApiDocRoute}) =>
      route(url:url, handler:handler, method: 'HEAD', acApiDocRoute:acApiDocRoute);

  AcWeb options({required String url, required Function handler, AcApiDocRoute? acApiDocRoute}) =>
      route(url:url, handler:handler, method: 'OPTIONS', acApiDocRoute:acApiDocRoute);

  AcWeb patch({required String url, required Function handler, AcApiDocRoute? acApiDocRoute}) =>
      route(url:url, handler:handler, method: 'PATCH', acApiDocRoute:acApiDocRoute);

  AcWeb post({required String url, required Function handler, AcApiDocRoute? acApiDocRoute}) =>
      route(url:url, handler:handler, method: 'POST', acApiDocRoute:acApiDocRoute);

  AcWeb put({required String url, required Function handler, AcApiDocRoute? acApiDocRoute}) =>
      route(url:url, handler:handler, method: 'PUT', acApiDocRoute:acApiDocRoute);

  AcWeb registerController({required Type controllerClass}) {
    // var controllerInstance = _instantiate(controllerClass);
    // var classRoute = '';
    //
    // var classAnnotations = AcWebAnnotations.getAnnotations(controllerClass);
    // for (var attr in classAnnotations) {
    //   if (attr is AcWebRoute) {
    //     classRoute = attr.path.trimRight('/');
    //   }
    // }
    //
    // var methods = AcWebAnnotations.getMethods(controllerClass);
    //
    // for (var method in methods) {
    //   var routeAttrs = AcWebAnnotations.getMethodAnnotations(controllerClass, method);
    //   for (var attr in routeAttrs) {
    //     if (attr is AcWebRoute) {
    //       var fullPath = '$classRoute/${attr.path.trim()}';
    //       var httpMethod = attr.method.toLowerCase();
    //       var routeKey = '$httpMethod>$fullPath';
    //       var acApiDocRoute = _getRouteDocFromHandler(controllerClass, method, null);
    //       _routeDefinitions[routeKey] = AcWebRouteDefinition.instanceFromJson({
    //         AcWebRouteDefinition.KEY_URL: fullPath,
    //         AcWebRouteDefinition.KEY_METHOD: httpMethod,
    //         AcWebRouteDefinition.KEY_CONTROLLER: controllerClass,
    //         AcWebRouteDefinition.KEY_HANDLER: method,
    //         AcWebRouteDefinition.KEY_DOCUMENTATION: acApiDocRoute,
    //       });
    //     }
    //   }
    // }

    return this;
  }

  AcWeb route({required String url,required Function handler,required String method, AcApiDocRoute? acApiDocRoute}) {
    var routeKey = '${method.toLowerCase()}>$url';
    var acDocRoute = acApiDocRoute ?? _getRouteDocFromHandlerReflection(handler:handler,acApiDocRoute: null);
    routeDefinitions[routeKey] = AcWebRouteDefinition.instanceFromJson({
      AcWebRouteDefinition.KEY_URL: url,
      AcWebRouteDefinition.KEY_METHOD: method.toLowerCase(),
      AcWebRouteDefinition.KEY_HANDLER: handler,
      AcWebRouteDefinition.KEY_DOCUMENTATION: acDocRoute,
    });
    return this;
  }

  AcWeb staticFiles({required String directory, required String prefix}) {
    // _staticFiles.add({'directory': p.normalize(baseDir), 'prefix': prefix});
    return this;
  }

}
