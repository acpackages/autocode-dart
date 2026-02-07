import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:ac_extensions/ac_extensions.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_web/ac_web.dart';
import 'package:jaguar/jaguar.dart';
import 'package:jaguar_cors/jaguar_cors.dart';

class RoutePathInfo {
  final String path;
  final List<String> params;

  RoutePathInfo(this.path, this.params);
}


/* AcDoc({
  "summary": "A concrete web server implementation using the Jaguar framework.",
  "description": "This class extends the abstract `AcWeb` server and provides a runnable implementation powered by the Jaguar web server package. It handles the lifecycle of the server (start, stop), translates Jaguar requests and responses to and from the framework's standard `AcWebRequest`/`AcWebResponse` objects, registers routes, and manages SSL.",
  "example": "void main() async {\n  final server = AcWebOnJaguar();\n\n  // Configure server properties\n  server.port = 8080;\n  server.forceHttps = false;\n  \n  // Register a controller\n  server.registerController(controllerClass: MyController);\n\n  // Start the server\n  await server.start();\n  print('Server listening on port \${server.port}');\n}"
}) */
class AcWebOnJaguar extends AcWeb {
  /* AcDoc({"summary": "A custom error handler for generating 404 and 500 responses."}) */
  final CustomErrorWriter _customErrorWriter = CustomErrorWriter();

  /* AcDoc({"summary": "Configuration options for Cross-Origin Resource Sharing (CORS)."}) */
  CorsOptions corsOptions = const CorsOptions(
    allowAllOrigins: true,
    allowAllHeaders: true,
    allowAllMethods: true,
  );
  /* AcDoc({"summary": "If true, all HTTP requests will be redirected to their HTTPS equivalent."}) */
  bool forceHttps = false;

  /* AcDoc({"summary": "The underlying Jaguar server instance for HTTP."}) */
  Jaguar? jaguarInstance;

  /* AcDoc({"summary": "The underlying Jaguar server instance for HTTPS/SSL."}) */
  Jaguar? jaguarSecureInstance;

  /* AcDoc({"summary": "The port number for the HTTP server."}) */
  int port = 0;

  /* AcDoc({"summary": "The port number for the HTTPS/SSL server."}) */
  int sslPort = 0;

  /* AcDoc({"summary": "The file system path to the SSL certificate chain file (.pem)."}) */
  String sslCertificateChainPath = "";

  /* AcDoc({"summary": "The file system path to the SSL private key file (.key)."}) */
  String sslPrivateKeyPath = "";

  /* AcDoc({
    "summary": "Initializes a new Jaguar-based web server instance.",
    "description": "Passes the `paths` parameter to the parent `AcWeb` constructor."
  }) */
  AcWebOnJaguar({super.paths});

  /* AcDoc({"summary": "Iterates through defined routes and registers them with the Jaguar instance."}) */
  void _addRoutesToJaguar() {
    for (var routeKey in routeDefinitions.keys) {
      AcWebRouteDefinition routeDefinition = routeDefinitions[routeKey]!;
      logger.log(
        "Registering jaguar route for route : $routeKey >>>> Url : ${routeDefinition.url}...",
      );
      var routeDetails = _normalizeRoutePath(routeDefinition.url);
      Route route = Route(
        routeDetails.path,
        methods: [routeDefinition.method.toUpperCase()],
        (context) async {
          final request = await _createAcWebRequestFromJaguarContext(context);
          // request
          logger.log("Handling jaguar request for : ${context.path}");
          logger.log(request);
          AcWebResponse webResponse = await handleWebRequest(
            request,
            routeDefinition,
          );
          await _createJaguarResponseFromAcWebResponse(webResponse, context);
        },
        before: [cors(corsOptions)],
      );
      jaguarInstance!.addRoute(route);
      logger.log(
        "Registered jaguar route for route : $routeKey >>>> Url : ${routeDefinition.url}!",
      );
    }
    for (var assetDirectory in assetFilesRoutes){
      String prefix = assetDirectory['prefix'];
      String assetsPrefix = assetDirectory['directory'];
      Route route = Route.get(prefix, (context) async {
        dynamic body = "";
        String? mimeType = 'text/html';
        try {
          String routePath = context.path;
          if (routePath.startsWith("/")) {
            routePath = routePath.substring(1);
          }
          String extension=AcFileUtils.getExtensionFromPath(routePath);
          mimeType = AcFileUtils.getMimeTypeFromExt(extension);
          logger.log("Loading Asset File for path $routePath");
          body = (await rootBundle.load('$assetsPrefix$routePath')).buffer.asUint8List();

          context.response = ByteResponse(body: body, mimeType: mimeType);
        } catch (ex,stack) {
          logger.error(ex);
          logger.error(stack);
          context.response = Response(statusCode: HttpStatus.notFound);
          // if (errorFunction != null) {
          //   dynamic errorResponse =
          //   errorFunction(Simplify.getExceptionMessage(ex,stack: stack));
          //   if (errorResponse != null) {
          //     context.response = Response.html(errorResponse);
          //   }
          // }
        }
      });
      jaguarInstance!.addRoute(route);
    }
    for (var rawMap in rawContentMaps){
      String prefix = rawMap['prefix'];
      String fallbackUrl = rawMap['fallbackUrl'];
      Map<String,dynamic> filesMap = rawMap['map'];
      Route route = Route.get(prefix, (context) async {
        dynamic body = "";
        String? mimeType = 'text/html';
        try {
          String routePath = context.path;
          if (routePath.startsWith("/")) {
            routePath = routePath.substring(1);
          }
          String extension=AcFileUtils.getExtensionFromPath(routePath);
          mimeType = AcFileUtils.getMimeTypeFromExt(extension);
          logger.log("Loading Asset File for path $routePath");
          if (!filesMap.containsKey(routePath)) {
            routePath = fallbackUrl;
          }

          if(filesMap.containsKey(routePath)){
            final content = filesMap[routePath]!;
            if (content.startsWith('base64:')) {
              final bytes = base64Decode(content.substring(7));
              return ByteResponse(
                body: Uint8List.fromList(bytes),mimeType: mimeType,
              );
            }
            return Response(
              body: content,mimeType: mimeType,
            );
          }
          else{
            context.response = Response(statusCode: HttpStatus.notFound);
          }
        } catch (ex,stack) {
          logger.error(ex);
          logger.error(stack);
          context.response = Response(statusCode: HttpStatus.notFound);
          // if (errorFunction != null) {
          //   dynamic errorResponse =
          //   errorFunction(Simplify.getExceptionMessage(ex,stack: stack));
          //   if (errorResponse != null) {
          //     context.response = Response.html(errorResponse);
          //   }
          // }
        }
      });
      jaguarInstance!.addRoute(route);
    }
    for (var staticDirectory in staticFilesRoutes){
      String url = staticDirectory['prefix']+staticDirectory['directory'];
      if(!url.startsWith("/")){
        url = "/$url";
      }
      url = "$url/*";
      String directory = staticDirectory['directory'];
      logger.log("Registering jaguar route for static files directory : Path : $url >>>> Directory : ${directory}...",
      );
      jaguarInstance!.staticFiles(url,directory);
    }
  }

  _addStaticFilesRoute(String path, String directory,{Function? errorFunction,ResponseProcessor? responseProcessor,}) {
    Route route = Route.get(path, (context) async {
      dynamic body = "";
      String? mimeType = 'text/html';
      try {
        String routePath = context.path;
        if (routePath.startsWith("/")) {
          routePath = routePath.substring(1);
        }
        String localPath = "$directory/${routePath.substring(path.replaceAll("*","").length)}";
        if(routePath.startsWith("$directory/")){
          // localPath = directoryroutePath.substring(path.replaceAll("*","").length);
        }
        File localFile = new File(localPath);
        logger.log("Loading Static File for path $routePath : LocalPath = $localPath");
        if(localFile.existsSync()){
          String extension=AcFileUtils.getExtensionFromPath(routePath);
          logger.log("Found LocalFile $routePath : Extension : $extension : Mime : $mimeType");
          body = localFile.readAsBytesSync();
          // mimeType = MimeList.fromExtension[extension];
          mimeType = AcFileUtils.getMimeTypeFromPath(routePath);
          context.response = ByteResponse(body: body, mimeType: mimeType);
        }
        else{
          logger.log("Could not file static file for $routePath : LocalPath = $localPath");
          context.response = Response(statusCode: HttpStatus.notFound);
        }
      } catch (ex,stack) {
        logger.error(Autocode.getExceptionMessage(exception: ex,stackTrace: stack));
        context.response = Response(statusCode: HttpStatus.notFound);
        if (errorFunction != null) {
          dynamic errorResponse =
          errorFunction(Autocode.getExceptionMessage(exception: ex,stackTrace: stack));
          if (errorResponse != null) {
            context.response = Response.html(errorResponse);
          }
        }
      }
    }, responseProcessor: responseProcessor,before:[cors(corsOptions)]);
    jaguarInstance!.addRoute(route);
  }

  RoutePathInfo _normalizeRoutePath(String originalPath) {
    final paramRegex = RegExp(r'\{([^}]+)\}');
    final matches = paramRegex.allMatches(originalPath);

    // If no path params → return original path unchanged
    if (matches.isEmpty) {
      return RoutePathInfo(originalPath, []);
    }

    // Extract param names and replace {param} → :param
    final params = matches.map((m) => m.group(1)!).toList();
    final convertedPath =
    originalPath.replaceAllMapped(paramRegex, (m) => ':${m[1]}');

    return RoutePathInfo(convertedPath, params);
  }

  /* AcDoc({"summary": "Translates a Jaguar `Context` object into the framework's standard `AcWebRequest`."}) */
  Future<AcWebRequest> _createAcWebRequestFromJaguarContext(
    Context context,
  ) async {
    AcWebRequest acWebRequest = AcWebRequest();
    acWebRequest.url = context.path.substring(1);
    try {
      logger.log("Generating AcWebRequest for path : ${acWebRequest.url}");
      acWebRequest.cookies.addAll(context.cookies);
      String method = context.req.method;
      logger.log("Method : $method");
      HttpHeaders headers = context.headers;
      headers.forEach((name, values) async {
        if (values.length == 1) {
          acWebRequest.headers[name] = values.first;
        } else {
          acWebRequest.headers[name] = values;
        }
      });
      context.query.forEach((key, value) {
        acWebRequest.get[key] = value;
      });
      acWebRequest.pathParameters = context.pathParams.toNestedMap();
      if (method == "POST") {
        bool foundNested = false;
        if (context.isFormData) {
          var formData = await context.bodyAsFormData();
          Map<String,dynamic> formEntries = formData.toNestedMap(valueExtractor: ( FormField<dynamic> value){
            if(value is FileFormField || value is BinaryFileFormField){
              AcWebFile webFile = AcWebFile();
              if(value.contentType != null){
                webFile.setContentType(contentType:value.contentType!);
              }
              if(value is TextFileFormField){
                webFile.fileName = value.filename;
                webFile.contentText = value.value;
              }
              else{
                var fileField = value as BinaryFileFormField;
                webFile.fileName = fileField.filename;
                webFile.contentStream = fileField.value;
              }
              return webFile;
            }
            else{
              return value.value;
            }
          });
          for (var key in formEntries.keys) {
            var value = formEntries[key];
            if(value is AcWebFile){
              acWebRequest.files[key] = value;
            }
            acWebRequest.post[key] = value;
          }
          // for (var entry in formData.entries) {
          //   final key = entry.key;
          //   final value = entry.value.value;
          //
          //   // Parse key: accountee[accountee_name] => ["accountee", "accountee_name"]
          //   final regex = RegExp(r'([^\[\]]+)|\[(.*?)\]');
          //   final matches = regex.allMatches(key);
          //   final parts = matches.map((m) => m.group(1) ?? m.group(2)!).toList();
          //
          //   Map<String, dynamic> current = acWebRequest.post;
          //   for (int i = 0; i < parts.length; i++) {
          //     final part = parts[i];
          //
          //     if (i == parts.length - 1) {
          //       current[part] = value;
          //     } else {
          //       if (current[part] == null || current[part] is! Map<String, dynamic>) {
          //         current[part] = {};
          //       }
          //       current = current[part];
          //     }
          //   }
          // }
          // for (var key in formData.keys) {
          //   FormField value = formData[key]!;
          //   logger.log(
          //     "Found File Field : $key = ${formData[key] is FileFormField}",
          //   );
          //   logger.log("$key = ${value}");
          //   if (formData[key] is FileFormField ||
          //       formData[key] is BinaryFileFormField) {
          //     ContentType? type = value.contentType;
          //     // UploadFile uploadFile=UploadFile();
          //     // Simplify.debug("Found file");
          //     // if(formData[key] is TextFileFormField){
          //     //   // Simplify.debug("Found text file form field");
          //     //   TextFileFormField textFile=formData[key] as TextFileFormField;
          //     //
          //     //   Simplify.debug(textFile.toString());
          //     //   Simplify.debug(textFile);
          //     //   uploadFile.filename=textFile.filename!;
          //     //   uploadFile.contentStream=textFile.value.cast();
          //     // }
          //     // else{
          //     //   Simplify.debug("Found Binary file form field");
          //     //   BinaryFileFormField binaryFile=formData[key] as BinaryFileFormField;
          //     //   uploadFile.filename=binaryFile.filename!;
          //     //   uploadFile.contentStream=binaryFile.value;
          //     // }
          //     // FileFormField? fileFormField = await context.getFile(key);
          //     // if (fileFormField != null) {
          //     //   uploadFile.field=fileFormField;
          //     //   acWebRequest.putFile(key, uploadFile);
          //     // }
          //   } else {
          //     if (key.indexOf("[") > 0) {
          //       FormField formField=formData[key] as FormField;
          //       foundNested = true;
          //       acWebRequest.putPostUrlEncodedMap(formField.name, formField.value);
          //     } else {
          //       FormField formField = formData[key] as FormField;
          //       acWebRequest.post[formField.name] = formField.value;
          //     }
          //   }
          // }
        } else if (context.isJson) {
          Map<String, dynamic> formData =
              (await context.bodyAsJsonMap()).cast<String, dynamic>();
          acWebRequest.post.addAll(formData);
        } else if (context.isUrlEncodedForm) {
          Map<String, String> formData = await context.bodyAsUrlEncodedForm();
          formData.forEach((key, value) async {
            if (key.indexOf("[") > 0) {
              foundNested = true;
            } else {
              acWebRequest.post[key] = value;
            }
          });
        }
      }
    } catch (ex, stack) {
      logger.error([ex, stack]);
    }
    // acWebRequest. = context;
    return acWebRequest;
  }

  /* AcDoc({"summary": "Translates the framework's `AcWebResponse` into a Jaguar `Response`."}) */
  Future<void> _createJaguarResponseFromAcWebResponse(
    AcWebResponse acWebResponse,
    Context context,
  ) async {
    logger.log(["", "", "Getting response for path ${context.path}"]);
    Response response = context.response;
    try {
      response = context.response;
      String resultType = "html";
      if (acWebResponse.responseCode == AcEnumHttpResponseCode.ok) {
        if (acWebResponse.responseType == AcEnumWebResponseType.html) {
          response = Response.html(acWebResponse.content);
        } else if (acWebResponse.responseType == AcEnumWebResponseType.json) {
          response = Response.json(acWebResponse.content);
        } else if (acWebResponse.responseType == AcEnumWebResponseType.raw) {
          response = Response(
            body: acWebResponse.content,
            headers: acWebResponse.headers,
            mimeType: AcFileUtils.getMimeTypeFromPath(context.path),
          );
        }
      } else {
        if (acWebResponse.responseType == AcEnumWebResponseType.redirect) {
          response = Redirect(
            Uri.parse(acWebResponse.content),
            statusCode: acWebResponse.responseCode,
          );
        }
      }
    } catch (ex, stack) {
      response = Response(
        body: Autocode.getExceptionMessage(exception: ex, stackTrace: stack),
        statusCode: AcEnumHttpResponseCode.internalServerError.value,
      );
    }
    context.response = response;
  }

  /* AcDoc({
    "summary": "Starts the Jaguar web server.",
    "description": "Configures and launches the Jaguar server instance(s) on the specified ports. If `forceHttps` is true, the HTTP instance will only serve redirects to the HTTPS port. If SSL is configured, a secure server will also be started.",
    "returns": "An `AcResult` indicating if the server started successfully.",
    "returns_type": "Future<AcResult>"
  }) */
  Future<AcResult> start() async {
    AcResult acResult = AcResult();
    try {
      if (port == 0) {
        port = 80;
      }
      logger.log("Starting jaguar server on port $port...");
      jaguarInstance = Jaguar(port: port, errorWriter: _customErrorWriter);
      if (jaguarInstance != null) {}
      if (forceHttps) {
        Route redirectRoute = Route("*", (context) async {
          try {
            logger.log("Context URL : ${context.req.requestedUri.toString()}");
            var uri = context.req.requestedUri;
            var redirectUri = Uri(
              scheme: 'https',
              host: uri.host,
              port: sslPort, // Extract host without port
              path: uri.path,
              query: uri.queryParameters.toString(),
            );
            if (context.req.requestedUri.port > 0) {
              redirectUri = Uri(
                scheme: 'https',
                host: uri.host,
                path: uri.path,
                query: uri.queryParameters.toString(),
              );
            }
            logger.log("Redirecting to : $redirectUri");
            context.response = Redirect(
              redirectUri,
              statusCode: HttpStatus.movedTemporarily,
            );
          } catch (ex, stack) {
            context.response = Response.html(
              Autocode.getExceptionMessage(exception: ex, stackTrace: stack),
            );
          }
        }, before: [cors(corsOptions)]);
        jaguarInstance!.addRoute(redirectRoute);
      } else {
        _addRoutesToJaguar();
        // jaguarInstance!.add(routes);
      }
      jaguarInstance!.onException.add(
        (ctx, temp, trace) => logger.error(
          "After Path in Exception ${ctx.path} Response = ${ctx.response.statusCode}",
        ),
      );
      // jaguarInstance?.addRoute(_handleRequest());
      await jaguarInstance?.serve();
      logger.log("Jaguar server running on port $port");
      if (sslPort > 0) {
        SecurityContext securityContext = SecurityContext();
        if (sslCertificateChainPath.isNotEmpty) {
          securityContext.useCertificateChain(sslCertificateChainPath);
        }
        if (sslPrivateKeyPath.isNotEmpty) {
          securityContext.usePrivateKey(sslPrivateKeyPath);
        }
        jaguarSecureInstance = new Jaguar(
          port: sslPort,
          errorWriter: _customErrorWriter,
          securityContext: securityContext,
        );
        if (jaguarSecureInstance != null) {}
        // jaguarSecureInstance!.add(routes);
        // staticPaths.forEach((key, value) {
        //   jaguarSecureInstance?.staticFiles(key, value);
        // });
        jaguarSecureInstance!.onException.add(
          (ctx, temp, trace) => logger.log(
            "After Path in Exception ${ctx.path} Response = ${ctx.response.statusCode}",
          ),
        );
        // jaguarInstance?.addRoute(_handleRequest());
        await jaguarSecureInstance?.serve();
      }
      acResult.setSuccess();
    } catch (ex, stack) {
      logger.error([ex, stack]);
      acResult.setException(exception: ex,stackTrace: stack);
    }
    return acResult;
  }

  /* AcDoc({
    "summary": "Stops the running Jaguar server instance(s).",
    "description": "Gracefully shuts down both the HTTP and HTTPS Jaguar servers if they are running."
  }) */
  stop() async {
    logger.log("Stopping jaguar server...");
    if (jaguarInstance != null) {
      await jaguarInstance!.close();
    }
    if (jaguarSecureInstance != null) {
      await jaguarSecureInstance!.close();
    }
    logger.log("Jaguar server stopped.");
  }
}

/* AcDoc({
  "summary": "A custom error handler for the Jaguar server.",
  "description": "Implements Jaguar's `ErrorWriter` to provide custom HTML or JSON responses for 404 (Not Found) and 500 (Internal Server Error) statuses, intelligently choosing the response format based on the client's `Accept` header."
}) */
class CustomErrorWriter implements ErrorWriter {
  /* AcDoc({"summary": "If set, 404 errors will redirect to this URL instead of showing an error page."}) */
  String redirectUrl404 = "";

  /* AcDoc({"summary": "Path to a static asset file to serve for 404 errors (future use)."}) */
  String assetFile404 = "";

  /* AcDoc({
    "summary": "Builds a response for a 404 Not Found error.",
    "description": "Checks the request's `Accept` header to return either a detailed HTML error page or a structured JSON error object.",
    "returns": "A Jaguar `Response` object for the 404 error.",
    "returns_type": "FutureOr<Response>"
  }) */
  @override
  FutureOr<Response> make404(Context ctx) async {
    Response response = Response(
      body: _write404Html(ctx),
      statusCode: HttpStatus.notFound,
    )..headers.contentType = ContentType.html;
    if (redirectUrl404.isNotEmpty) {
      response = Redirect(
        Uri.parse(redirectUrl404),
        statusCode: HttpStatus.movedTemporarily,
      );
      return response;
    } else {
      final String accept =
          ctx.req.headers.value(HttpHeaders.acceptHeader) ?? '';
      final List<String> acceptList = accept.split(',');

      if (acceptList.contains('text/html')) {
        response = Response(
          body: _write404Html(ctx),
          statusCode: HttpStatus.notFound,
          mimeType: MimeTypes.html,
        );
      } else if (acceptList.contains('application/json') ||
          acceptList.contains('text/json')) {
        response = Response.json({
          'Path': ctx.path,
          'Method': ctx.method,
          'Message': 'Not found!',
        }, statusCode: HttpStatus.notFound);
      }
    }
    return response;
  }

  /* AcDoc({
    "summary": "Builds a response for a 500 Internal Server Error.",
    "description": "Checks the request's `Accept` header to return either a detailed HTML error page with a stack trace or a structured JSON error object.",
    "returns": "A Jaguar `Response` object for the 500 error.",
    "returns_type": "FutureOr<Response>"
  }) */
  @override
  FutureOr<Response> make500(Context ctx, Object error, [StackTrace? stack]) {
    final String accept = ctx.req.headers.value(HttpHeaders.acceptHeader) ?? '';
    final List<String> acceptList = accept.split(',');

    if (acceptList.contains('text/html')) {
      return Response(
        body: _write500Html(ctx, error, stack),
        statusCode: HttpStatus.notFound,
        mimeType: MimeTypes.html,
      );
    } else if (acceptList.contains('application/json') ||
        acceptList.contains('text/json')) {
      final data = <String, dynamic>{'error': error.toString()};
      if (stack != null) {
        data['stack'] = stack.toString();
      }

      return Response.json(data, statusCode: 500);
    } /* TODO else if (acceptList.contains('application/xml')) {
      final data = <String, dynamic>{
        'error': error.toString(),
      };
      if (stack != null) data['stack'] = Trace.format(stack);

      return Response.xml(data, statusCode: 500);
    } */ else {
      return Response(
        body: _write500Html(ctx, error, stack),
        statusCode: 500,
        mimeType: MimeTypes.html,
      );
    }
  }

  /* AcDoc({"summary": "Generates the HTML content for a 404 Not Found page."}) */
  String _write404Html(Context ctx) => '''
<!DOCTYPE>
<html>
<head>
  <title>404 - Not found!</title>
  <style>
    body, html {
      margin: 0px;
      padding: 0px;
      border: 0px;
      font-family: monospace, sans-serif;
      background-color: #e4e4e4;
    }
    .content {
      width: 100%;
      height: 100%;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
    }
    .title {
      font-size: 30px;
      margin: 10px 0px;
    }
    .info {
      font-size: 16px;
      margin: 5px 0px;
    }
  </style>
</head>
<body>
  <div class="content">
    <div class="title">Not found!</div>
    <div class="info">Path: <i>${ctx.path}</i></div>
    <div class="info">Method: <i>${ctx.method}</i></div>
  </div>
</body>
</html>
''';

  /* AcDoc({"summary": "Generates the HTML content for a 500 Internal Server Error page."}) */
  String _write500Html(Context ctx, Object error, [StackTrace? stack]) {
    String stackInfo = "";
    if (stack != null) {
      stackInfo = '''
    <div class="info">
    <div class="info-title">Stack</div>
      <pre>${stack.toString()}</pre>
    </div>
    ''';
    }

    return '''
<!DOCTYPE>
<html>
<head>
  <title>Server error</title>
  <style>
    body, html {
      margin: 0px;
      padding: 0px;
      border: 0px;
      background-color: #e4e4e4;
    }
    .header {
      font-family: Helvetica,Arial;
      font-size: 20px;
      line-height: 25px;
      background-color: rgba(204, 49, 0, 0.94);
      color: #F8F8F8;
      overflow: hidden;
      padding: 10px 10px;
      box-sizing: border-box;
      font-weight: bold;
    }
    .footer {
      padding-left:20px;
      height:20px;
      font-family:Helvetica,Arial;
      font-size:12px;
      color:#5E5E5E;
      margin-top: 10px;
    }
    .content {
      font-family:Helvetica,Arial;
      font-size:18px;
    }
    .info {
      border-bottom: 1px solid rgba(0, 0, 0, 0.21);
      padding: 15px;
      box-sizing: border-box;
    }
    .info-title {
      font-size: 20px;
      font-weight: bold;
      margin-bottom: 5px;
    }
    pre {
      margin: 0px;
    }
  </style>
</head>
<body>
  <div class="header" style="">Server error!</div>
  <div class="content">
    <div class="info">
      <div class="info-title">Message</div>
      <div>$error</div>
    </div>
    $stackInfo
    <div class="info">
      <div class="info-title">Request</div>
      <div>Resource: ${ctx.path}</div>
      <div>Method: ${ctx.method}</div>
    </div>
  </div>
  <div class="footer">Jaguar Server - 2016 - <a href="https://github.com/jaguar-dart">https://github.com/jaguar-dart</a></div>
</body>
</html>
''';
  }
}
