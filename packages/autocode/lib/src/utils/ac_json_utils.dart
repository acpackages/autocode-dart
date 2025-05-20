import 'dart:convert';
import 'dart:mirrors';
import 'package:autocode/autocode.dart';

class AcJsonUtils {
  static Map<String, dynamic> getJsonDataFromInstance({
    required Object instance,
  }) {
    final result = <String, dynamic>{};
    final mirror = reflect(instance);
    final classMirror = mirror.type;

    for (final field in classMirror.declarations.values.whereType<VariableMirror>()) {
      final propertyName = field.simpleName;
      String jsonKey = MirrorSystem.getName(propertyName);
      final bindJsonAttributes = _getAcBindJsonPropertyAttributes(field);

      if (bindJsonAttributes.isNotEmpty) {
        final bindJsonAttribute = bindJsonAttributes[0];
        if (bindJsonAttribute.key != null) {
          jsonKey = bindJsonAttribute.key!;
        }
        if (bindJsonAttribute.skipInToJson == true) {
          continue;
        }
      }

      // Skip static fields
      if (field.isStatic) continue;

      var propertyValue = mirror.getField(propertyName).reflectee;
      if (propertyValue != null) {
        propertyValue = _getJsonForPropertyValue(propertyValue);
        result[jsonKey] = propertyValue;
      }
    }

    return result;
  }


  static dynamic _getJsonForPropertyValue(dynamic propertyValue) {
    if (propertyValue == null) return null;

    if (propertyValue is num || propertyValue is String || propertyValue is bool) {
      return propertyValue;
    }

    if (propertyValue is List) {
      return propertyValue.map((e) => _getJsonForPropertyValue(e)).toList();
    }

    if (propertyValue is Map) {
      return propertyValue.map((k, v) =>
          MapEntry(k.toString(), _getJsonForPropertyValue(v)));
    }

    if (propertyValue is Exception || propertyValue is Error) {
      return propertyValue.toString();
    }

    try {
      final mirror = reflect(propertyValue);
      final typeMirror = mirror.type;

      // Use `toJson` if available
      if (typeMirror.instanceMembers.containsKey(Symbol('toJson'))) {
        return mirror.invoke(Symbol('toJson'), []).reflectee;
      }

      // Otherwise fallback to `toString`
      return propertyValue.toString();
    } catch (_) {
      // In case of any unexpected reflection failure
      return propertyValue.toString();
    }
  }


  static Map<String, dynamic> instanceToJson({required Object instance}) {
    final mirror = reflect(instance);
    if (mirror.type.declarations.containsKey(#toJson)) {
      return mirror.invoke(#toJson, []).reflectee;
    } else {
      return getJsonDataFromInstance(instance: instance);
    }
  }

  static String prettyEncode(dynamic object) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(object);
  }

  static void setInstancePropertiesFromJsonData({
    required Object instance,
    required Map<String, dynamic> jsonData,
  }) {
    final mirror = reflect(instance);
    for (final field in mirror.type.declarations.values.whereType<VariableMirror>()) {
      _setInstancePropertyValueFromJson(
        mirror: mirror,
        field: field,
        jsonData: jsonData,
      );
    }
  }

  static void _setInstancePropertyValueFromJson({
    required InstanceMirror mirror,
    required VariableMirror field,
    required Map<String, dynamic> jsonData,
  }) {
    var propertyName = MirrorSystem.getName(field.simpleName);
    final bindJsonAttributes = _getAcBindJsonPropertyAttributes(field);
    Type? arrayType;
    if (bindJsonAttributes.isNotEmpty) {
      final bindJsonAttribute = bindJsonAttributes[0];
      if(bindJsonAttribute.key != null){
        propertyName = bindJsonAttribute.key!;
      }
      if (bindJsonAttribute.skipInFromJson == true) {
        return;
      }
      if (bindJsonAttribute.arrayType != null) {
        arrayType = bindJsonAttribute.arrayType;
      }
    }
    if (jsonData.containsKey(propertyName)) {

      var value = jsonData[propertyName];
      final fieldType = field.type;
      if (fieldType is ClassMirror) {
        if(value is List){
        }
        if (arrayType != null && value is List) {

          value = value.map((v) {
            final objectMirror = reflectClass(arrayType!)
                .newInstance(Symbol(''), []);
            final object = objectMirror.reflectee;

            setInstancePropertiesFromJsonData(
              instance: object,
              jsonData: v as Map<String, dynamic>,
            );

            return object;
          }).toList();
        } else if (value is Map) {

          final objectMirror =
          reflectClass(fieldType.reflectedType).newInstance(Symbol(''), []);
          final object = objectMirror.reflectee;

          setInstancePropertiesFromJsonData(
            instance: object,
            jsonData: Map.from(value),
          );

        }
      }
      mirror.setField(field.simpleName, value);
    }
  }


  static List<AcBindJsonProperty> _getAcBindJsonPropertyAttributes(
    VariableMirror field,
  ) {
    return field.metadata
        .where((m) => m.reflectee is AcBindJsonProperty)
        .map((m) => m.reflectee as AcBindJsonProperty)
        .toList();
  }
}
