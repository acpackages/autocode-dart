import 'package:test/test.dart';
import 'package:autocode/autocode.dart';

enum SampleEnum {
  alpha('ALPHA'),
  beta('BETA'),
  gamma('GAMMA');

  final String value;
  const SampleEnum(this.value);
}

class SampleChild {
  String name = '';
  int count = 0;

  SampleChild({this.name = '', this.count = 0});

  factory SampleChild.fromJson(Map<String, dynamic> json) {
    return SampleChild(
      name: AcJsonUtils.deserializeValue<String>(json['name'], defaultValue: '')!,
      count: AcJsonUtils.deserializeValue<int>(json['count'], defaultValue: 0)!,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'count': count,
  };
}

void main() {
  group('AcJsonUtils.deserializeValue Tests', () {
    test('Primitives and coercion', () {
      // int coercion
      expect(AcJsonUtils.deserializeValue<int>(42), equals(42));
      expect(AcJsonUtils.deserializeValue<int>('123'), equals(123));
      expect(AcJsonUtils.deserializeValue<int>(45.9), equals(45));
      expect(AcJsonUtils.deserializeValue<int>('invalid', defaultValue: 10), equals(10));
      expect(AcJsonUtils.deserializeValue<int>(null, defaultValue: 5), equals(5));

      // double coercion
      expect(AcJsonUtils.deserializeValue<double>(3.14), equals(3.14));
      expect(AcJsonUtils.deserializeValue<double>('2.718'), equals(2.718));
      expect(AcJsonUtils.deserializeValue<double>(10), equals(10.0));
      expect(AcJsonUtils.deserializeValue<double>('invalid', defaultValue: 1.0), equals(1.0));

      // bool coercion
      expect(AcJsonUtils.deserializeValue<bool>(true), isTrue);
      expect(AcJsonUtils.deserializeValue<bool>(false), isFalse);
      expect(AcJsonUtils.deserializeValue<bool>(1), isTrue);
      expect(AcJsonUtils.deserializeValue<bool>(0), isFalse);
      expect(AcJsonUtils.deserializeValue<bool>('true'), isTrue);
      expect(AcJsonUtils.deserializeValue<bool>('FALSE'), isFalse);
      expect(AcJsonUtils.deserializeValue<bool>('yes'), isTrue);
      expect(AcJsonUtils.deserializeValue<bool>('0'), isFalse);
      expect(AcJsonUtils.deserializeValue<bool>('invalid', defaultValue: false), isFalse);

      // String coercion
      expect(AcJsonUtils.deserializeValue<String>('hello'), equals('hello'));
      expect(AcJsonUtils.deserializeValue<String>(123), equals('123'));
      expect(AcJsonUtils.deserializeValue<String>(true), equals('true'));
      expect(AcJsonUtils.deserializeValue<String>(null, defaultValue: 'def'), equals('def'));
    });

    test('DateTime deserialization', () {
      final now = DateTime.utc(2026, 10, 14, 11, 0, 0);
      final isoStr = now.toIso8601String();

      expect(AcJsonUtils.deserializeValue<DateTime>(now), equals(now));
      expect(AcJsonUtils.deserializeValue<DateTime>(isoStr), equals(now));
      expect(
        AcJsonUtils.deserializeValue<DateTime>(now.millisecondsSinceEpoch),
        equals(now),
      );
      expect(
        AcJsonUtils.deserializeValue<DateTime>('invalid-date', defaultValue: now),
        equals(now),
      );
    });

    test('Enum deserialization with enumValues', () {
      expect(
        AcJsonUtils.deserializeValue<SampleEnum>('alpha', enumValues: SampleEnum.values),
        equals(SampleEnum.alpha),
      );
      expect(
        AcJsonUtils.deserializeValue<SampleEnum>('ALPHA', enumValues: SampleEnum.values),
        equals(SampleEnum.alpha),
      );
      expect(
        AcJsonUtils.deserializeValue<SampleEnum>('BETA', enumValues: SampleEnum.values),
        equals(SampleEnum.beta),
      );
      expect(
        AcJsonUtils.deserializeValue<SampleEnum>('unknown', enumValues: SampleEnum.values, defaultValue: SampleEnum.gamma),
        equals(SampleEnum.gamma),
      );
    });

    test('Custom model deserialization with fromJson', () {
      final json = {'name': 'Widget', 'count': '15'};
      final child = AcJsonUtils.deserializeValue<SampleChild>(
        json,
        fromJson: SampleChild.fromJson,
      );

      expect(child, isNotNull);
      expect(child!.name, equals('Widget'));
      expect(child.count, equals(15));
    });

    test('deserializeList tests', () {
      final rawList = ['1', '2', 3, '4'];
      final ints = AcJsonUtils.deserializeList<int>(rawList);
      expect(ints, equals([1, 2, 3, 4]));

      final rawChildren = [
        {'name': 'One', 'count': 1},
        {'name': 'Two', 'count': '2'},
      ];
      final children = AcJsonUtils.deserializeList<SampleChild>(
        rawChildren,
        fromJson: SampleChild.fromJson,
      );
      expect(children.length, equals(2));
      expect(children[0].name, equals('One'));
      expect(children[0].count, equals(1));
      expect(children[1].name, equals('Two'));
      expect(children[1].count, equals(2));
    });

    test('deserializeMap tests', () {
      final rawMap = {
        'first': {'name': 'A', 'count': 10},
        'second': {'name': 'B', 'count': 20},
      };
      final map = AcJsonUtils.deserializeMap<SampleChild>(
        rawMap,
        fromJson: SampleChild.fromJson,
      );
      expect(map.length, equals(2));
      expect(map['first']?.name, equals('A'));
      expect(map['first']?.count, equals(10));
      expect(map['second']?.name, equals('B'));
      expect(map['second']?.count, equals(20));
    });
  });
}
