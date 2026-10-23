import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
/* AcDoc({
  "description": "Provides utility functions for converting Dart objects to and from JSON using reflection via `ac_mirrors`. Supports nested objects, arrays, and field-level annotations such as `@AcBindJsonProperty`.",
}) */

class AcJsonUtils {
  /* AcDoc({
    "description": "Converts an object to a JSON map. If the object defines a `toJson()` method, it will be used. Otherwise, falls back to field-by-field reflection using `ac_mirrors`.",
    "parameters": {
      "instance": {
        "type": "Object",
        "description": "The object to serialize into a JSON-compatible map."
      }
    },
    "returns": {
      "type": "Map<String, dynamic>",
      "description": "The resulting map that represents the object's data in JSON-compatible format."
    }
  }) */
  static Map<String, dynamic> instanceToJson({required Object instance}) {
    try {
      final mirror = acReflect(instance);

      if (mirror.classMirror.instanceMembers.containsKey(
          const Symbol('toJson'))) {
        try {
          final result = mirror.invoke(const Symbol('toJson'), []);
          if (result is Map<String, dynamic>) {
            return result;
          }
        } catch (_) {}
      }

      return getJsonDataFromInstance(instance: instance);
    }
    catch(ex,stack){
      print("Error instance to json");
      print(stack);
      print(instance.runtimeType);
      throw ex;
    }
  }

  /* AcDoc({
    "description": "Reflects over all fields of the given object instance and converts them into key-value pairs for JSON serialization. Handles @AcBindJsonProperty annotations for custom key mapping or exclusions.",
    "parameters": {
      "instance": {
        "type": "Object",
        "description": "The object instance whose fields will be read and serialized."
      }
    },
    "returns": {
      "type": "Map<String, dynamic>",
      "description": "A map containing all serializable fields of the object."
    }
  }) */
  static Map<String, dynamic> getJsonDataFromInstance({
    required Object instance,
  }) {
    var result = <String, dynamic>{};
    if(instance is Map){
      result = Map.from(instance);
    }
    else{
      try {
        final instanceMirror = acReflect(instance);
        final classMirror = instanceMirror.classMirror;

        for (final member in classMirror.instanceMembers.values) {
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
      } catch (_) {}
    }

    return result;
  }

  /* AcDoc({
    "description": "Populates an existing object instance with values from a JSON map. Uses `ac_mirrors` to reflectively set field values, including support for nested objects and arrays.",
    "parameters": {
      "instance": {
        "type": "Object",
        "description": "The object instance to populate with data."
      },
      "jsonData": {
        "type": "Map<String, dynamic>",
        "description": "A JSON map containing data to assign to the instance's fields."
      }
    }
  }) */
  static void setInstancePropertiesFromJsonData({
    required Object instance,
    required Map<String, dynamic> jsonData,
  }) {
    if (jsonData.isEmpty) return;
    try {
      final instanceMirror = acReflect(instance);
      final classMirror = instanceMirror.classMirror;
      for (final member in classMirror.instanceMembers.values) {
        if (member is AcVariableMirror && !member.isStatic) {
          setInstancePropertyValueFromJson(
            instanceMirror: instanceMirror,
            fieldMirror: member,
            jsonData: jsonData,
          );
        }
      }
    } catch (_) {}
  }

  /* AcDoc({
    "description": "Sets a single property on an object instance from a JSON map using field metadata and type conversion.",
    "parameters": {
      "instanceMirror": {
        "type": "AcInstanceMirror",
        "description": "The mirror of the object instance being modified."
      },
      "fieldMirror": {
        "type": "AcVariableMirror",
        "description": "The mirror describing the field to update."
      },
      "jsonData": {
        "type": "Map<String, dynamic>",
        "description": "The JSON data containing the value to assign."
      }
    }
  }) */
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
      } catch (e) {}
    }
  }

  /* AcDoc({
    "description": "Converts a raw JSON value into its expected Dart type, including instantiating nested classes, arrays, and enums.",
    "parameters": {
      "jsonValue": {
        "type": "dynamic",
        "description": "The JSON value to convert."
      },
      "fieldType": {
        "type": "Type",
        "description": "The expected Dart type of the target field."
      },
      "arrayType": {
        "type": "Type?",
        "description": "If the field is a list, the type of the list elements."
      }
    },
    "returns": {
      "type": "dynamic",
      "description": "A Dart-typed value converted from the input JSON."
    }
  }) */
  static dynamic convertJsonToDartValue(dynamic jsonValue, Type fieldType, Type? arrayType) {
    if (jsonValue == null) return null;

    // Skip enum handling for dynamic type
    if (fieldType == dynamic) {
      return jsonValue;
    }

    if(fieldType == DateTime){
      return DateTime.parse(jsonValue);
    }

    // Handle enums
    try {
      final classMirror = acReflectClass(fieldType);
      if (classMirror.isEnum && jsonValue is String) {
        try {
          // Try to invoke static fromValue method using ac_mirrors
          final fromValueResult = (classMirror as dynamic).invoke(null, const Symbol('fromValue'), [jsonValue]);
          return fromValueResult;
        } catch (e) {
          // Fallback to invoking the enum value directly
          try {
            return (classMirror as dynamic).invoke(null, Symbol(jsonValue), []);
          } catch (e) {
            throw ArgumentError('Cannot convert "$jsonValue" to enum $fieldType: $e');
          }
        }
      }
    } catch (e) {
      // If reflection fails (e.g., no mirror for fieldType), return jsonValue as-is
      return jsonValue;
    }

    if (arrayType != null && jsonValue is List) {
      return jsonValue.map((item) {
        if (item is Map<String, dynamic>) {
          final newObject = acReflectClass(arrayType).newInstance("", []);
          setInstancePropertiesFromJsonData(instance: newObject, jsonData: item);
          return newObject;
        }
        return item;
      }).toList();
    }

    if (jsonValue is Map<String, dynamic>) {
      try {
        final newObject = acReflectClass(fieldType).newInstance("", []);
        setInstancePropertiesFromJsonData(instance: newObject, jsonData: jsonValue);
        return newObject;
      } catch (e) {
        return jsonValue;
      }
    }

    return jsonValue;
  }

  /* AcDoc({
    "description": "Recursively processes any object and prepares it for JSON encoding. Supports primitives, lists, maps, and nested model objects.",
    "parameters": {
      "propertyValue": {
        "type": "dynamic",
        "description": "The object or value to serialize to JSON."
      }
    },
    "returns": {
      "type": "dynamic",
      "description": "The JSON-safe representation of the input value."
    }
  }) */
  static dynamic getJsonForPropertyValue(dynamic propertyValue) {
    try {
      if (propertyValue == null || propertyValue is num ||
          propertyValue is String || propertyValue is bool) {
        return propertyValue;
      }
      if (propertyValue is List) {
        return propertyValue.map((e) => getJsonForPropertyValue(e)).toList();
      }
      if (propertyValue is Map) {
        return propertyValue.map((k, v) =>
            MapEntry(k.toString(), getJsonForPropertyValue(v)));
      }

      if(propertyValue is DateTime){
        return propertyValue.toIso8601String();
      }
      if (propertyValue is Exception || propertyValue is Error) {
        return propertyValue.toString();
      }

      return instanceToJson(instance: propertyValue);
    }catch(ex,stack){
      return null;
    }
  }

  /* AcDoc({
    "description": "Encodes any Dart object into a pretty-printed JSON string.",
    "parameters": {
      "object": {
        "type": "dynamic",
        "description": "The object to convert to a pretty JSON string."
      }
    },
    "returns": {
      "type": "String",
      "description": "The pretty-printed JSON representation."
    }
  }) */
  static String prettyEncode(dynamic object) {
    final encoder = JsonEncoder.withIndent('  ', (dynamic nonEncodable) {
      if (nonEncodable is DateTime) {
        return nonEncodable.toIso8601String();
      }
      if (nonEncodable is Enum) {
        return nonEncodable.name;
      }
      try {
        return (nonEncodable as dynamic).toJson();
      } catch (_) {
        return nonEncodable.toString();
      }
    });
    return encoder.convert(object);
  }

  /* AcDoc({
    "description": "Extracts the string name from a Dart Symbol like Symbol(\"field\") => \"field\".",
    "parameters": {
      "symbol": {
        "type": "Symbol",
        "description": "The symbol to convert to a string."
      }
    },
    "returns": {
      "type": "String",
      "description": "The name represented by the symbol."
    }
  }) */
  static String symbolToName(Symbol symbol) {
    return symbol.toString().split('"')[1];
  }

  static dynamic serializeValue(dynamic val) {
    if (val == null || val is num || val is String || val is bool) {
      return val;
    }
    if (val is DateTime) {
      return val.toIso8601String();
    }
    try {
      return (val as dynamic).toJson();
    } catch (_) {}
    if (val is Enum) {
      try {
        return (val as dynamic).value;
      } catch (_) {
        return val.name;
      }
    }
    if (val is List) {
      return val.map(serializeValue).toList();
    }
    if (val is Iterable) {
      return val.map((e) => serializeValue(e)).toList();
    }
    if (val is Map) {
      return val.map((k, v) => MapEntry(k.toString(), serializeValue(v)));
    }
    try {
      return AcJsonUtils.getJsonForPropertyValue(val);
    } catch (_) {
      return val.toString();
    }
  }

  /* AcDoc({
    "description": "Deserializes a raw JSON value into the specified Dart type T without reflection.",
    "parameters": {
      "val": {"type": "dynamic", "description": "The raw JSON value."},
      "defaultValue": {"type": "T?", "description": "Fallback value if val is null or unparseable."},
      "fromJson": {"type": "T Function(Map<String, dynamic> json)?", "description": "Factory function for model classes."},
      "customParser": {"type": "T Function(dynamic raw)?", "description": "Custom parser function for custom transformations."},
      "enumValues": {"type": "List<T>?", "description": "List of enum values for enum deserialization."}
    },
    "returns": {"type": "T?", "description": "The deserialized value or defaultValue."}
  }) */
  static T? deserializeValue<T>(
    dynamic val, {
    T? defaultValue,
    T Function(Map<String, dynamic> json)? fromJson,
    T Function(dynamic raw)? customParser,
    List<T>? enumValues,
  }) {
    if (val == null) return defaultValue;

    // 1. Direct type match
    if (val is T) return val;

    // 2. Custom parser takes priority
    if (customParser != null) {
      try {
        return customParser(val) ?? defaultValue;
      } catch (_) {
        return defaultValue;
      }
    }

    // 3. Custom Model / Object with fromJson factory
    if (fromJson != null) {
      if (val is Map<String, dynamic>) {
        return fromJson(val);
      } else if (val is Map) {
        return fromJson(val.cast<String, dynamic>());
      }
      return defaultValue;
    }

    // 4. Primitives and Coercion based on generic type T
    if (T == int || defaultValue is int) {
      if (val is num) return val.toInt() as T;
      if (val is String) {
        final parsed = int.tryParse(val.trim());
        if (parsed != null) return parsed as T;
      }
      return defaultValue;
    }

    if (T == double || defaultValue is double) {
      if (val is num) return val.toDouble() as T;
      if (val is String) {
        final parsed = double.tryParse(val.trim());
        if (parsed != null) return parsed as T;
      }
      return defaultValue;
    }

    if (T == num || defaultValue is num) {
      if (val is num) return val as T;
      if (val is String) {
        final parsed = num.tryParse(val.trim());
        if (parsed != null) return parsed as T;
      }
      return defaultValue;
    }

    if (T == String || defaultValue is String) {
      return val.toString() as T;
    }

    if (T == bool || defaultValue is bool) {
      if (val is bool) return val as T;
      if (val is num) return (val != 0) as T;
      if (val is String) {
        final lower = val.trim().toLowerCase();
        if (lower == 'true' || lower == '1' || lower == 'yes') return true as T;
        if (lower == 'false' || lower == '0' || lower == 'no') return false as T;
      }
      return defaultValue;
    }

    // 5. DateTime Parsing
    if (T == DateTime || defaultValue is DateTime) {
      if (val is DateTime) return val as T;
      if (val is String) {
        final parsed = DateTime.tryParse(val.trim());
        if (parsed != null) return parsed as T;
      }
      if (val is num) {
        final ms = val.toInt();
        return DateTime.fromMillisecondsSinceEpoch(
          ms < 10000000000 ? ms * 1000 : ms,
          isUtc: true,
        ) as T;
      }
      return defaultValue;
    }

    // 6. Enum parsing (when enumValues is provided)
    if (enumValues != null) {
      final valStr = val.toString().trim().toLowerCase();
      for (final e in enumValues) {
        if (e is Enum) {
          if (e.name.toLowerCase() == valStr) return e;
          try {
            if ((e as dynamic).value.toString().toLowerCase() == valStr) return e;
          } catch (_) {}
        }
      }
      return defaultValue;
    }

    return defaultValue;
  }

  /// Convenience deserializer for typed lists
  static List<T> deserializeList<T>(
    dynamic val, {
    T Function(Map<String, dynamic> json)? fromJson,
    T Function(dynamic raw)? itemParser,
    List<T>? enumValues,
  }) {
    if (val == null || val is! List) return [];
    final results = <T>[];
    for (final item in val) {
      final deserialized = deserializeValue<T>(
        item,
        fromJson: fromJson,
        customParser: itemParser,
        enumValues: enumValues,
      );
      if (deserialized != null) {
        results.add(deserialized);
      }
    }
    return results;
  }

  /// Convenience deserializer for typed maps
  static Map<String, V> deserializeMap<V>(
    dynamic val, {
    V Function(Map<String, dynamic> json)? fromJson,
    V Function(dynamic raw)? valueParser,
    List<V>? enumValues,
  }) {
    if (val == null || val is! Map) return {};
    final results = <String, V>{};
    val.forEach((k, v) {
      final key = k.toString();
      final deserialized = deserializeValue<V>(
        v,
        fromJson: fromJson,
        customParser: valueParser,
        enumValues: enumValues,
      );
      if (deserialized != null) {
        results[key] = deserialized;
      }
    });
    return results;
  }
}