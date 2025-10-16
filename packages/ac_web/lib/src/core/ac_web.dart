import 'dart:io';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_extensions/ac_extensions.dart';
import 'package:ac_web/ac_web.dart';

/* AcDoc({
  "summary": "The core class of the web framework, responsible for routing and request handling.",
  "description": "This class acts as the main server instance. It manages route definitions, handles incoming requests by dispatching them to the appropriate handlers (either controller methods or closures), and automatically generates OpenAPI (Swagger) documentation for the defined routes.",
  "example": "void main() {\n  // 1. Create a server instance.\n  final app = AcWeb();\n\n  // 2. Register a simple route.\n  app.get(\n    url: '/hello/{name}', \n    handler: (AcWebRequest request) {\n      final name = request.pathParameters['name'] ?? 'World';\n      return AcWebResponse.json(data: {'message': 'Hello, \$name!'});\n    }\n  );\n\n  // 3. Register a controller (recommended).\n  app.registerController(controllerClass: UserController);\n\n  // 4. (In a real server) Listen for requests and pass them to app.handleRequest(...)\n}"
}) */
class AcWeb {
  /* AcDoc({"summary": "The master API documentation object that accumulates all route docs."}) */
  AcApiDoc acApiDoc;

  /* AcDoc({"summary": "A map of all registered routes, keyed by 'METHOD>url_path'."}) */
  final Map<String, AcWebRouteDefinition> routeDefinitions = {};

  /* AcDoc({"summary": "A list of routes for serving static files."}) */
  final List<Map<String, dynamic>> staticFilesRoutes = [];

  /* AcDoc({"summary": "The logger instance for the web server."}) */
  AcLogger logger = AcLogger(
    logMessages: true,
    logDirectory: 'logs/ac-web',
    logType: AcEnumLogType.console,
    logFileName: 'ac-web.txt',
  );

  /* AcDoc({"summary": "An optional global URL prefix for all routes."}) */
  String urlPrefix = "";

  /* AcDoc({
    "summary": "Initializes a new web server instance.",
    "description": "The constructor sets up the framework by firing the `acWebCreated` hook and registering the built-in routes required to serve OpenAPI/Swagger documentation at the `/swagger/` path.",
    "params": [
      {"name": "paths", "description": "A list of paths, currently unused."}
    ]
  }) */
  AcWeb({List<String> paths = const []}) : acApiDoc = AcApiDoc() {
    AcHooks.execute(hookName: AcEnumWebHook.acWebCreated.value, args: [this]);

    // Register the route that generates the main swagger.json file.
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

    // Register routes to serve the static Swagger UI files.
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

  /* AcDoc({"summary": "Extracts named parameters from a URL path based on a route template."}) */
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

  /* AcDoc({"summary": "Generates API documentation for a route by reflecting on its controller method."}) */
  AcApiDocRoute _getRouteDocFromMethodMirror({
    required AcMethodMirror methodMirror,
    AcApiDocRoute? acApiDocRoute,
  }) {
    acApiDocRoute ??= AcApiDocRoute();
    for (var param in methodMirror.parameters) {
      for (var meta in param.metadata) {
        var key = param.simpleName.getName();
        if (meta is AcWebValueFromPath) {
          acApiDocRoute.addParameter(parameter: AcApiDocParameter(name: key, required: true, in_: "path"));
        } else if (meta is AcWebValueFromQuery) {
          acApiDocRoute.addParameter(parameter: AcApiDocParameter(name: key, required: true, in_: "query"));
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

  /* AcDoc({"summary": "Checks if a request URI matches a route's path template."}) */
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

  void autoRegisterControllers(){
    List<Type> controllers =  acGetClassTypesWithAnnotation(AcWebController);
    for(var controller in  controllers){
      registerController(controllerClass: controller);
    }
  }

  /* AcDoc({
    "summary": "Handles an incoming web request by dispatching it to the correct handler.",
    "description": "This is the main request dispatcher. It finds the matching route definition and executes its handler. For controller methods, it uses reflection to perform dependency injection, automatically populating method parameters from the request path, query, headers, body, etc., based on `@AcWebValueFrom...` annotations.",
    "params": [
      {"name": "request", "description": "The incoming request object."},
      {"name": "routeDefinition", "description": "The route definition that matches the request."}
    ],
    "returns": "A future that completes with the `AcWebResponse` generated by the handler.",
    "returns_type": "Future<AcWebResponse>"
  }) */
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
      logger.log("Handing controller route...");
      final controllerClassMirror = acReflectClass(routeDefinition.controller!);
      // Create a new instance of the controller for each request.
      final controllerInstance = controllerClassMirror.newInstance('', []);
      logger.log("Instance class name is : ${controllerClassMirror.getName()}");
      final controllerInstanceMirror = acReflect(controllerInstance);

      final methodName = Symbol(routeDefinition.handler as String);
      logger.log("Handler controller method name is : ${methodName.getName()}");
      final methodMirror = controllerClassMirror.instanceMembers[methodName] as AcMethodMirror;

      final positionalArgs = <dynamic>[];
      final namedArgs = <Symbol, dynamic>{};
      logger.log("Looking for arguments of method : ${methodName.getName()}");
      for (final parameter in methodMirror.parameters) {
        dynamic argValue;
        bool valueSet = false;
        logger.log("Found parameter : ${parameter.getName()}");

        if (parameter.type == AcWebRequest) {
          logger.log("Parameter type is AcWebRequest");
          argValue = request;
          valueSet = true;
        } else {
          logger.log("Checking meta of parameter");
          for (final meta in parameter.metadata) {
            final key = parameter.simpleName.getName();
            logger.log("Parameter key : $key");
            if (meta is AcWebValueFromPath && request.pathParameters.containsKey(key)) {
              logger.log("Parameter is of type AcWebValueFromPath");
              argValue = request.pathParameters[key]; valueSet = true; break;
            } else if (meta is AcWebValueFromQuery && request.queryParameters.containsKey(key)) {
              logger.log("Parameter is of type AcWebValueFromQuery");
              argValue = request.queryParameters[key]; valueSet = true; break;
            } else if (meta is AcWebValueFromForm && request.formFields.containsKey(key)) {
              logger.log("Parameter is of type AcWebValueFromForm");
              argValue = request.formFields[key]; valueSet = true; break;
            } else if (meta is AcWebValueFromHeader && request.headers.containsKey(key)) {
              logger.log("Parameter is of type AcWebValueFromHeader");
              argValue = request.headers[key]; valueSet = true; break;
            } else if (meta is AcWebValueFromCookie && request.cookies.containsKey(key)) {
              logger.log("Parameter is of type AcWebValueFromCookie");
              argValue = request.cookies[key]; valueSet = true; break;
            } else if (meta is AcWebValueFromBody) {
              logger.log("Parameter is of type AcWebValueFromBody");
              final paramType = parameter.type;
              final object = acReflectClass(paramType).newInstance('', []);
              AcJsonUtils.setInstancePropertiesFromJsonData(instance: object, jsonData: request.body);
              argValue = object; valueSet = true; break;
            }
          }
        }
        if (!valueSet) {
          logger.log("Value is not set");
          argValue = null;
        }
        if(parameter.isNamed){
          logger.log("Parameter is named");
          namedArgs[parameter.simpleName] = argValue;
        } else {
          logger.log("Parameter is not named");
          positionalArgs.add(argValue);
        }
      }
      print(controllerInstanceMirror.instance);
      print(methodName);
      print(positionalArgs);
      print(namedArgs);
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

  /* AcDoc({
    "summary": "Registers all routes from a controller class.",
    "description": "This is the recommended way to define routes. It reflects on the provided controller class, finds all methods annotated with `@AcWebRoute`, and automatically registers them as API endpoints. It also generates API documentation from the method's parameters and metadata annotations.",
    "params": [
      {"name": "controllerClass", "description": "The `Type` of the controller class to register."}
    ],
    "returns": "The current `AcWeb` instance, for a fluent interface.",
    "returns_type": "AcWeb"
  }) */
  AcWeb registerController({required Type controllerClass}) {
    final classMirror = acReflectClass(controllerClass);
    logger.log("Registering controller class : ${classMirror.getName()}");
    String classRoute = '';
    logger.log("Checking class meta...");
    for (var meta in classMirror.metadata) {
      if (meta is AcWebRoute) {
        logger.log("Found route meta annotation.");
        classRoute = meta.path.trimRight();
      }
    }
    logger.log("Class meta checked.");
    logger.log("Class route is : $classRoute");
    logger.log("Going through class instance members...");
    for (var member in classMirror.instanceMembers.values) {
      if (member is! AcMethodMirror) continue;
      logger.log("Found method mirror.");
      for (var meta in member.metadata) {
        logger.log("Checking method meta...");
        if (meta is AcWebRoute) {
          logger.log("Found route meta annotation on method.");
          final fullPath = '$classRoute/${meta.path.trim()}'.replaceAll('//', '/');
          final httpMethod = meta.method.toLowerCase();
          final routeKey = '$httpMethod>$fullPath';
          logger.log("Method route details > Method: $httpMethod, Path : $fullPath, RouteKey : $routeKey ");
          final acApiDocRoute = _getRouteDocFromMethodMirror(methodMirror: member);

          routeDefinitions[routeKey] = AcWebRouteDefinition.instanceFromJson({
            'url': fullPath,
            'method': httpMethod,
            'controller': controllerClass,
            'handler': member.simpleName.getName(),
            'documentation': acApiDocRoute,
          });
        }
      }
    }
    logger.log("Controller registered.");
    return this;
  }

  /* AcDoc({
    "summary": "Registers a route with a closure handler.",
    "description": "A generic method for registering a route. This is best for simple routes. Note: For routes registered this way, parameter injection is not supported, and API documentation must be provided manually via the `acApiDocRoute` parameter.",
    "params": [
      {"name": "url", "description": "The URL path for the route."},
      {"name": "handler", "description": "The closure function that handles the request."},
      {"name": "method", "description": "The HTTP method (e.g., 'GET', 'POST')."},
      {"name": "acApiDocRoute", "description": "An optional, manually created documentation object for this route."}
    ],
    "returns": "The current `AcWeb` instance, for a fluent interface.",
    "returns_type": "AcWeb"
  }) */
  AcWeb route({
    required String url,
    required Function handler,
    required String method,
    AcApiDocRoute? acApiDocRoute,
  }) {
    var routeKey = '${method.toLowerCase()}>$url';
    routeDefinitions[routeKey] = AcWebRouteDefinition.instanceFromJson({
      AcWebRouteDefinition.keyUrl: url,
      AcWebRouteDefinition.keyMethod: method.toLowerCase(),
      AcWebRouteDefinition.keyHandler: handler,
      AcWebRouteDefinition.keyDocumentation: acApiDocRoute ?? AcApiDocRoute(),
    });
    return this;
  }

  // --- Standard HTTP method helpers ---

  /* AcDoc({"summary": "Adds a server URL to the API documentation."}) */
  AcWeb addHostUrl({required String url}) {
    acApiDoc.addServer(server: AcApiDocServer(url: url));
    return this;
  }

  /* AcDoc({"summary": "Registers a route for the CONNECT HTTP method."}) */
  AcWeb connect({required String url, required Function handler, AcApiDocRoute? acApiDocRoute}) => route(url: url, handler: handler, method: 'CONNECT', acApiDocRoute: acApiDocRoute);

  /* AcDoc({"summary": "Registers a route for the DELETE HTTP method."}) */
  AcWeb delete({required String url, required Function handler, AcApiDocRoute? acApiDocRoute}) => route(url: url, handler: handler, method: 'DELETE', acApiDocRoute: acApiDocRoute);

  /* AcDoc({"summary": "Registers a route for the GET HTTP method."}) */
  AcWeb get({required String url, required Function handler, AcApiDocRoute? acApiDocRoute}) => route(url: url, handler: handler, method: 'GET', acApiDocRoute: acApiDocRoute);

  /* AcDoc({"summary": "Registers a route for the HEAD HTTP method."}) */
  AcWeb head({required String url, required Function handler, AcApiDocRoute? acApiDocRoute}) => route(url: url, handler: handler, method: 'HEAD', acApiDocRoute: acApiDocRoute);

  /* AcDoc({"summary": "Registers a route for the OPTIONS HTTP method."}) */
  AcWeb options({required String url, required Function handler, AcApiDocRoute? acApiDocRoute}) => route(url: url, handler: handler, method: 'OPTIONS', acApiDocRoute: acApiDocRoute);

  /* AcDoc({"summary": "Registers a route for the PATCH HTTP method."}) */
  AcWeb patch({required String url, required Function handler, AcApiDocRoute? acApiDocRoute}) => route(url: url, handler: handler, method: 'PATCH', acApiDocRoute: acApiDocRoute);

  /* AcDoc({"summary": "Registers a route for the POST HTTP method."}) */
  AcWeb post({required String url, required Function handler, AcApiDocRoute? acApiDocRoute}) => route(url: url, handler: handler, method: 'POST', acApiDocRoute: acApiDocRoute);

  /* AcDoc({"summary": "Registers a route for the PUT HTTP method."}) */
  AcWeb put({required String url, required Function handler, AcApiDocRoute? acApiDocRoute}) => route(url: url, handler: handler, method: 'PUT', acApiDocRoute: acApiDocRoute);

  /* AcDoc({"summary": "Registers a route for the TRACE HTTP method."}) */
  AcWeb trace({required String url, required Function handler, AcApiDocRoute? acApiDocRoute}) => route(url: url, handler: handler, method: 'TRACE', acApiDocRoute: acApiDocRoute);

  /* AcDoc({
    "summary": "Configures a route to serve static files from a directory.",
    "description": "Sets up a route where requests beginning with the `prefix` will serve files from the specified `directory` on the filesystem.",
    "params": [
      {"name": "directory", "description": "The local filesystem directory to serve files from."},
      {"name": "prefix", "description": "The URL prefix that maps to the static directory."}
    ],
    "returns": "The current `AcWeb` instance, for a fluent interface.",
    "returns_type": "AcWeb"
  }) */
  AcWeb staticFiles({required String directory, required String prefix}) {
    staticFilesRoutes.add({'prefix': prefix, 'directory': directory});
    return this;
  }

  Map getUrlJson() {
    List<String> urls = routeDefinitions.keys.toList();
    var index = 0;
    final Map result = {};

    for (var url in urls) {
      url = url.substring(url.indexOf(">")+1);
      url = url .replaceAll(RegExp(r"\{.*?\}"), "");
      url = url.trim();
      if(url.charAt(url.length - 1) =="/"){
        url = url.substring(0,url.length-1);
      }
      final parts = url.replaceFirst(RegExp(r"^/"), "").split("/");

      // recursive builder
      Map current = result;
      for (int i = 0; i < parts.length; i++) {
        final key = (parts[i].replaceAll(RegExp(r"\{.*?\}"), "")).toCamelCase();
        if (i == parts.length - 1) {
          current[key] = url;
        } else {
          if(!current.containsKey(key)){
            current[key] = Map.from({});
          }
          if(current[key] is Map){
            current = current[key];
          }
        }
      }
    }

    return result;
  }
}