/// VM-based implementation that uses `dart:mirrors`.
import 'dart:mirrors' as mirrors;
import '../api.dart';

// Public API functions
void initializeAcMirrors(Map<Type, AcClassMirror> mirrors) {
  // No-op on the VM, as reflection is available at runtime.
}
AcClassMirror<T> acReflectClass<T>(Type type) => AcClassMirrorImpl<T>(mirrors.reflectClass(type));
AcInstanceMirror<T> acReflect<T extends Object>(T instance) => AcInstanceMirrorImpl<T>(mirrors.reflect(instance));

// --- Implementation Classes ---

class AcParameterMirrorImpl implements AcParameterMirror {
  final mirrors.ParameterMirror _mirror;
  AcParameterMirrorImpl(this._mirror);

  @override Type get type => _mirror.type.reflectedType;
  @override bool get isOptional => _mirror.isOptional;
  @override bool get isNamed => _mirror.isNamed;
  @override bool get hasDefaultValue => _mirror.hasDefaultValue;
  @override Symbol get simpleName => _mirror.simpleName;
  @override List<Object> get metadata => List<Object>.of(_mirror.metadata.map((m) => m.reflectee));
  @override bool get isStatic => false;
  @override bool get isPrivate => _mirror.isPrivate;
  @override String getName() => mirrors.MirrorSystem.getName(simpleName);
}

class AcVariableMirrorImpl implements AcVariableMirror {
  final mirrors.VariableMirror _mirror;
  AcVariableMirrorImpl(this._mirror);

  @override Type get type => _mirror.type.reflectedType;
  @override bool get isFinal => _mirror.isFinal;
  @override bool get isConst => _mirror.isConst;
  @override Symbol get simpleName => _mirror.simpleName;
  @override List<Object> get metadata => List<Object>.of(_mirror.metadata.map((m) => m.reflectee));
  @override bool get isStatic => _mirror.isStatic;
  @override bool get isPrivate => _mirror.isPrivate;
  @override String getName() => mirrors.MirrorSystem.getName(simpleName);
}

class AcMethodMirrorImpl implements AcMethodMirror {
  final mirrors.MethodMirror _mirror;
  AcMethodMirrorImpl(this._mirror);

  @override Type get returnType => _mirror.returnType.reflectedType;
  @override List<AcParameterMirror> get parameters => _mirror.parameters.map((p) => AcParameterMirrorImpl(p)).toList();
  @override bool get isConstructor => _mirror.isConstructor;
  @override bool get isGetter => _mirror.isGetter;
  @override bool get isSetter => _mirror.isSetter;
  @override String get constructorName => _mirror.isConstructor ? mirrors.MirrorSystem.getName(_mirror.constructorName) : '';
  @override Symbol get simpleName => _mirror.simpleName;
  @override List<Object> get metadata => List<Object>.of(_mirror.metadata.map((m) => m.reflectee));
  @override bool get isStatic => _mirror.isStatic;
  @override bool get isPrivate => _mirror.isPrivate;
  @override String getName() => mirrors.MirrorSystem.getName(simpleName);
}

class AcClassMirrorImpl<T> implements AcClassMirror<T> {
  final mirrors.ClassMirror _mirror;
  AcClassMirrorImpl(this._mirror);

  @override Symbol get simpleName => _mirror.simpleName;
  @override Type get reflectedType => _mirror.reflectedType;
  @override bool get isAbstract => _mirror.isAbstract;
  @override bool get isEnum => _mirror.isEnum;
  @override List<Object> get metadata => List<Object>.of(_mirror.metadata.map((m) => m.reflectee));
  @override bool get isStatic => false;
  @override bool get isPrivate => _mirror.isPrivate;
  @override String getName() => mirrors.MirrorSystem.getName(simpleName);

  @override Map<Symbol, AcDeclarationMirror> get instanceMembers {
    final result = <Symbol, AcDeclarationMirror>{};
    var currentMirror = _mirror;
    while (currentMirror.superclass != null) {
      currentMirror.declarations.forEach((symbol, declaration) {
        if (declaration.isPrivate || _isStatic(declaration)) return;
        if (declaration is mirrors.MethodMirror && declaration.isConstructor) return;
        if (_isSynthetic(declaration)) return;

        result.putIfAbsent(symbol, () {
          if (declaration is mirrors.MethodMirror) return AcMethodMirrorImpl(declaration);
          return AcVariableMirrorImpl(declaration as mirrors.VariableMirror);
        });
      });
      currentMirror = currentMirror.superclass!;
    }
    return result;
  }

  @override Map<Symbol, AcDeclarationMirror> get staticMembers => _transformDeclarations(_mirror.staticMembers, isStatic: true);

  @override AcClassMirror? get superclass => _mirror.superclass == null || _mirror.superclass!.reflectedType == Object
      ? null
      : AcClassMirrorImpl(_mirror.superclass!);

  @override List<AcClassMirror> get superinterfaces => _mirror.superinterfaces.map((i) => AcClassMirrorImpl(i)).toList();

  @override Map<String, AcMethodMirror> get constructors {
    final result = <String, AcMethodMirror>{};
    _mirror.declarations.values.whereType<mirrors.MethodMirror>().where((m) => m.isConstructor && !_isSynthetic(m)).forEach((m) {
      final name = mirrors.MirrorSystem.getName(m.constructorName);
      result[name] = AcMethodMirrorImpl(m);
    });
    return result;
  }

  @override T newInstance(String constructorName, List positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    return _mirror.newInstance(Symbol(constructorName), positionalArgs, namedArgs).reflectee as T;
  }

  @override dynamic invoke(Object target, Symbol memberName, List positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    return mirrors.reflect(target).invoke(memberName, positionalArgs, namedArgs).reflectee;
  }

  bool _isStatic(mirrors.DeclarationMirror d) {
    if (d is mirrors.MethodMirror) return d.isStatic;
    if (d is mirrors.VariableMirror) return d.isStatic;
    return false;
  }

  /// Helper to safely check the `isSynthetic` property.
  bool _isSynthetic(mirrors.DeclarationMirror d) {
    if (d is mirrors.MethodMirror) return d.isSynthetic;
    // FIX: VariableMirror does not have isSynthetic. Fields are never synthetic.
    if (d is mirrors.VariableMirror) return false;
    return false;
  }

  Map<Symbol, AcDeclarationMirror> _transformDeclarations(Map<Symbol, mirrors.DeclarationMirror> declarations, {bool isStatic = false}) {
    final result = <Symbol, AcDeclarationMirror>{};
    declarations.forEach((key, value) {
      if (_isSynthetic(value)) return;
      if (isStatic && !_isStatic(value)) return;

      if (value is mirrors.MethodMirror) {
        if (!value.isConstructor) result[key] = AcMethodMirrorImpl(value);
      }
      if (value is mirrors.VariableMirror) result[key] = AcVariableMirrorImpl(value);
    });
    return result;
  }
}

class AcInstanceMirrorImpl<T> implements AcInstanceMirror<T> {
  final mirrors.InstanceMirror _mirror;
  AcInstanceMirrorImpl(this._mirror);

  @override T get instance => _mirror.reflectee as T;
  @override AcClassMirror<T> get classMirror => AcClassMirrorImpl<T>(_mirror.type);
  @override dynamic getField(Symbol fieldName) => _mirror.getField(fieldName).reflectee;
  @override void setField(Symbol fieldName, dynamic value) => _mirror.setField(fieldName, value);
  @override dynamic invoke(Symbol memberName, List positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    return _mirror.invoke(memberName, positionalArgs, namedArgs).reflectee;
  }
}
