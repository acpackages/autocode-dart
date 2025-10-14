/* AcDoc({
  "description": "Full reactive system for Dart — includes AcReactiveValue, AcContext, AcReactiveList, and AcReactiveModel. Supports deep nested reactivity and fine-grained change listeners."
}) */

/// Reactive single value (like Vue’s `ref()` or Solid’s `signal()`).
class AcReactiveValue<T> {
  T _value;
  final List<void Function(T)> _listeners = [];

  AcReactiveValue(this._value);

  T get value => _value;
  set value(T newValue) {
    if (_value != newValue) {
      _value = newValue;
      _notify();
    }
  }

  void onChange(void Function(T) listener) => _listeners.add(listener);

  void _notify() {
    for (final listener in _listeners) {
      listener(_value);
    }
  }

  @override
  String toString() => 'AcReactiveValue($_value)';
}
