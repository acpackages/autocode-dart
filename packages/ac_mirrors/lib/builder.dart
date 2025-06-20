import 'dart:async';
import 'dart:convert';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:build/build.dart';
import 'package:crypto/crypto.dart';
import 'package:source_gen/source_gen.dart';
import 'package:ac_mirrors/annotations.dart';
import 'package:glob/glob.dart';

Builder acMirrorsBuilder(BuilderOptions options) {
  return const AcMirrorsAggregatingBuilder();
}

class AcMirrorsAggregatingBuilder implements Builder {
  const AcMirrorsAggregatingBuilder();

  void log(String message) {
    print('[ac_mirrors_builder] $message');
  }

  @override
  final buildExtensions = const {
    r'$lib$': ['_ac_generated/ac_mirrors_generated_code.acg.dart']
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final uniqueClasses = <ClassElement>{};
    final reflectableChecker = TypeChecker.fromRuntime(AcReflectable);
    log("Starting build step. Scanning for reflectable annotations...");

    // This logic recursively finds ALL reachable libraries.
    final allReachableLibraries = <LibraryElement>{};
    final processingQueue = <LibraryElement>[];

    // 1. Seed the queue with all libraries in the current package's /lib folder.
    await for (final inputId in buildStep.findAssets(Glob('lib/**.dart'))) {
      if (await buildStep.resolver.isLibrary(inputId)) {
        processingQueue.add(await buildStep.resolver.libraryFor(inputId));
      }
    }

    log("Found ${processingQueue.length} top-level libraries in this package. Discovering all reachable files...");

    // 2. Process the queue, adding all imported and exported libraries to it.
    int processedCount = 0;
    while (processingQueue.isNotEmpty) {
      final current = processingQueue.removeAt(0);
      if (allReachableLibraries.contains(current) || current.isInSdk) continue;

      log("    -> Discovering library [${++processedCount}]: ${current.source.uri}");
      allReachableLibraries.add(current);

      processingQueue.addAll(current.importedLibraries);
      processingQueue.addAll(current.exportedLibraries);
    }

    log("Completed discovery. Scanning ${allReachableLibraries.length} total libraries for annotations.");

    for (final library in allReachableLibraries) {
      log(" -> Scanning file: ${library.source.uri}");
      final reader = LibraryReader(library);
      for (final classElement in reader.classes) {
        if (reflectableChecker.hasAnnotationOfExact(classElement)) {
          log("    > Found direct annotation on: ${classElement.name}");
          uniqueClasses.add(classElement);
          continue;
        }

        for (final metadata in classElement.metadata) {
          final annotationElement = metadata.element;
          if (annotationElement == null) continue;

          Element? elementToInspectForAnnotation;
          if (annotationElement is ConstructorElement) {
            elementToInspectForAnnotation = annotationElement.enclosingElement;
          } else if (annotationElement is PropertyAccessorElement) {
            elementToInspectForAnnotation = annotationElement.variable;
          }

          if (elementToInspectForAnnotation != null && reflectableChecker.hasAnnotationOfExact(elementToInspectForAnnotation)) {
            log("    > Found meta-annotation on: ${classElement.name} via ${elementToInspectForAnnotation.name}");
            uniqueClasses.add(classElement);
            break;
          }
        }
      }
    }

    if (uniqueClasses.isNotEmpty) {
      log("Found ${uniqueClasses.length} reflectable classes. Generating mirrors file...");
      final outputId = AssetId(buildStep.inputId.package, 'lib/_ac_generated/ac_mirrors_generated_code.acg.dart');
      final buffer = StringBuffer();
      generateFileContent(buffer, uniqueClasses);

      log("Writing generated file to ${outputId.path} (will overwrite if it exists)...");
      await buildStep.writeAsString(outputId, buffer.toString());
      log("Successfully generated ${outputId.path}.");
    } else {
      log("No reflectable classes found. Nothing to generate.");
    }
  }

  void generateFileContent(StringBuffer buffer, Set<ClassElement> classes) {
    final allUris = <Uri>{};
    for (final classEl in classes) {
      collectUris(classEl, allUris);
    }

    writeHeader(buffer, allUris);

    for (final classEl in classes) {
      generateDeclarationMirrors(buffer, classEl);
    }

    for (final classEl in classes) {
      generateClassMirror(buffer, classEl);
    }

    writeFooterAndInitializer(buffer, classes);
  }

  void collectUris(ClassElement classEl, Set<Uri> uris) {
    ClassElement? current = classEl;
    while(current != null && current.name != 'Object') {
      uris.add(current.library.source.uri);
      for (final member in getAllDeclarations(current)) {
        for (final meta in member.metadata) {
          final metaElement = meta.element;
          if (metaElement?.library?.source.uri != null) {
            uris.add(metaElement!.library!.source.uri);
          }
        }
        if (member is FieldElement) {
          final typeElement = member.type.element;
          if (typeElement?.library?.source.uri != null) {
            uris.add(typeElement!.library!.source.uri);
          }
        } else if (member is ExecutableElement) {
          final returnTypeElement = member.returnType.element;
          if (returnTypeElement?.library?.source.uri != null) {
            uris.add(returnTypeElement!.library!.source.uri);
          }
          for (final param in member.parameters) {
            final paramTypeElement = param.type.element;
            if (paramTypeElement?.library?.source.uri != null) {
              uris.add(paramTypeElement!.library!.source.uri);
            }
          }
        }
      }
      final supertype = current.supertype;
      current = (supertype?.element is ClassElement) ? supertype!.element as ClassElement : null;
    }
  }

  void writeHeader(StringBuffer buffer, Set<Uri> uris) {
    log("Writing file header and imports.");
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// ignore_for_file: constant_identifier_names, non_constant_identifier_names, unnecessary_brace_in_string_interps, unused_import, unnecessary_lambdas, prefer_const_constructors, prefer_const_literals_to_create_immutables');
    buffer.writeln("import 'package:ac_mirrors/ac_mirrors.dart';");
    buffer.writeln("import 'package:ac_mirrors/src/impl/generated.dart';");
    for(final uri in uris.where((u) => u.scheme != 'dart')) {
      buffer.writeln("import '$uri';");
    }
    buffer.writeln('');
    buffer.writeln('String _symbolToName(Symbol symbol) => symbol.toString().split(\'\\"\')[1];\n');
  }

  String generateMirrorName(Element element) {
    final uniqueId = '${element.library!.source.uri}::${element.enclosingElement?.name}::${element.name}';
    final bytes = utf8.encode(uniqueId);
    final digest = sha1.convert(bytes);
    return 'M${digest.toString().substring(0, 16)}';
  }

  String _generateMetadataSource(List<ElementAnnotation> metadata) {
    return metadata.map((m) {
      try {
        final constant = m.computeConstantValue();
        return constant != null ? _dartObjectToSource(constant) : '';
      } catch (e) {
        log("  > WARNING: Could not compute constant value for annotation. Falling back to source. This may fail for cross-class constants. Error: $e");
        return m.toSource().substring(1);
      }
    }).where((s) => s.isNotEmpty).join(', ');
  }

  String _dartObjectToSource(DartObject object) {
    final reader = ConstantReader(object);

    if (reader.isNull) return 'null';
    if (reader.isBool) return reader.boolValue.toString();
    if (reader.isDouble) return reader.doubleValue.toString();
    if (reader.isInt) return reader.intValue.toString();
    if (reader.isString) return "'${reader.stringValue.replaceAll("'", "\\'")}'";
    if (reader.isList) return 'const [${reader.listValue.map(_dartObjectToSource).join(', ')}]';
    if (reader.isMap) {
      final entries = reader.mapValue.entries.map((e) => '${_dartObjectToSource(e.key!)}: ${_dartObjectToSource(e.value!)}').join(', ');
      return 'const {$entries}';
    }
    if (reader.isType) return reader.typeValue.getDisplayString(withNullability: false);

    final variable = object.variable;
    if (variable != null) {
      if (variable.enclosingElement is ClassElement) {
        return '${variable.enclosingElement!.name}.${variable.name}';
      }
      return variable.name ?? '';
    }

    final revived = reader.revive();
    final typeName = revived.source.fragment.isEmpty ? revived.accessor : revived.source.fragment;
    final accessor = revived.accessor.isNotEmpty && revived.accessor != typeName ? '.${revived.accessor}' : '';

    final positionalArgs = revived.positionalArguments.map(_dartObjectToSource).join(', ');
    final namedArgs = revived.namedArguments.entries.map((e) => '${e.key}: ${_dartObjectToSource(e.value)}').join(', ');
    final allArgs = [positionalArgs, namedArgs].where((s) => s.isNotEmpty).join(', ');

    return 'const $typeName$accessor($allArgs)';
  }

  void generateDeclarationMirrors(StringBuffer buffer, ClassElement classEl) {
    log("Generating declaration mirrors for class '${classEl.name}'.");
    for (final declaration in getAllDeclarations(classEl).where((d) => !d.isSynthetic)) {
      final mirrorName = generateMirrorName(declaration);
      log(" -> Generating declaration mirror '$mirrorName' for '${declaration.name}' (${declaration.runtimeType})");
      final metadata = _generateMetadataSource(declaration.metadata);

      String getReturnTypeLine(ExecutableElement e) {
        final typeString = e.returnType.isVoid ? 'dynamic' : e.returnType.getDisplayString(withNullability: false);
        return '  @override Type get returnType => $typeString;';
      }

      String getSimpleNameLine(Element e) {
        return "  @override Symbol get simpleName => const Symbol('${e.name}');";
      }

      String getNameLine(Element e) {
        return "  @override String getName() => '${e.name}';";
      }

      if (declaration is ConstructorElement) {
        buffer.writeln("// Mirror for constructor '${declaration.name}' in class '${classEl.name}'");
        buffer.writeln('class ${mirrorName} implements AcMethodMirror {');
        buffer.writeln('  const ${mirrorName}();');
        buffer.writeln(getSimpleNameLine(declaration));
        buffer.writeln(getNameLine(declaration));
        buffer.writeln('  @override bool get isStatic => false;');
        buffer.writeln('  @override bool get isPrivate => ${declaration.isPrivate};');
        buffer.writeln('  @override List<Object> get metadata => const [$metadata];');
        buffer.writeln(getReturnTypeLine(declaration));
        buffer.writeln('  @override bool get isConstructor => true;');
        buffer.writeln('  @override bool get isGetter => false;');
        buffer.writeln('  @override bool get isSetter => false;');
        buffer.writeln('  @override String get constructorName => "${declaration.name}";');
        buffer.writeln('  @override List<AcParameterMirror> get parameters => const [];');
        buffer.writeln('}');
      } else if (declaration is MethodElement) {
        buffer.writeln("// Mirror for method '${declaration.name}' in class '${classEl.name}'");
        buffer.writeln('class ${mirrorName} implements AcMethodMirror {');
        buffer.writeln('  const ${mirrorName}();');
        buffer.writeln(getSimpleNameLine(declaration));
        buffer.writeln(getNameLine(declaration));
        buffer.writeln('  @override bool get isStatic => ${declaration.isStatic};');
        buffer.writeln('  @override bool get isPrivate => ${declaration.isPrivate};');
        buffer.writeln('  @override List<Object> get metadata => const [$metadata];');
        buffer.writeln(getReturnTypeLine(declaration));
        buffer.writeln('  @override bool get isConstructor => false;');
        buffer.writeln('  @override bool get isGetter => false;');
        buffer.writeln('  @override bool get isSetter => false;');
        buffer.writeln('  @override String get constructorName => "";');
        buffer.writeln('  @override List<AcParameterMirror> get parameters => const [];');
        buffer.writeln('}');
      } else if (declaration is PropertyAccessorElement) {
        buffer.writeln("// Mirror for accessor '${declaration.name}' in class '${classEl.name}'");
        buffer.writeln('class ${mirrorName} implements AcMethodMirror {');
        buffer.writeln('  const ${mirrorName}();');
        buffer.writeln(getSimpleNameLine(declaration));
        buffer.writeln(getNameLine(declaration));
        buffer.writeln('  @override bool get isStatic => ${declaration.isStatic};');
        buffer.writeln('  @override bool get isPrivate => ${declaration.isPrivate};');
        buffer.writeln('  @override List<Object> get metadata => const [$metadata];');
        buffer.writeln(getReturnTypeLine(declaration));
        buffer.writeln('  @override bool get isConstructor => false;');
        buffer.writeln('  @override bool get isGetter => ${declaration.isGetter};');
        buffer.writeln('  @override bool get isSetter => ${declaration.isSetter};');
        buffer.writeln('  @override String get constructorName => "";');
        buffer.writeln('  @override List<AcParameterMirror> get parameters => const [];');
        buffer.writeln('}');
      } else if (declaration is FieldElement) {
        buffer.writeln("// Mirror for field '${declaration.name}' in class '${classEl.name}'");
        buffer.writeln('class ${mirrorName} implements AcVariableMirror {');
        buffer.writeln('  const ${mirrorName}();');
        buffer.writeln(getSimpleNameLine(declaration));
        buffer.writeln(getNameLine(declaration));
        buffer.writeln('  @override bool get isStatic => ${declaration.isStatic};');
        buffer.writeln('  @override bool get isPrivate => ${declaration.isPrivate};');
        buffer.writeln('  @override List<Object> get metadata => const [$metadata];');
        buffer.writeln('  @override Type get type => ${declaration.type.getDisplayString(withNullability: false)};');
        buffer.writeln('  @override bool get isFinal => ${declaration.isFinal};');
        buffer.writeln('  @override bool get isConst => ${declaration.isConst};');
        buffer.writeln('}');
      }
    }
    buffer.writeln('');
  }

  void generateClassMirror(StringBuffer buffer, ClassElement classEl) {
    final className = classEl.name;
    final classMirrorName = generateMirrorName(classEl);
    log("Generating class mirror '$classMirrorName' for class '$className'.");

    final typeParams = classEl.typeParameters.isNotEmpty
        ? '<${classEl.typeParameters.map((p) => p.name).join(', ')}>'
        : '';
    final classNameWithTypeParams = '$className$typeParams';

    buffer.writeln("// Mirror for class '${classEl.name}' from ${classEl.library.source.uri}");
    buffer.writeln('class $classMirrorName extends GeneratedAcClassMirror<$classNameWithTypeParams> {');

    buffer.writeln("  const $classMirrorName();");
    buffer.writeln("  @override final Symbol simpleName = const Symbol('$className');");
    buffer.writeln('  @override final Type reflectedType = $className;');
    buffer.writeln('  @override final bool isAbstract = ${classEl.isAbstract};');
    buffer.writeln('  @override bool get isEnum => ${classEl is EnumElement};');
    buffer.writeln('  @override final bool isStatic = false;');
    buffer.writeln('  @override final bool isPrivate = ${classEl.isPrivate};');
    buffer.writeln('  @override final List<Object> metadata = const [${_generateMetadataSource(classEl.metadata)}];');
    buffer.writeln('  @override String getName() => "$className";');

    final superclass = classEl.supertype?.element;
    if (superclass != null && superclass.name != 'Object') {
      buffer.writeln('  @override AcClassMirror? get superclass => acReflectClass(${superclass.name});');
    } else {
      buffer.writeln('  @override AcClassMirror? get superclass => null;');
    }
    buffer.writeln('  @override List<AcClassMirror> get superinterfaces => const [];');

    final instanceMembers = <Symbol, Element>{};
    for(final member in getAllDeclarations(classEl).where((d) => !_isStatic(d) && d is! ConstructorElement)) {
      if(member.isSynthetic) continue;
      instanceMembers.putIfAbsent(Symbol(member.name!), () => member);
    }

    log("  -> Found ${instanceMembers.length} non-synthetic instance members for '$className'.");
    buffer.writeln('  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {');
    for(final member in instanceMembers.values) {
      final mirrorName = generateMirrorName(member);
      log("    -> Mapping instance member '${member.name}' to its mirror '$mirrorName'.");
      buffer.writeln("    const Symbol('${member.name}'): const ${mirrorName}(),");
    }
    buffer.writeln('  };');

    buffer.writeln('  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};');

    buffer.writeln('  @override Map<String, AcMethodMirror> get constructors => const {');
    if (!classEl.isAbstract) {
      final nonSyntheticConstructors = classEl.constructors.where((c) => !c.isSynthetic);
      log("  -> Found ${nonSyntheticConstructors.length} non-synthetic constructors for '$className'.");
      for(final member in nonSyntheticConstructors) {
        final memberName = member.name.isEmpty ? "" : member.name;
        final mirrorName = generateMirrorName(member);
        log("    -> Mapping constructor '${memberName.isEmpty ? '(default)' : memberName}' to its mirror '$mirrorName'.");
        buffer.writeln('    "$memberName": const ${mirrorName}(),');
      }
    }
    buffer.writeln('  };');


    buffer.writeln('  @override $classNameWithTypeParams newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {');
    if (classEl.isAbstract) {
      buffer.writeln('    throw UnimplementedError("Cannot instantiate an abstract class \\"$className\\".");');
    } else {
      buffer.writeln('    switch(constructorName) {');
      for(final ctor in classEl.constructors.where((c) => c.isPublic && !c.isSynthetic)) {
        final positionalParams = ctor.parameters.where((p) => !p.isNamed);
        final namedParams = ctor.parameters.where((p) => p.isNamed);
        final positionalArgsString = List.generate(positionalParams.length, (i) => 'positionalArgs[$i]').join(', ');
        final namedArgsString = namedParams.map((p) => "${p.name}: namedArgs[const Symbol('${p.name}')]").join(', ');
        final allArgs = [positionalArgsString, namedArgsString].where((s) => s.isNotEmpty).join(', ');

        final ctorName = ctor.name.isEmpty ? "" : ".${ctor.name}";
        buffer.writeln('      case "${ctor.name}": return $className$ctorName($allArgs);');
      }
      buffer.writeln('      default: throw UnimplementedError("Constructor \\"\$constructorName\\" not found or supported.");');
      buffer.writeln('    }');
    }
    buffer.writeln('  }');

    buffer.writeln('  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {');
    buffer.writeln('    final instance = target as $classNameWithTypeParams;');
    buffer.writeln('    switch(memberName) {');
    for(final member in instanceMembers.values.where((m) => !m.isPrivate)) {
      if (member is FieldElement) {
        buffer.writeln("      case const Symbol('${member.name}'): return instance.${member.name};");
        if(!member.isFinal) {
          buffer.writeln('      case const Symbol("${member.name}="): instance.${member.name} = positionalArgs[0]; break;');
        }
      } else if (member is PropertyAccessorElement) {
        if (member.isGetter) {
          buffer.writeln("      case const Symbol('${member.name}'): return instance.${member.name};");
        }
        else if (member.isSetter) {
          final propertyName = member.name.replaceAll('=', '');
          buffer.writeln("      case const Symbol('${member.name}'): instance.$propertyName = positionalArgs[0]; break;");
        }
      } else if (member is MethodElement) {
        final positionalParams = member.parameters.where((p) => !p.isNamed);
        final namedParams = member.parameters.where((p) => p.isNamed);
        final positionalArgsString = List.generate(positionalParams.length, (i) => 'positionalArgs[$i]').join(', ');
        final namedArgsString = namedParams.map((p) => "${p.name}: namedArgs[const Symbol('${p.name}')]").join(', ');
        final allArgs = [positionalArgsString, namedArgsString].where((s) => s.isNotEmpty).join(', ');

        if (member.returnType.isVoid) {
          buffer.writeln("      case const Symbol('${member.name}'): instance.${member.name}($allArgs); break;");
        } else {
          buffer.writeln("      case const Symbol('${member.name}'): return instance.${member.name}($allArgs);");
        }
      }
    }
    buffer.writeln('      default: throw UnimplementedError("Cannot invoke \\"\${_symbolToName(memberName)}\\" on \\"$className\\".");');
    buffer.writeln('    }');
    buffer.writeln('  }');

    buffer.writeln('}');
  }

  void writeFooterAndInitializer(StringBuffer buffer, Set<ClassElement> classes) {
    log("Generating final mirrors map and initializer function.");
    buffer.writeln('\nfinal Map<Type, AcClassMirror> generatedMirrors = {');
    for (final classEl in classes) {
      final classMirrorName = generateMirrorName(classEl);
      buffer.writeln('  ${classEl.name}: const ${classMirrorName}(),');
    }
    buffer.writeln('};');
    buffer.writeln('\nvoid acMirrorsInitialize() { initializeAcMirrors(generatedMirrors); }');
  }

  List<Element> getAllDeclarations(ClassElement classEl) {
    return [
      ...classEl.fields,
      ...classEl.methods,
      ...classEl.accessors,
      ...classEl.constructors,
    ];
  }

  bool _isStatic(Element d) {
    if (d is ExecutableElement) return d.isStatic;
    if (d is FieldElement) return d.isStatic;
    return false;
  }
}
