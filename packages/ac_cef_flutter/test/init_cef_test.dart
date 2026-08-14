import 'package:flutter_test/flutter_test.dart';
import 'package:ac_cef_flutter/ac_cef_flutter.dart';

void main() {
  group('initCef and default client getters', () {
    test('default state before initCef', () {
      expect(defaultCefNativeClient, isNull);
      expect(defaultCefClient, isNull);
      expect(isCefInitialized, isFalse);
    });
  });
}
