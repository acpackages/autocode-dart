import 'package:autocode/autocode.dart';
import 'ac_reactive_list.dart';
import 'ac_reactive_value.dart';

/// Reactive map/object that supports deep reactivity.
class AcContext {
  final Map<String, dynamic> _data = {};
  final AcEvents _events = AcEvents();
  final AcEvents _propertyEvents = AcEvents();

  AcContext({Map<String, dynamic>? value = const {}}) {
    if (value != null) {
      value.forEach((k, v) => this[k] = v);
    }
  }

  dynamic operator [](String key) {
    var value = _data[key];
    if (value is Map<String, dynamic>) {
      value = _data[key] = AcContext(value:value);
    } else if (value is List) {
      value = _data[key] = AcReactiveList(value);
    }
    return value;
  }

  void operator []=(String key, dynamic value) {
    if (value is Map<String, dynamic>) {
      value = AcContext(value:value);
    } else if (value is List) {
      value = AcReactiveList(value);
    }
    _data[key] = value;
    _notify(key, value);
  }

  String on({required String event,required void Function(dynamic) callback}) {
    return _events.subscribe(event: event, callback: callback);
  }

  String onPropertyChange({required String key,required void Function(dynamic) callback}) {
    return _propertyEvents.subscribe(event: key, callback: callback);
  }

  void _notify(String key, dynamic value) {
    _propertyEvents.execute(key: key,args: [value]);
    _events.execute(key: 'change',args: [{'key':key,'value':value}]);
  }

  /// Deep reactive listener like "user.address.city"
  void onPathChange({required String path,required void Function(dynamic) callback}) {
    final parts = path.split('.');
    if (parts.length == 1) {
      onPropertyChange(key:parts.first,callback:callback);
      return;
    }

    final head = parts.first;
    final tail = parts.skip(1).join('.');
    final child = this[head];

    if (child is AcContext) {
      child.onPathChange(path:tail, callback:callback);
    } else {
      onPropertyChange(key:head, callback: (v) {
        if (v is AcContext) v.onPathChange(path:tail, callback:callback);
      });
    }
  }

  /// Convert nested reactive structures into plain Maps.
  Map<String, dynamic> toMap() {
    return _data.map((k, v) {
      if (v is AcContext) return MapEntry(k, v.toMap());
      if (v is AcReactiveList) return MapEntry(k, v.toList());
      if (v is AcReactiveValue) return MapEntry(k, v.value);
      return MapEntry(k, v);
    });
  }

  @override
  String toString() => 'AcContext($_data)';
}
