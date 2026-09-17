import 'package:ac_mirrors/ac_mirrors.dart';

/* AcDoc({
  "summary": "An annotation to mark a route handler as returning a view.",
  "description": "This is a marker annotation used to identify a controller method that returns a response to be rendered by a view or template engine. The web framework can use this to differentiate between handlers that return data (like JSON) and those that return content to be rendered into a full HTML page.",
  "example": "@AcWebRoute(path: '/', method: 'GET')\n@AcWebView() // Marks this route as rendering a view.\nFuture<AcWebResponse> showHomePage() {\n  // The framework would take this response, find the 'home_page.template'\n  // file, and use a rendering engine to produce the final HTML.\n  return AcWebResponse.view(template: 'home_page.template');\n}"
}) */
@AcReflectable()
class AcWebView {
  /* AcDoc({
    "summary": "Creates the marker annotation for a view-rendering route."
  }) */
  const AcWebView();
}