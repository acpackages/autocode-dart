import 'dart:io';
import '../enums/ac_enum_api_doc_asset_source.dart';
import '../enums/ac_enum_api_doc_renderer.dart';
import '../models/ac_api_doc_ui_options.dart';

class AcApiDocUiHandler {
  final AcApiDocUiOptions options;

  AcApiDocUiHandler({required this.options});

  String getHtml() {
    switch (options.renderer) {
      case AcEnumApiDocRenderer.scalar:
        return _getScalarHtml();
      case AcEnumApiDocRenderer.swaggerUi:
        return _getSwaggerUiHtml();
      case AcEnumApiDocRenderer.redoc:
        return _getRedocHtml();
      case AcEnumApiDocRenderer.rapidoc:
        return _getRapiDocHtml();
      case AcEnumApiDocRenderer.elements:
        return _getElementsHtml();
    }
  }

  String _getScalarHtml() {
    final customCssBlock = options.customCss != null && options.customCss!.isNotEmpty
        ? '<style>${options.customCss}</style>'
        : '';
    final themeAttribute = options.theme != 'auto' ? 'data-theme="${options.theme}"' : '';

    return '''<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>${options.title}</title>
    $customCssBlock
  </head>
  <body>
    <script
      id="api-reference"
      data-url="${options.jsonPath}"
      $themeAttribute>
    </script>
    <script src="https://cdn.jsdelivr.net/npm/@scalar/api-reference"></script>
  </body>
</html>''';
  }

  String _getSwaggerUiHtml() {
    final version = options.cdnVersion ?? '5.11.0';
    final customCssBlock = options.customCss != null && options.customCss!.isNotEmpty
        ? '<style>${options.customCss}</style>'
        : '';

    return '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>${options.title}</title>
  <link rel="stylesheet" type="text/css" href="https://unpkg.com/swagger-ui-dist@$version/swagger-ui.css" />
  <link rel="icon" type="image/png" href="https://unpkg.com/swagger-ui-dist@$version/favicon-32x32.png" sizes="32x32" />
  <style>
    html { box-sizing: border-box; overflow-y: scroll; }
    *, *:before, *:after { box-sizing: inherit; }
    body { margin: 0; background: #fafafa; }
  </style>
  $customCssBlock
</head>
<body>
  <div id="swagger-ui"></div>
  <script src="https://unpkg.com/swagger-ui-dist@$version/swagger-ui-bundle.js"></script>
  <script src="https://unpkg.com/swagger-ui-dist@$version/swagger-ui-standalone-preset.js"></script>
  <script>
    window.onload = function() {
      window.ui = SwaggerUIBundle({
        url: "${options.jsonPath}",
        dom_id: '#swagger-ui',
        deepLinking: true,
        presets: [
          SwaggerUIBundle.presets.apis,
          SwaggerUIStandalonePreset
        ],
        layout: "StandaloneLayout"
      });
    };
  </script>
</body>
</html>''';
  }

  String _getRedocHtml() {
    final version = options.cdnVersion ?? 'latest';
    final customCssBlock = options.customCss != null && options.customCss!.isNotEmpty
        ? '<style>${options.customCss}</style>'
        : '';

    return '''<!DOCTYPE html>
<html>
  <head>
    <title>${options.title}</title>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://fonts.googleapis.com/css?family=Montserrat:300,400,700|Roboto:300,400,700" rel="stylesheet">
    <style>body { margin: 0; padding: 0; }</style>
    $customCssBlock
  </head>
  <body>
    <redoc spec-url="${options.jsonPath}"></redoc>
    <script src="https://cdn.redoc.ly/redoc/$version/bundles/redoc.standalone.js"></script>
  </body>
</html>''';
  }

  String _getRapiDocHtml() {
    final theme = options.theme == 'light' ? 'light' : 'dark';
    final customCssBlock = options.customCss != null && options.customCss!.isNotEmpty
        ? '<style>${options.customCss}</style>'
        : '';

    return '''<!doctype html>
<html>
  <head>
    <meta charset="utf-8">
    <title>${options.title}</title>
    <script type="module" src="https://unpkg.com/rapidoc/dist/rapidoc-min.js"></script>
    $customCssBlock
  </head>
  <body>
    <rapi-doc
      spec-url="${options.jsonPath}"
      theme="$theme"
      render-style="read"
      show-header="false"
      allow-try="true"
    ></rapi-doc>
  </body>
</html>''';
  }

  String _getElementsHtml() {
    final customCssBlock = options.customCss != null && options.customCss!.isNotEmpty
        ? '<style>${options.customCss}</style>'
        : '';

    return '''<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>${options.title}</title>
    <script src="https://unpkg.com/@stoplight/elements/web-components.min.js"></script>
    <link rel="stylesheet" href="https://unpkg.com/@stoplight/elements/styles.min.css">
    $customCssBlock
  </head>
  <body>
    <elements-api apiDescriptionUrl="${options.jsonPath}" router="hash" layout="sidebar" />
  </body>
</html>''';
  }

  String? getAssetContent({required String relativePath}) {
    if (options.source == AcEnumApiDocAssetSource.injectedMap && options.files != null) {
      return options.files![relativePath];
    } else if (options.source == AcEnumApiDocAssetSource.directory && options.directoryPath != null) {
      final file = File('${options.directoryPath}/$relativePath');
      if (file.existsSync()) {
        return file.readAsStringSync();
      }
    }
    return null;
  }
}
