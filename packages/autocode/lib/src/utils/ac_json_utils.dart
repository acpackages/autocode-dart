import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

class AcJsonUtils {
  /// Converts an object instance to a `Map<String, dynamic>` using ac_mirrors.
  static Map<String, dynamic> instanceToJson({required Object instance}) {
    final mirror = acReflect(instance);

    // First, try to invoke a `toJson()` method if the class defines one.
    if (mirror.classMirror.instanceMembers.containsKey(const Symbol('toJson'))) {
      try {
        final result = mirror.invoke(const Symbol('toJson'), []);
        // Ensure the result is of the correct type before returning.
        if (result is Map<String, dynamic>) {
          return result;
        }
      } catch (_) {
        // If invocation fails, fall back to field-by-field reflection.
      }
    }

    // Fallback to reflecting on each field individually.
    return getJsonDataFromInstance(instance: instance);
  }

  /// Reflects on an object's fields to build a JSON map.
  static Map<String, dynamic> getJsonDataFromInstance({
    required Object instance,
  }) {
    final result = <String, dynamic>{};
    final instanceMirror = acReflect(instance);
    final classMirror = instanceMirror.classMirror;

    // Iterate over all instance members provided by the AcClassMirror.
    for (final member in classMirror.instanceMembers.values) {
      // We are only interested in fields, not methods.
      if (member is! AcVariableMirror || member.isStatic) {
        continue;
      }

      final fieldSymbol = member.simpleName;
      String jsonKey = symbolToName(fieldSymbol);

      final bindProps = member.metadata.whereType<AcBindJsonProperty>().firstOrNull;

      if (bindProps != null) {
        if (bindProps.key != null) {
          jsonKey = bindProps.key!;
        }
        if (bindProps.skipInToJson == true) {
          continue;
        }
      }

      var propertyValue = instanceMirror.getField(fieldSymbol);
      if (propertyValue != null) {
        result[jsonKey] = getJsonForPropertyValue(propertyValue);
      }
    }
    return result;
  }

  /// RESTORED: Updates an existing object's properties from a JSON map.
  static void setInstancePropertiesFromJsonData({
    required Object instance,
    required Map<String, dynamic> jsonData,
  }) {
    final instanceMirror = acReflect(instance);
    final classMirror = instanceMirror.classMirror;
    // Iterate over all instance members to find fields to populate.
    for (final member in classMirror.instanceMembers.values) {
      print("Class Name : ${classMirror.simpleName} | Member Name : ${member.simpleName} | Is Variable Mirror : ${member is AcVariableMirror} | Is Static : ${member.isStatic} | Member Type : {${member.runtimeType}  " );
      if (member is AcVariableMirror && !member.isStatic) {
        setInstancePropertyValueFromJson(
          instanceMirror: instanceMirror,
          fieldMirror: member,
          jsonData: jsonData,
        );
      }
    }
  }

  /// RESTORED HELPER: Sets a single property on an instance from a JSON value.
  static void setInstancePropertyValueFromJson({
    required AcInstanceMirror instanceMirror,
    required AcVariableMirror fieldMirror,
    required Map<String, dynamic> jsonData,
  }) {
    final fieldSymbol = fieldMirror.simpleName;
    String jsonKey = symbolToName(fieldSymbol);
    Type? arrayType;

    final bindProps = fieldMirror.metadata.whereType<AcBindJsonProperty>().firstOrNull;

    if (bindProps != null) {
      if (bindProps.key != null) {
        jsonKey = bindProps.key!;
      }
      if (bindProps.skipInFromJson == true) {
        return;
      }
      arrayType = bindProps.arrayType;
    }

    if (jsonData.containsKey(jsonKey)) {
      final jsonValue = jsonData[jsonKey];
      final dartValue = convertJsonToDartValue(jsonValue, fieldMirror.type, arrayType);

      try {
        instanceMirror.setField(fieldSymbol, dartValue);
      } catch(e) {
        // This will often fail for final fields, which is expected.
        // You could add logging here if needed.
      }
    }
  }

  /// Converts a single JSON value to its corresponding Dart type.
  static dynamic convertJsonToDartValue(dynamic jsonValue, Type fieldType, Type? arrayType) {
    if (jsonValue == null) return null;

    if (arrayType != null && jsonValue is List) {
      return jsonValue.map((item) {
        if (item is Map<String, dynamic>) {
          // Use ac_mirrors to create a new instance of the list's generic type
          final newObject = acReflectClass(arrayType).newInstance("", []);
          setInstancePropertiesFromJsonData(instance: newObject, jsonData: item);
          return newObject;
        }
        return item; // It's a list of primitives
      }).toList();
    }

    if (jsonValue is Map<String, dynamic>) {
      // For a nested object, create a new instance and populate it.
      try {
        final newObject = acReflectClass(fieldType).newInstance("", []);
        setInstancePropertiesFromJsonData(instance: newObject, jsonData: jsonValue);
        return newObject;
      } catch (e) {
        return jsonValue; // return the raw map as a fallback
      }
    }

    // It's a primitive type (String, int, bool, double)
    return jsonValue;
  }


  /// Helper to recursively prepare a property's value for JSON encoding.
  static dynamic getJsonForPropertyValue(dynamic propertyValue) {
    if (propertyValue == null || propertyValue is num || propertyValue is String || propertyValue is bool) {
      return propertyValue;
    }
    if (propertyValue is List) {
      return propertyValue.map((e) => getJsonForPropertyValue(e)).toList();
    }
    if (propertyValue is Map) {
      return propertyValue.map((k, v) => MapEntry(k.toString(), getJsonForPropertyValue(v)));
    }
    if (propertyValue is Exception || propertyValue is Error) {
      return propertyValue.toString();
    }

    // For any other object, try to call instanceToJson on it recursively.
    return instanceToJson(instance: propertyValue);
  }


  /// Encodes an object to a pretty-printed JSON string.
  static String prettyEncode(dynamic object) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(object);
  }

  /// Helper to convert a Symbol like `Symbol("myField")` to the string "myField".
  static String symbolToName(Symbol symbol) {
    return symbol.toString().split('"')[1];
  }
}

class AcJsonUtilsTemp {

  static Map<String, dynamic> getJsonDataFromInstance({
    required Object instance,
  }) {
    final result = <String, dynamic>{};
    final instanceMirror = acReflect(instance);
    AcClassMirror? classMirror = instanceMirror.classMirror;
    while (classMirror != null && classMirror.reflectedType != Object) {
      print("Checking classmirror : ${classMirror.getName()})}");
      for (final field in classMirror.instanceMembers.values.whereType<AcVariableMirror>()) {
        final propertyName = field.simpleName;
        String jsonKey = field.getName();
        print("jsonKey in  getJsonDataFromInstance is : $jsonKey");
        // Skip static fields
        if (field.isStatic) continue;

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

        // Prevent overwriting keys from child class if already added
        if (!result.containsKey(jsonKey)) {
          var propertyValue = instanceMirror.getField(propertyName);
          print("PropertyValue is : $propertyValue");
          print(propertyValue);
          if (propertyValue != null) {
            propertyValue = _getJsonForPropertyValue(propertyValue);
            result[jsonKey] = propertyValue;
          }
        }
      }

      classMirror = classMirror.superclass;
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
      final mirror = acReflect(propertyValue);
      final typeMirror = mirror.classMirror;

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
    final mirror = acReflect(instance);
    if (mirror.classMirror.instanceMembers.containsKey(#toJson)) {
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
    final mirror = acReflect(instance);
    for (final field in mirror.classMirror.instanceMembers.values.whereType<AcVariableMirror>()) {
      _setInstancePropertyValueFromJson(
        mirror: mirror,
        field: field,
        jsonData: jsonData,
      );
    }
  }

  static void _setInstancePropertyValueFromJson({
    required AcInstanceMirror mirror,
    required AcVariableMirror field,
    required Map<String, dynamic> jsonData,
  }) {
    // var propertyName = MirrorSystem.getName(field.simpleName);
    String propertyName = field.getName();
    print("propertyName in  _setInstancePropertyValueFromJson is : $propertyName");
    print(propertyName);
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
      if (fieldType is AcClassMirror) {
        if(value is List){
        }
        if (arrayType != null && value is List) {

          value = value.map((v) {
            final objectMirror = acReflectClass(arrayType!)
                .newInstance("", []);
            final object = objectMirror.reflectee;

            setInstancePropertiesFromJsonData(
              instance: object,
              jsonData: v as Map<String, dynamic>,
            );

            return object;
          }).toList();
        } else if (value is Map) {

          final objectMirror = acReflectClass(fieldType.runtimeType).newInstance("", []);
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
      AcVariableMirror field,
      ) {
    return field.metadata
        .where((m) => m is AcBindJsonProperty)
        .map((m) => m as AcBindJsonProperty)
        .toList();
  }
}
