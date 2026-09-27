import '../enums/ac_enum_api_doc_asset_source.dart';
import '../enums/ac_enum_api_doc_renderer.dart';

class AcApiDocUiOptions {
  bool enabled;
  String urlPath;
  String jsonPath;
  String swaggerJsonPath;
  String title;
  AcEnumApiDocRenderer renderer;
  AcEnumApiDocAssetSource source;
  String? cdnVersion;
  String? directoryPath;
  Map<String, String>? files;
  String theme;
  String? customCss;

  AcApiDocUiOptions({
    this.enabled = true,
    this.urlPath = '/docs',
    this.jsonPath = '/docs/openapi.json',
    this.swaggerJsonPath = '/swagger/swagger.json',
    this.title = 'API Documentation',
    this.renderer = AcEnumApiDocRenderer.scalar,
    this.source = AcEnumApiDocAssetSource.cdn,
    this.cdnVersion,
    this.directoryPath,
    this.files,
    this.theme = 'auto',
    this.customCss,
  });
}
