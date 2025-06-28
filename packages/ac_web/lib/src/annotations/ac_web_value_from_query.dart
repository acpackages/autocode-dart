import 'package:ac_mirrors/ac_mirrors.dart';

/* AcDoc({
  "summary": "An annotation to inject a URL query parameter into a handler parameter.",
  "description": "This annotation is used to decorate a parameter in a controller method, instructing the web framework to extract a value from the URL's query string (the part after '?') and provide it as an argument for that parameter.",
  "example": "// For a route that handles requests like: /articles?category=tech\n\n@AcWebRoute(path: '/articles', method: 'GET')\nvoid listArticles(\n  @AcWebValueFromQuery(key: 'category') String category,\n) {\n  // If a request is made to '/articles?category=tech',\n  // the framework automatically injects the value:\n  // category will be 'tech'.\n  // ... handler logic to fetch articles in that category ...\n}"
}) */
@AcReflectable()
class AcWebValueFromQuery {
  /* AcDoc({
    "summary": "The name of the query parameter whose value should be injected.",
    "description": "This must match the key in the URL's query string (e.g., the 'sort' in '?sort=asc')."
  }) */
  final String key;

  /* AcDoc({
    "summary": "Creates an annotation to bind a method parameter to a URL query parameter.",
    "params": [
      {"name": "key", "description": "The name of the query parameter to extract the value from."}
    ]
  }) */
  const AcWebValueFromQuery({required this.key});
}