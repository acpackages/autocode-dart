extension AcListExtensions<T> on List<T> {
  List<S> castElements<S>() {
    return map((e) => e as S).toList();
  }

  List<T> difference(List<T> list) {
    return where((item) => !list.contains(item)).toList();
  }

  List<T> symmetricDifference(List<T> list) {
    final diff1 = where((item) => !list.contains(item));
    final diff2 = list.where((item) => !contains(item));
    return [...diff1, ...diff2];
  }

  List<T> intersection(List<T> list) {
    return where((item) => list.contains(item)).toList();
  }

  Map<String, dynamic> asMapAt(int index) {
    return this[index] as Map<String, dynamic>;
  }

  String asStringAt(int index) {
    return this[index] as String;
  }

  List<T> prepend(T value) {
    return [value, ...this];
  }

  Map<String, dynamic> mapByKey(String key) {
    final result = <String, dynamic>{};
    for (var element in this) {
      if (element is Map && element.containsKey(key)) {
        result[element[key].toString()] = element;
      }
    }
    return result;
  }

  List<T> union(List<T> list) {
    final result = [...this];
    for (var item in list) {
      if (!result.contains(item)) {
        result.add(item);
      }
    }
    return result;
  }

  List<T> distinct() {
    final result = <T>[];
    for (var item in this) {
      if (!result.contains(item)) {
        result.add(item);
      }
    }
    return result;
  }
}
