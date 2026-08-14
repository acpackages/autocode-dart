import 'package:ac_cef/ac_cef.dart';
import 'package:test/test.dart';

void main() {
  group('CefApp lifecycle', () {
    test('CefApp singleton creates in newApp state', () {
      final app = CefApp.getInstance();
      expect(app.getState(), equals(CefAppState.newApp));
      expect(app.isStarted, isFalse);
    });
  });
}
