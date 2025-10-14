import 'ac_context.dart';
import 'ac_reactive_value.dart';

/// Reactive list with deep reactivity for nested elements.
class AcReactiveList {
  final List<dynamic> _list;
  final List<void Function()> _listeners = [];

  AcReactiveList([List<dynamic>? initial]) : _list = List.from(initial ?? []);

  dynamic operator [](int index) {
    var value = _list[index];
    if (value is Map<String, dynamic>) {
      value = _list[index] = AcContext(value:value);
    } else if (value is List) {
      value = _list[index] = AcReactiveList(value);
    }
    return value;
  }

  void operator []=(int index, dynamic value) {
    if (value is Map<String, dynamic>) {
      value = AcContext(value:value);
    } else if (value is List) {
      value = AcReactiveList(value);
    }
    _list[index] = value;
    _notify();
  }

  void add(dynamic value) {
    if (value is Map<String, dynamic>) {
      value = AcContext(value:value);
    } else if (value is List) {
      value = AcReactiveList(value);
    }
    _list.add(value);
    _notify();
  }

  void removeAt(int index) {
    _list.removeAt(index);
    _notify();
  }

  void onChange(void Function() listener) => _listeners.add(listener);

  void _notify() {
    for (final listener in _listeners) {
      listener();
    }
  }

  List<dynamic> toList() {
    return _list.map((v) {
      if (v is AcContext) return v.toMap();
      if (v is AcReactiveList) return v.toList();
      if (v is AcReactiveValue) return v.value;
      return v;
    }).toList();
  }

  @override
  String toString() => 'AcReactiveList($_list)';
}