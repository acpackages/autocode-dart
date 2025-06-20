import 'dart:io';
import 'package:ac_blueprints/ac_blueprints.dart';
import 'package:ac_extensions/ac_extensions.dart';
import 'package:autocode/autocode.dart';

class AcCodeParser {
  
  @AcBindJsonProperty(skipInToJson:true,skipInFromJson: true)
  final Map<String, Map<String, RegExp>> languageEntityPatterns = {
    'ts': {
      AcEnumCodeEntityType.CLASS: RegExp(r'\b(export\s+)?(abstract\s+)?class\s+(\w+)', caseSensitive: false),
      AcEnumCodeEntityType.INTERFACE: RegExp(r'\bexport\s+interface\s+(\w+)', caseSensitive: false),
      AcEnumCodeEntityType.ENUM: RegExp(r'\benum\s+(\w+)', caseSensitive: false),
      AcEnumCodeEntityType.FUNCTION: RegExp(r'\bfunction\s+(\w+)\s*\(', caseSensitive: false),
      AcEnumCodeEntityType.VARIABLE: RegExp(r'\b(let|const|var)\s+(\w+)', caseSensitive: false),
    },
    'dart': {
      AcEnumCodeEntityType.CLASS: RegExp(r'\b(abstract\s+)?class\s+(\w+)', caseSensitive: false),
      AcEnumCodeEntityType.MIXIN: RegExp(r'\bmixin\s+(\w+)', caseSensitive: false),
      AcEnumCodeEntityType.ENUM: RegExp(r'\benum\s+(\w+)', caseSensitive: false),
      AcEnumCodeEntityType.FUNCTION: RegExp(r'\b(\w+)\s+(\w+)\s*\(', caseSensitive: false),
      AcEnumCodeEntityType.VARIABLE: RegExp(r'\b(?:final|var|const)\s+(\w+)', caseSensitive: false),
    },
    'php': {
      AcEnumCodeEntityType.CLASS: RegExp(r'\b(abstract\s+)?class\s+(\w+)', caseSensitive: false),
      AcEnumCodeEntityType.INTERFACE: RegExp(r'\binterface\s+(\w+)', caseSensitive: false),
      AcEnumCodeEntityType.TRAIT: RegExp(r'\btrait\s+(\w+)', caseSensitive: false),
      AcEnumCodeEntityType.FUNCTION: RegExp(r'\bfunction\s+(\w+)\s*\(', caseSensitive: false),
      AcEnumCodeEntityType.VARIABLE: RegExp(r'\$(\w+)\s*=', caseSensitive: false),
      AcEnumCodeEntityType.CONSTANT: RegExp(r'\bconst\s+(\w+)', caseSensitive: false),
    },
    'cs': {
      AcEnumCodeEntityType.CLASS: RegExp(r'\b(class)\s+(\w+)', caseSensitive: false),
      AcEnumCodeEntityType.INTERFACE: RegExp(r'\binterface\s+(\w+)', caseSensitive: false),
      AcEnumCodeEntityType.ENUM: RegExp(r'\benum\s+(\w+)', caseSensitive: false),
      AcEnumCodeEntityType.METHOD: RegExp(r'\b(public|private|protected|internal)?\s+(\w+)\s+(\w+)\s*\(', caseSensitive: false),
      AcEnumCodeEntityType.VARIABLE: RegExp(r'\b(\w+)\s+(\w+)\s*(=|;)', caseSensitive: false),
      AcEnumCodeEntityType.CONSTANT: RegExp(r'\bconst\s+(\w+)\s+(\w+)', caseSensitive: false),
    },
    'java': {
      AcEnumCodeEntityType.CLASS: RegExp(r'\bclass\s+(\w+)', caseSensitive: false),
      AcEnumCodeEntityType.INTERFACE: RegExp(r'\binterface\s+(\w+)', caseSensitive: false),
      AcEnumCodeEntityType.ENUM: RegExp(r'\benum\s+(\w+)', caseSensitive: false),
      AcEnumCodeEntityType.METHOD: RegExp(r'\b(public|private|protected)?\s+(\w+)\s+(\w+)\s*\(', caseSensitive: false),
      AcEnumCodeEntityType.CONSTANT: RegExp(r'\bstatic\s+final\s+\w+\s+(\w+)', caseSensitive: false),
    },
    'js': {
      AcEnumCodeEntityType.CLASS: RegExp(r'\bclass\s+(\w+)', caseSensitive: false),
      AcEnumCodeEntityType.FUNCTION: RegExp(r'\bfunction\s+(\w+)\s*\(', caseSensitive: false),
      AcEnumCodeEntityType.VARIABLE: RegExp(r'\b(var|let|const)\s+(\w+)', caseSensitive: false),
    },
    'py': {
    AcEnumCodeEntityType.CLASS: RegExp(r'\bclass\s+(\w+)', caseSensitive: false),
    AcEnumCodeEntityType.FUNCTION: RegExp(r'\bdef\s+(\w+)\s*\(', caseSensitive: false),
    AcEnumCodeEntityType.CONSTANT:  RegExp(r'^\s*(\w+)\s*=\s*["\'']?.+?["\']?\s*\$', caseSensitive: false),
    }
  };
  List<AcCodeEntityClass> classes = List.empty(growable: true);
  List<AcCodeEntityComment> comments = List.empty(growable: true);
  List<AcCodeEntityConstant> constants= List.empty(growable: true);
  List<AcCodeEntityEnum> enums = List.empty(growable: true);
  List<AcCodeEntityFunction> functions = List.empty(growable: true);
  List<AcCodeEntityInterface> interfaces = List.empty(growable: true);
  List<AcCodeEntityMethod> methods = List.empty(growable: true);
  List<AcCodeEntityMixin> mixins = List.empty(growable: true);
  List<AcCodeEntityVariable> variables = List.empty(growable: true);

  AcCodeParser();

  Future<AcResult> parseDirectoryFiles({required String directoryPath,bool recursive = false, bool ignoreComments = true}) async {
    AcResult acResult = AcResult();
    try{
      final directory = Directory(directoryPath);
      final files = directory.listSync(recursive: recursive).whereType<File>();
      bool continueOperation = true;
      for (final file in files) {
        if(continueOperation){
          AcResult fileResult = await parseFileCode(filePath:file.path,ignoreComments: ignoreComments);
          if(!fileResult.isSuccess()){
            acResult.setFromResult(result: fileResult);
            continueOperation = false;
            break;
          }
        }
      }
      if(continueOperation){
        acResult.setSuccess();
      }
    }
    catch(ex,stack){
      acResult.setException(exception: ex,stackTrace: stack);
    }
    return acResult;
  }

  Future<AcResult> parseFileCode({required String filePath, bool ignoreComments = true}) async {
    AcResult acResult = AcResult();
    try{
      filePath = filePath.replaceAll("\\", "/");
      File file = File(filePath);
      if(file.existsSync()){
        final ext = file.path.split('.').last.toLowerCase();
        if (languageEntityPatterns.containsKey(ext)){
          final content = await File(file.path).readAsLines();

          bool inBlockComment = false;
          String blockCommentBuffer = '';
          int blockCommentStartLine = 0;

          final blockStartRegex = RegExp(r'''^(\s*)(/\*|"""|''' + "'''|<!--)");
          final blockEndRegex = RegExp(r'''(\*/|"""|''' + "'''|-->)\s*;?\$");

          for (int i = 0; i < content.length; i++) {
            final rawLine = content[i];
            final line = rawLine.trim();
            if(ignoreComments){
              if (inBlockComment) {
                blockCommentBuffer += rawLine + '\n';
                if (blockEndRegex.hasMatch(line)) {
                  inBlockComment = false;
                  comments.add(AcCodeEntityComment()
                    ..text = blockCommentBuffer.trim()
                    ..filePath = filePath
                    ..lineNumber = blockCommentStartLine
                    ..columnNumber = 0
                    ..isDoc = blockCommentBuffer.trim().startsWith('/**') || blockCommentBuffer.trim().startsWith('///'));
                  blockCommentBuffer = '';
                }
                continue;
              }

              // Block comment start
              if (blockStartRegex.hasMatch(line)) {
                inBlockComment = true;
                blockCommentStartLine = i + 1;
                blockCommentBuffer = rawLine + '\n';
                continue;
              }

              // Single-line comments
              if (line.startsWith('//') ||
                  line.startsWith('#') ||
                  line.startsWith('--') ||
                  line.startsWith('///') ||
                  line.startsWith('##')) {
                comments.add(AcCodeEntityComment()
                  ..text = line
                  ..filePath = filePath
                  ..lineNumber = i + 1
                  ..columnNumber = rawLine.indexOf(line)
                  ..isDoc = line.startsWith('///') || line.startsWith('##') || line.startsWith('/**'));
                continue;
              }

              // Skip line if only comment or empty
              if (line.isEmpty || RegExp(r'^(\s*)(//|#|--|<!--)').hasMatch(line)) continue;
            }
            final patterns = languageEntityPatterns[ext]!;
            for (final entityType in patterns.keys) {
              final regex = patterns[entityType]!;
              final matches = regex.allMatches(line);
              for (final match in matches) {
                final name = match.group(match.groupCount)!;
                final line = i + 1;
                final column = match.start;
                switch(entityType){
                  case AcEnumCodeEntityType.CLASS:
                    var entity = AcCodeEntityClass()
                      ..name = name
                      ..filePath = filePath
                      ..lineNumber = line
                      ..columnNumber = column;
                    classes.add(entity);
                    break;
                  case AcEnumCodeEntityType.INTERFACE:
                    var entity = AcCodeEntityInterface()
                      ..name = name
                      ..filePath = filePath
                      ..lineNumber = line
                      ..columnNumber = column;
                    interfaces.add(entity);
                    break;
                  case AcEnumCodeEntityType.ENUM:
                    var entity =  AcCodeEntityEnum()
                      ..name = name
                      ..filePath = filePath
                      ..lineNumber = line
                      ..columnNumber = column;
                    enums.add(entity);
                  case AcEnumCodeEntityType.FUNCTION:
                    var entity =  AcCodeEntityFunction()
                      ..name = name
                      ..filePath = filePath
                      ..lineNumber = line
                      ..columnNumber = column;
                    functions.add(entity);
                  case AcEnumCodeEntityType.METHOD:
                    var entity =  AcCodeEntityMethod()
                      ..name = name
                      ..filePath = filePath
                      ..lineNumber = line
                      ..columnNumber = column;
                    methods.add(entity);
                  case AcEnumCodeEntityType.VARIABLE:
                    var entity =  AcCodeEntityVariable()
                      ..name = name
                      ..filePath = filePath
                      ..lineNumber = line
                      ..columnNumber = column;
                    variables.add(entity);
                  case AcEnumCodeEntityType.CONSTANT:
                    var entity =  AcCodeEntityConstant()
                      ..name = name
                      ..filePath = filePath
                      ..lineNumber = line
                      ..columnNumber = column;
                    constants.add(entity);
                  case AcEnumCodeEntityType.MIXIN:
                    var entity =  AcCodeEntityMixin()
                      ..name = name
                      ..filePath = filePath
                      ..lineNumber = line
                      ..columnNumber = column;
                    mixins.add(entity);
                }
              }
            }
          }
        }
      }
      acResult.setSuccess();
    }
    catch(ex,stack){
      acResult.setException(exception: ex,stackTrace: stack);
    }
    return acResult;
  }

  factory AcCodeParser.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcCodeParser();
    instance.fromJson(jsonData:jsonData);
    return instance;
  }

  AcCodeParser fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData:jsonData);
    return this;
  }

  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }

}
