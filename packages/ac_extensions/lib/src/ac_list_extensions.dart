import 'dart:core';
extension AcListExtensions<T> on List<T> {

  List<T> castTo<T>(){
    List<T> result = List<T>.empty(growable: true);
    forEach((element) {
      result.add(element as T);
    });
    return result;
  }

  List difference<T>(List<T> list) {
    return where((item) => !list.contains(item)).toList();
  }

  List differenceSymmetrical<T>(List<T> list) {
    final diff1 = where((item) => !list.contains(item));
    final diff2 = list.where((item) => !contains(item));
    return [...diff1, ...diff2];
  }

  List intersection<T>(List<T> list) {
    return where((item) => list.contains(item)).toList();
  }

  Map getMap(int index){
    return this[index] as Map;
  }

  String getString(int index){
    return this[index] as String;
  }

  List<T> prepend(T value) {
    return [value, ...this];
  }

  Map toMap(String key){
    Map<String,dynamic> result={};
    forEach((element) {
      Map elementMap = element as Map;
      result[elementMap[key]]=element;
    });
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

  List<T> uniqueValues(){
    List<T> result= List<T>.empty(growable: true);
    for(var item in this){
      if(!result.contains(item)){
        result.add(item);
      }
    }
    return result;
  }
}
