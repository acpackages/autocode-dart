import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';
import 'package:ac_web/ac_web.dart';
import 'package:ac_web_on_jaguar/ac_web_on_jaguar.dart';
const classAnnotation = AcReflectable();

/// A sample annotation to place on a method.
class MethodMeta {
  final String description;
  const MethodMeta(this.description);
}

/// A sample annotation to place on a field.
class FieldMeta {
  final bool isSensitive;
  const FieldMeta({this.isSensitive = false});
}


// --- Supporting Base Class and Interface ---

@acReflectable
abstract class Person {
  final String name;

  Person(this.name);


  String getGreeting();
}

@acReflectable
abstract class Loggable {
  void log(String message);
}


// --- Main Customer Class ---

/// A comprehensive Customer class designed to test all features of ac_mirrors.
@classAnnotation // Using a meta-annotation
class Customer extends Person implements Loggable {

  // --- Static Members ---

  /// A static, constant field.
  static const String defaultCountry = 'USA';

  /// A static, mutable field.
  static int totalCustomers = 0;

  /// A static method.
  @MethodMeta('Creates a guest customer object.')
  static Customer createGuest() {
    totalCustomers++;
    return Customer.named(id: -1, name: 'Guest', email: 'guest@example.com');
  }

  // --- Instance Fields ---

  /// A final, public field with an annotation.
  @FieldMeta(isSensitive: true)
  final int id;

  /// A final, public field inherited from Person.
  @override
  final String name;

  /// A mutable, public field.
  String email;

  /// A private field, accessible via a getter/setter.
  String? _notes;

  // --- Constructors ---

  /// A const default constructor.
  Customer({
    required this.id,
    required this.name,
    required this.email
  }) : super(name);

  /// A public named constructor.
  Customer.named({
    required this.id,
    required this.name,
    required this.email
  }) : super(name);

  // --- Getters and Setters ---

  /// A public getter for a private field.
  String? get notes => _notes;

  /// A public setter for a private field.
  set notes(String? value) {
    _notes = value;
  }

  // --- Instance Methods ---

  @override
  @MethodMeta('Generates a standard greeting.')
  String getGreeting() {
    return 'Hello, $name!';
  }

  /// A public instance method with a parameter.
  void updateEmail(String newEmail) {
    email = newEmail;
  }

  @override
  void log(String message) {
    print('LOG [Customer ID: $id]: $message');
  }
}
