import 'dart:convert';
import 'package:test/test.dart';
import 'package:autocode/autocode.dart';

import 'package:ac_web/ac_web.dart';

// 1. Define a Mock Controller
@AcWebController()
@AcWebUseInterceptor(['ControllerInterceptor'])
class TestController {
  @AcWebRoute(path: '/hello', method: 'GET')
  @AcWebUseInterceptor(['MethodInterceptor'])
  Future<AcWebResponse> hello(AcWebRequest request) async {
    return AcWebResponse.json(data: {'message': 'Hello World'});
  }

  @AcWebRoute(path: '/secure', method: 'GET')
  @AcWebUseInterceptor(['AcWebJwtInterceptor'])
  Future<AcWebResponse> secure(AcWebRequest request) async {
    final claims = request.internalParams['jwt_claims'];
    return AcWebResponse.json(data: {'user': claims['sub']});
  }
}

// 2. Define Mock Interceptors
class SimpleInterceptor extends AcWebInterceptor {
  final String id;
  final List<String> log;
  SimpleInterceptor(this.id, this.log);

  @override
  String get name => id;

  @override
  Future<AcWebResponse?> onRequest(AcWebRequest request) async {
    log.add('$id:onRequest');
    return null;
  }

  @override
  Future<AcWebResponse> onResponse(AcWebRequest request, AcWebResponse response) async {
    log.add('$id:onResponse');
    return response;
  }
}

void main() {
  group('AcWeb Interceptors Verification', () {
    late AcWeb app;
    late List<String> executionLog;

    setUp(() {
      app = AcWeb();
      executionLog = [];
      
      // Register interceptors that can be looked up by name
      app.addInterceptor(SimpleInterceptor('GlobalInterceptor', executionLog));
      app.addInterceptor(SimpleInterceptor('ControllerInterceptor', executionLog));
      app.addInterceptor(SimpleInterceptor('MethodInterceptor', executionLog));
      
      // app.addInterceptor(AcWebJwtInterceptor(secret_key: 'test-secret', exclude_paths: ['/auth'])); // MOVED to specific test
      
      app.registerController(controllerClass: TestController);
    });

    test('Interceptor Chain Execution Order', () async {
      final routeKey = 'get>/hello';
      final routeDef = app.routeDefinitions[routeKey]!;
      
      final request = AcWebRequest.instanceFromJson({'url': '/hello', 'method': 'GET'});
      
      final response = await app.handleWebRequest(request, routeDef);

      expect(response.responseCode, AcEnumHttpResponseCode.ok);
      
      // Expected Order: 
      // Req: Global -> Controller -> Method
      // Res: Method -> Controller -> Global
      expect(executionLog, [
        'GlobalInterceptor:onRequest',
        'ControllerInterceptor:onRequest',
        'MethodInterceptor:onRequest',
        'MethodInterceptor:onResponse',
        'ControllerInterceptor:onResponse',
        'GlobalInterceptor:onResponse',
      ]);
    });

    test('Short-circuiting Interceptor', () async {
      final log = <String>[];
      final shortApp = AcWeb();
      
      shortApp.addInterceptor(SimpleInterceptor('Early', log));
      
      // Short-circuiting interceptor
      shortApp.addInterceptor(CallbackInterceptor('Short', 
        onRequest: (req) async => AcWebResponse.json(data: {'error': 'shorted'}, responseCode: AcEnumHttpResponseCode.unauthorized),
        onResponse: (req, res) async {
          log.add('Short:onResponse');
          return res;
        }
      ));
      
      shortApp.addInterceptor(SimpleInterceptor('Late', log));

      shortApp.get(url: '/test', handler: (args) async => AcWebResponse.json(data: 'ok'));

      final routeDef = shortApp.routeDefinitions['get>/test']!;
      final request = AcWebRequest.instanceFromJson({'url': '/test', 'method': 'GET'});
      
      final response = await shortApp.handleWebRequest(request, routeDef);

      expect(response.responseCode, AcEnumHttpResponseCode.unauthorized);
      expect(jsonDecode(jsonEncode(response.content))['error'], 'shorted');
      
      // Req: Early -> Short (Short returns response, Late skipped)
      // Res: Short -> Early
      expect(log, [
        'Early:onRequest',
        'Short:onResponse',
        'Early:onResponse',
      ]);
    });

     test('JWT Interceptor - Unauthorized', () async {
       app.addInterceptor(AcWebJwtInterceptor(secretKey: 'test-secret', excludePaths: ['/auth']));

        final routeDef = app.routeDefinitions['get>/secure']!;
       final request = AcWebRequest.instanceFromJson({
         'url': '/secure', 
         'method': 'GET',
         'headers': {} // No auth header
       });
       
       final response = await app.handleWebRequest(request, routeDef);
       expect(response.responseCode, AcEnumHttpResponseCode.unauthorized);
    });
  });
}

// Helper interceptor for testing
class CallbackInterceptor extends AcWebInterceptor {
  final String _name;
  final Future<AcWebResponse?> Function(AcWebRequest)? onRequestCb;
  final Future<AcWebResponse> Function(AcWebRequest, AcWebResponse)? onResponseCb;

  CallbackInterceptor(this._name, {Future<AcWebResponse?> Function(AcWebRequest)? onRequest, Future<AcWebResponse> Function(AcWebRequest, AcWebResponse)? onResponse})
    : onRequestCb = onRequest,
      onResponseCb = onResponse;

  @override
  String get name => _name;

  @override
  Future<AcWebResponse?> onRequest(AcWebRequest request) async => onRequestCb?.call(request);

  @override
  Future<AcWebResponse> onResponse(AcWebRequest request, AcWebResponse response) async => onResponseCb != null ? onResponseCb!(request, response) : response;
}

extension on AcWebJwtInterceptor {
  // name check
}
