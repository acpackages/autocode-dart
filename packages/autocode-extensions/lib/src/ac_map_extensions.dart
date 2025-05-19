import 'dart:convert';
import 'dart:core';
import 'dart:math';
import 'package:autocode_extensions/src/ac_list_extensions.dart';

extension AcMapExtensions on Map {

  Map<K,V> castMap<K,V>(){
    Map<K,V> result=<K,V>{};
    forEach((key, value) {
      result[key as K]= value as V;
    });
    return result;
  }

  Map<String, Map<String, dynamic>> changes(Map newMap) {
    final result = <String, Map<String, dynamic>>{};

    newMap.forEach((key, newValue) {
      if (!containsKey(key)) {
        result[key] = {'old': null, 'new': newValue, 'change': 'add'};
      } else if (this[key] != newValue) {
        result[key] = {'old': this[key], 'new': newValue, 'change': 'modify'};
      }
    });

    forEach((key, oldValue) {
      if (!newMap.containsKey(key)) {
        result[key] = {'old': oldValue, 'new': null, 'change': 'remove'};
      }
    });

    return result;
  }

  Map<String, dynamic> clone() {
    return jsonDecode(jsonEncode(this)) as Map<String, dynamic>;
  }

  void copyFrom(Map source) {
    source.forEach((key, value) {
      this[key] = value;
    });
  }

  void copyTo(Map destination) {
    forEach((key, value) {
      destination[key] = value;
    });
  }

  Map filter(bool Function(dynamic key, dynamic value) test) {
    final result = {};
    forEach((key, value) {
      if (test(key, value)) {
        result[key] = value;
      }
    });
    return result;
  }

  dynamic get(dynamic key){
    dynamic result;
    if (containsKey(key)) {
      result = this[key];
    }
    return result;
  }

  bool getBool(dynamic key){
    bool result=false;
    if (containsKey(key)) {
      if(this[key]!=null) {
        result = this[key] as bool;
      }
    }
    return result;
  }

  double getDouble(dynamic key, {int round=0}){
    double result=0;
    if (containsKey(key)) {
      if(this[key]!=null) {
        result = double.parse(this[key].toString());
      }
    }
    if (round > 0) {
      num mod = pow(10.0, round);
      result = ((result * mod).round().toDouble() / mod);
    }
    return result;
  }

  int getInt(dynamic key){
    int result=0;
    if (containsKey(key)) {
      if(this[key]!=null) {
        result = int.parse(this[key].toString());
      }
    }
    return result;
  }

  List<T> getList<T>(dynamic key,{bool growable = true}){
    List<T> result=List.empty(growable: growable);
    if (containsKey(key)) {
      if(this[key]!=null && this[key] is List) {
        if (T == dynamic) {
          result = (this[key] as List<dynamic>).cast<T>();
        }
        else if (T == Map<String,dynamic>) {
          List<Map<String,dynamic>> response = List.empty(growable: true);
          for(var value in (this[key] as List<dynamic>)){
            response.add(Map.from(value));
          }
          result = response as List<T>;
        } else {
          List<T> response = List.empty(growable: true);
          for(var value in (this[key] as List<dynamic>)){
            response.add(value);
          }
          result = response;
        }
      }
    }
    return result;
  }

  Map<K,V> getMap<K,V>(dynamic key){
    Map<K,V> result={};
    if (containsKey(key)) {
      if(this[key]!=null) {
        result = this[key].cast<K,V>();
      }
    }
    return result;
  }

  String getString(dynamic key){
    String result="";
    if (containsKey(key)) {
      if(this[key]!=null) {
        result = this[key].toString();
      }
    }
    return result;
  }

  Map merge(Map contraMap){
    contraMap.forEach((key, value) {
      this[key]=value;
    });
    return this;
  }

  bool isSame(Map other) {
    return jsonEncode(this) == jsonEncode(other);
  }

  put(Object key,dynamic value){
    this[key]=value;
  }

  putNestedMapValue(String key,dynamic value){
    if(key.indexOf("[")>0) {
      key=key.replaceAll("]","");
      List<String> keysList = key.split("[");
      Map<int,Map> mapTree={};
      for (int i = 0; i < keysList.length-1; i++) {
        Map currentMap={};
        if(i==0){
          if(containsKey(keysList[i])){
            currentMap=Map.from(getMap(keysList[i]));
          }
          else{
            mapTree[i]={};
          }
        }
        else if(i>0){
          Map previousMap=Map.from(mapTree.getMap(i-1));
          if(previousMap.containsKey(keysList[i])){
            currentMap=previousMap.getMap(keysList[i]);
          }
        }
        mapTree[i]=currentMap;
      }
      Map lastMap=mapTree[keysList.length-2]!;
      lastMap[keysList.last]=value;
      mapTree[keysList.length-2]!=lastMap;
      for (int i = keysList.length-2; i > 0 ; i--) {
        Map parentMap=mapTree.getMap(i-1);
        Map childMap=mapTree.getMap(i);
        parentMap[keysList[i]]=childMap;
        mapTree[i-1]=parentMap;
      }
      this[keysList.first]=mapTree[0];
    }
  }

  String toQueryString() {
    return Uri(queryParameters: cast<String, dynamic>()).query;
  }

  List<T> toValuesList<T>(){
    return values.toList().castTo<T>();
  }
}