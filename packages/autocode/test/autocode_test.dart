import 'package:test/test.dart';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

@AcReflectable()
class NestedModel {
  String name;
  int value;

  NestedModel({this.name = '', this.value = 0});

  factory NestedModel.fromJson(Map<String, dynamic> json) {
    final instance = NestedModel();
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: instance, jsonData: json);
    return instance;
  }

  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }
}

@AcReflectable()
class ParentModel {
  @AcBindJsonProperty(arrayType: NestedModel)
  Map<String, NestedModel>? mapOfObjects;

  ParentModel({this.mapOfObjects});

  factory ParentModel.fromJson(Map<String, dynamic> json) {
    final instance = ParentModel();
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: instance, jsonData: json);
    return instance;
  }

  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }
}

void main() {
  group('AcJsonUtils Map Deserialization Tests', () {
    test('Should deserialize Map<String, CustomClass> correctly', () {
      final jsonMap = {
        'mapOfObjects': {
          'first': {'name': 'Alice', 'value': 42},
          'second': {'name': 'Bob', 'value': 99},
        }
      };

      final parent = ParentModel.fromJson(jsonMap);

      expect(parent.mapOfObjects, isNotNull);
      expect(parent.mapOfObjects!.length, equals(2));
      expect(parent.mapOfObjects!['first'], isA<NestedModel>());
      expect(parent.mapOfObjects!['first']!.name, equals('Alice'));
      expect(parent.mapOfObjects!['first']!.value, equals(42));
      expect(parent.mapOfObjects!['second']!.name, equals('Bob'));
      expect(parent.mapOfObjects!['second']!.value, equals(99));

      // Test serialization back to JSON
      final serialized = parent.toJson();
      expect(serialized['mapOfObjects']['first']['name'], equals('Alice'));
      expect(serialized['mapOfObjects']['first']['value'], equals(42));
    });

    test('Should serialize and deserialize custom value enums correctly', () {
      final json = {'propertyName': 'COLUMN_TITLE'};
      final container = EnumContainer.fromJson(json);
      expect(container.propertyName, equals(TestEnum.columnTitle));

      final serialized = container.toJson();
      expect(serialized['propertyName'], equals('COLUMN_TITLE')); // Should serialize to string value/name
    });
  });
}

@AcReflectable()
enum TestEnum {
  columnTitle("COLUMN_TITLE"),
  required("REQUIRED"),
  unknown("UNKNOWN");

  final String value;
  const TestEnum(this.value);
}

@AcReflectable()
class EnumContainer {
  TestEnum propertyName;

  EnumContainer({this.propertyName = TestEnum.unknown});

  factory EnumContainer.fromJson(Map<String, dynamic> json) {
    final instance = EnumContainer();
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: instance, jsonData: json);
    return instance;
  }

  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }
}
