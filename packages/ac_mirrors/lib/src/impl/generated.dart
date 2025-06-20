/// AOT-compatible implementation that uses generated code.
import '../api.dart';

Map<Type, AcClassMirror> generatedMirrorsMap = {};
bool isAcMirrorsInitialized = false;

// Public API functions
void initializeAcMirrors(Map<Type, AcClassMirror> mirrors) {
  generatedMirrorsMap = mirrors;
  isAcMirrorsInitialized = true;
}

void ensureAcMirrorsInitialized() {
  if (!isAcMirrorsInitialized) {
    throw StateError(
        'The ac_mirrors system has not been initialized. '
            'Please make sure you have run the build_runner and called `acMirrorsInitialize()` '
            'in your main() function.'
    );
  }
}

AcClassMirror<T> acReflectClass<T>(Type type) {
  ensureAcMirrorsInitialized();
  final mirror = generatedMirrorsMap[type];
  if (mirror == null) {
    throw ArgumentError('No reflector generated for type $T. Did you annotate it with @acReflectable?');
  }
  return mirror as AcClassMirror<T>;
}

AcInstanceMirror<T> acReflect<T extends Object>(T instance) {
  final classMirror = acReflectClass<T>(instance.runtimeType as Type);
  return AcInstanceMirrorImpl<T>(instance, classMirror);
}

// --- Implementation Classes ---

class AcInstanceMirrorImpl<T> implements AcInstanceMirror<T> {
  @override
  final T instance;

  @override
  final AcClassMirror<T> classMirror;

  AcInstanceMirrorImpl(this.instance, this.classMirror);

  @override
  dynamic getField(Symbol fieldName) {
    return classMirror.invoke(instance as Object, fieldName, []);
  }

  @override
  void setField(Symbol fieldName, dynamic value) {
    final setterName = Symbol('${symbolToName(fieldName)}=');
    classMirror.invoke(instance as Object, setterName, [value]);
  }

  @override
  dynamic invoke(Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    return classMirror.invoke(instance as Object, memberName, positionalArgs, namedArgs);
  }
}

String symbolToName(Symbol symbol) {
  return symbol.toString().split('"')[1];
}

// Base class for generated mirrors to provide common functionality.
abstract class GeneratedAcClassMirror<T> implements AcClassMirror<T> {
  const GeneratedAcClassMirror();
  @override
  dynamic invoke(
      Object target, Symbol memberName, List<dynamic> positionalArgs,
      [Map<Symbol, dynamic> namedArgs = const {}]);
}
