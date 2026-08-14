import 'package:ac_webview/ac_webview.dart';
import 'package:test/test.dart';

void main() {
  group('AcWebview tests', () {
    test('AcWebview initializes correctly', () {
      final webview = AcWebview(url: 'https://flutter.dev', useCef: true);
      expect(webview.url, equals('https://flutter.dev'));
      expect(webview.useCef, isTrue);
    });
  });
}
