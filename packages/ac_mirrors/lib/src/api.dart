/// The core API for the reflection system, designed to mimic `dart:mirrors`
/// while being compatible with AOT compilation through code generation.
///
/// To get an instance of these mirrors, use the top-level functions `acReflect()`
/// or `acReflectClass()`.

// --- Base Mirror Interfaces ---

/// A common interface for all reflected declarations (classes, methods, fields, etc.).
abstract class AcDeclarationMirror {
  /// The unqualified name of the declaration as a [Symbol].
  Symbol get simpleName;

  /// A list of metadata annotation instances attached to this declaration.
  List<Object> get metadata;

  /// Is this declaration marked as `static`?
  bool get isStatic;

  /// Is this declaration private (name starts with `_`)?
  bool get isPrivate;

  String getName();
}

// --- Specific Declaration Mirrors ---

/// Represents a reflected parameter of a method or constructor.
abstract class AcParameterMirror implements AcDeclarationMirror {
  /// The static [Type] of the parameter.
  Type get type;

  /// Is this parameter optional?
  bool get isOptional;

  /// Is this a named parameter (e.g., `{String name}`)?
  bool get isNamed;

  /// Does this parameter have a default value?
  bool get hasDefaultValue;
}

/// Represents a reflected variable declaration (field).
abstract class AcVariableMirror implements AcDeclarationMirror {
  /// The static [Type] of the variable.
  Type get type;

  /// Is this variable declared as `final`?
  bool get isFinal;

  /// Is this variable declared as `const`?
  bool get isConst;
}

/// Represents a reflected method or constructor.
abstract class AcMethodMirror implements AcDeclarationMirror {
  /// The return [Type] of the method. For constructors, this is the
  /// class type. For void methods, it's the `void` type.
  Type get returnType;

  /// An ordered list of the method's parameters.
  List<AcParameterMirror> get parameters;

  /// Is this a constructor?
  bool get isConstructor;

  /// Is this a getter? (a method with no parameters)
  bool get isGetter;

  /// Is this a setter? (a method with one required parameter and a `void` or `dynamic` return type)
  bool get isSetter;

  /// The name of a named constructor (e.g., `fromJson` for `MyClass.fromJson()`).
  /// Returns an empty string for unnamed constructors.
  String get constructorName;
}

/// Represents the reflected metadata of a class.
abstract class AcClassMirror<T> implements AcDeclarationMirror {
  @override
  Symbol get simpleName;

  /// The static [Type] that this mirror reflects.
  Type get reflectedType;

  /// A map of all instance members (methods, getters, setters, fields) declared in this class.
  Map<Symbol, AcDeclarationMirror> get instanceMembers;

  /// A map of all static members (methods, fields) declared in this class.
  Map<Symbol, AcDeclarationMirror> get staticMembers;

  /// A map of all constructors declared in this class.
  Map<String, AcMethodMirror> get constructors;

  /// A mirror on the superclass. Returns `null` if the superclass is `Object`.
  AcClassMirror? get superclass;

  /// A list of mirrors on the interfaces implemented by this class.
  List<AcClassMirror> get superinterfaces;

  /// Is this class declared as `abstract`?
  bool get isAbstract;

  /// Is this class an `enum`?
  bool get isEnum;

  /// Creates a new instance of the reflected class.
  ///
  /// - [constructorName] is the name of a named constructor (e.g., 'fromJson'). Use
  ///   an empty string `''` for the default, unnamed constructor.
  /// - [positionalArgs] is a list of positional arguments.
  /// - [namedArgs] is a map of named arguments.
  T newInstance(
      String constructorName,
      List<dynamic> positionalArgs,
      [Map<Symbol, dynamic> namedArgs = const {}]
      );

  /// Invokes a method on a target instance of the reflected class.
  /// This is the low-level method used by `AcInstanceMirror`.
  dynamic invoke(
      Object target,
      Symbol memberName,
      List<dynamic> positionalArgs,
      [Map<Symbol, dynamic> namedArgs = const {}]
      );
}

// --- Instance Mirror ---

/// Represents a reflected instance of an object.
abstract class AcInstanceMirror<T> {
  /// A mirror of the instance's class.
  AcClassMirror<T> get classMirror;

  /// The actual object instance being reflected.
  T get instance;

  /// Gets the value of a field on the instance.
  ///
  /// - [fieldName] is the symbol for the field to access.
  dynamic getField(Symbol fieldName);

  /// Sets the value of a field on the instance.
  ///
  /// - [fieldName] is the symbol for the field to modify.
  /// - [value] is the new value for the field.
  void setField(Symbol fieldName, dynamic value);

  /// Invokes an instance method (or getter/setter) on the object.
  ///
  /// - [memberName] is the symbol for the method to call.
  /// - [positionalArgs] is a list of positional arguments.
  /// - [namedArgs] is a map of named arguments.
  dynamic invoke(
      Symbol memberName,
      List<dynamic> positionalArgs,
      [Map<Symbol, dynamic> namedArgs = const {}]
      );
}
