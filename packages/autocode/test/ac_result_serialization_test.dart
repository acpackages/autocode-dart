import 'package:test/test.dart';
import 'package:autocode/autocode.dart';

void main() {
  group('AcResult Reflection-Free Serialization Tests', () {
    test('Should serialize and deserialize success result with primitive value', () {
      final result = AcResult()..setSuccess(value: 'test_token', message: 'Logged in');
      final json = result.toJson();

      expect(json['code'], equals(AcResult.codeSuccess));
      expect(json['status'], equals('success'));
      expect(json['message'], equals('Logged in'));
      expect(json['value'], equals('test_token'));

      final restored = AcResult.instanceFromJson(jsonData: json);
      expect(restored.isSuccess(), isTrue);
      expect(restored.code, equals(AcResult.codeSuccess));
      expect(restored.message, equals('Logged in'));
      expect(restored.value, equals('test_token'));
    });

    test('Should serialize and deserialize failure and exception result', () {
      final result = AcResult()..setFailure(message: 'Invalid credentials');
      final json = result.toJson();

      expect(json['status'], equals('failure'));
      expect(json['code'], equals(AcResult.codeFailure));
      expect(json['message'], equals('Invalid credentials'));

      final restored = AcResult.instanceFromJson(jsonData: json);
      expect(restored.isFailure(), isTrue);
      expect(restored.message, equals('Invalid credentials'));
    });

    test('Should serialize and deserialize complex nested value (List and Map)', () {
      final data = {
        'user': {'id': 123, 'name': 'Admin'},
        'roles': ['admin', 'manager'],
        'time': DateTime.utc(2026, 1, 1).toIso8601String(),
      };
      final result = AcResult()..setSuccess(value: data);
      final json = result.toJson();

      final restored = AcResult.instanceFromJson(jsonData: json);
      expect(restored.isSuccess(), isTrue);
      expect(restored.value, isA<Map>());
      expect(restored.value['user']['name'], equals('Admin'));
      expect(restored.value['roles'], equals(['admin', 'manager']));
    });

    test('Should handle string-based codes gracefully', () {
      final json = {
        'code': '1',
        'status': 'success',
        'message': 'OK',
        'value': 42,
      };
      final restored = AcResult.instanceFromJson(jsonData: json);
      expect(restored.isSuccess(), isTrue);
      expect(restored.code, equals(1));
      expect(restored.value, equals(42));
    });
  });
}
