import 'dart:async';
import 'dart:io';
import 'dart:mirrors';
import 'package:autocode/autocode.dart';
import 'package:autocode_web/autocode_web.dart';
import 'package:jaguar/jaguar.dart';
import 'package:jaguar_cors/jaguar_cors.dart';

class AcWebOnJaguar extends AcWeb{
  final CustomErrorWriter _customErrorWriter = CustomErrorWriter();
  CorsOptions corsOptions = const CorsOptions(
      allowAllOrigins: true,
      allowAllHeaders: true,
      allowAllMethods: true
  );
  bool forceHttps = false;
  Jaguar? jaguarInstance;
  Jaguar? jaguarSecureInstance;
  int port = 0;
  int sslPort = 0;
  String sslCertificateChainPath = "";
  String sslPrivateKeyPath = "";

  _addRoutesToJaguar(){
    for(var routeKey in routeDefinitions.keys){
      AcWebRouteDefinition routeDefinition = routeDefinitions[routeKey]!;
      logger.log("Registering jaguar route for route : $routeKey >>>> Url : ${routeDefinition.url}...");
      Route route = Route(routeDefinition.url,methods: [routeDefinition.method.toUpperCase()], (context) async {
        final request = await _createAcWebRequestFromJaguarContext(context);
        logger.log("Handling jaguar request for : ${context.path}");
        AcWebResponse webResponse = await handleWebRequest(request,routeDefinition);
        await _createJaguarResponseFromAcWebResponse(webResponse,context);
      },before:[cors(corsOptions)]);
      jaguarInstance!.addRoute(route);
      logger.log("Registered jaguar route for route : $routeKey >>>> Url : ${routeDefinition.url}!");
    }
  }

  Future<AcWebRequest> _createAcWebRequestFromJaguarContext(Context context) async {
    AcWebRequest acWebRequest = AcWebRequest();
    acWebRequest.url = context.path.substring(1);
    try {
      logger.log("Generating AcWebRequest for path : ${acWebRequest.url}");
      acWebRequest.cookies.addAll(context.cookies);
      String method=context.req.method;
      logger.log("Method : $method");
      HttpHeaders headers=context.headers;
      headers.forEach((name, values) async{
        if(values.length==1){
          acWebRequest.headers[name] = values.first;
        }
        else{
          acWebRequest.headers[name] = values;
        }
      });
      context.query.forEach((key, value) {
        acWebRequest.get[key] = value;
      });
      if(method=="POST"){
        bool foundNested = false;
        if(context.isFormData){
          var formData = await context.bodyAsFormData();
          for(var key in formData.keys) {
            FormField value=formData[key]!;
            logger.log("Found File Field : $key = ${formData[key] is FileFormField}");
            logger.log("$key = ${value}");
            if (formData[key] is FileFormField || formData[key] is BinaryFileFormField) {
              ContentType? type = value.contentType;
              // UploadFile uploadFile=UploadFile();
              // Simplify.debug("Found file");
              // if(formData[key] is TextFileFormField){
              //   // Simplify.debug("Found text file form field");
              //   TextFileFormField textFile=formData[key] as TextFileFormField;
              //
              //   Simplify.debug(textFile.toString());
              //   Simplify.debug(textFile);
              //   uploadFile.filename=textFile.filename!;
              //   uploadFile.contentStream=textFile.value.cast();
              // }
              // else{
              //   Simplify.debug("Found Binary file form field");
              //   BinaryFileFormField binaryFile=formData[key] as BinaryFileFormField;
              //   uploadFile.filename=binaryFile.filename!;
              //   uploadFile.contentStream=binaryFile.value;
              // }
              // FileFormField? fileFormField = await context.getFile(key);
              // if (fileFormField != null) {
              //   uploadFile.field=fileFormField;
              //   acWebRequest.putFile(key, uploadFile);
              // }
            }
            else {
              if(key.indexOf("[")>0){
                // FormField formField=formData[key] as FormField;
                // foundNested = true;
                // acWebRequest.putPostUrlEncodedMap(formField.name, formField.value);
              }
              else{
                FormField formField=formData[key] as FormField;
                acWebRequest.post[formField.name] =  formField.value;
              }
            }
          }
        }
        else if(context.isJson){
          Map<String,dynamic >formData=(await context.bodyAsJsonMap()) .cast<String,dynamic>();
          acWebRequest.post.addAll(formData);
        }
        else if(context.isUrlEncodedForm){
          Map<String,String> formData=await context.bodyAsUrlEncodedForm();
          formData.forEach((key, value) async {
            if(key.indexOf("[")>0){
              foundNested = true;
            }
            else{
              acWebRequest.post[key] = value;
            }
          });
        }
      }
    } catch (ex,stack) {
      logger.error([ex,stack]);
    }
    // acWebRequest. = context;
    return acWebRequest;
  }

  Future<void> _createJaguarResponseFromAcWebResponse(AcWebResponse acWebResponse,Context context) async {
    logger.log(["","","Getting response for path ${context.path}"]);
    Response response=context.response;
    try{
      response = context.response;
      String resultType = "html";
      if(acWebResponse.responseCode == AcEnumHttpResponseCode.OK){
        if(acWebResponse.responseType == AcEnumWebResponseType.HTML){
          response = Response.html(acWebResponse.content);
        }
        else if(acWebResponse.responseType == AcEnumWebResponseType.JSON){
          response = Response.json(acWebResponse.content);
        }
        else if(acWebResponse.responseType == AcEnumWebResponseType.RAW){
          response = Response(body: acWebResponse.content, headers: acWebResponse.headers,mimeType: AcFileUtils.getMimeTypeFromPath(context.path));
        }
      }
      else{
        if(acWebResponse.responseType == AcEnumWebResponseType.REDIRECT){
          response=Redirect(Uri.parse(acWebResponse.content),statusCode:acWebResponse.responseCode);
        }
      }
    }
    catch(ex,stack){
      response = Response(body:Autocode.getExceptionMessage(exception: ex,stackTrace: stack),statusCode: AcEnumHttpResponseCode.INTERNAL_SERVER_ERROR);
    }
    context.response = response;
  }

  start() async {
    try {
      if (port == 0) {
        port = 80;
      }
      logger.log("Starting jaguar server on port $port...");
      jaguarInstance = Jaguar(port: port,errorWriter: _customErrorWriter );
      if (jaguarInstance != null) {}
      if(forceHttps){
        Route redirectRoute = Route( "*", (context) async {
          try {
            logger.log("Context URL : ${context.req.requestedUri.toString()}");
            var uri = context.req.requestedUri;
            var redirectUri = Uri(
              scheme: 'https',
              host: uri.host,
              port: sslPort,// Extract host without port
              path: uri.path,
              query: uri.queryParameters.toString(),
            );
            if(context.req.requestedUri.port>0){
              redirectUri = Uri(
                scheme: 'https',
                host: uri.host,
                path: uri.path,
                query: uri.queryParameters.toString(),
              );
            }
            logger.log("Redirecting to : $redirectUri");
            context.response = Redirect(redirectUri,statusCode:HttpStatus.movedTemporarily );
          } catch (ex, stack) {
            context.response =
                Response.html(Autocode.getExceptionMessage(exception: ex, stackTrace: stack));
          }
        }, before: [cors(corsOptions)]);
        jaguarInstance!.addRoute(redirectRoute);
      }
      else{
        _addRoutesToJaguar();
        // jaguarInstance!.add(routes);
      }
      // staticPaths.forEach((key, value) {
      //   jaguarInstance?.staticFiles(key, value);
      // });
      jaguarInstance!.onException.add((ctx,temp,trace) => logger.error("After Path in Exception ${ctx.path} Response = ${ctx.response.statusCode}"));
      // jaguarInstance?.addRoute(_handleRequest());
      await jaguarInstance?.serve();
      logger.log("Jaguar server running on port $port");
      if(sslPort > 0){
        SecurityContext securityContext = SecurityContext();
        if(sslCertificateChainPath.isNotEmpty){
          securityContext.useCertificateChain(sslCertificateChainPath);
        }
        if(sslPrivateKeyPath.isNotEmpty){
          securityContext.usePrivateKey(sslPrivateKeyPath);
        }
        jaguarSecureInstance = new Jaguar(port: sslPort,errorWriter: _customErrorWriter,securityContext: securityContext);
        if (jaguarSecureInstance != null) {}
        // jaguarSecureInstance!.add(routes);
        // staticPaths.forEach((key, value) {
        //   jaguarSecureInstance?.staticFiles(key, value);
        // });
        jaguarSecureInstance!.onException.add((ctx,temp,trace) => logger.log("After Path in Exception ${ctx.path} Response = ${ctx.response.statusCode}"));
        // jaguarInstance?.addRoute(_handleRequest());
        await jaguarSecureInstance?.serve();
      }
    } catch(ex,stack) {
      logger.error([ex,stack]);
    }
  }

  stop() async {
    logger.log("Stopping jaguar server...");
    if(jaguarInstance!=null){
      await jaguarInstance!.close();
    }
    if(jaguarSecureInstance!=null){
      await jaguarSecureInstance!.close();
    }
    logger.log("Jaguar server stopped.");
  }

}


class CustomErrorWriter implements ErrorWriter {
  String redirectUrl404 = "";
  String assetFile404 = "";

  @override
  FutureOr<Response> make404(Context ctx) async{
    Response response = Response(body: _write404Html(ctx), statusCode: HttpStatus.notFound)
      ..headers.contentType = ContentType.html;
    if(redirectUrl404.isNotEmpty) {
      response = Redirect(
          Uri.parse(redirectUrl404), statusCode: HttpStatus.movedTemporarily);
      return response;
    }
    else{
      final String accept = ctx.req.headers.value(HttpHeaders.acceptHeader) ?? '';
      final List<String> acceptList = accept.split(',');

      if (acceptList.contains('text/html')) {
        response = Response(
            body: _write404Html(ctx),
            statusCode: HttpStatus.notFound,
            mimeType: MimeTypes.html);
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

  @override
  FutureOr<Response> make500(Context ctx, Object error, [StackTrace? stack]) {
    final String accept = ctx.req.headers.value(HttpHeaders.acceptHeader) ?? '';
    final List<String> acceptList = accept.split(',');

    if (acceptList.contains('text/html')) {
      return Response(
          body: _write500Html(ctx, error, stack),
          statusCode: HttpStatus.notFound,
          mimeType: MimeTypes.html);
    } else if (acceptList.contains('application/json') ||
        acceptList.contains('text/json')) {
      final data = <String, dynamic>{
        'error': error.toString(),
      };
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
    } */
    else {
      return Response(
          body: _write500Html(ctx, error, stack),
          statusCode: 500,
          mimeType: MimeTypes.html);
    }
  }

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