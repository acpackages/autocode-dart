import 'ac_context.dart';

/// Reactive model that wraps AcContext for object-like access.
abstract class AcReactiveModel {
  final AcContext context;

  AcReactiveModel(Map<String, dynamic> value) : context = AcContext(value:value);

  dynamic operator [](String key) => context[key];
  void operator []=(String key, dynamic value) => context[key] = value;

  void onPropertyChange({required String key,required void Function(dynamic) callback}) =>
      context.onPropertyChange(key: key, callback: callback);

  void onPathChange({required String path,required void Function(dynamic) callback}) =>
      context.onPathChange(path:path, callback:callback);

  Map<String, dynamic> toMap() => context.toMap();
}