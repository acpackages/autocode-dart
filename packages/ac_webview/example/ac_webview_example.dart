import 'package:ac_webview/ac_webview.dart';

void main() {
  final webview = AcWebview(url: 'https://flutter.dev');
  print('AcWebview initialized with url: ${webview.url}');
}
