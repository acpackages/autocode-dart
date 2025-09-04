import 'package:ac_mirrors/ac_mirrors.dart';

@AcReflectable()
class AcEnumCodeEntityType {
  // 🔵 Core Types
  static const CLASS = 'class';
  static const INTERFACE = 'interface';
  static const ENUM = 'enum';
  static const STRUCT = 'struct';
  static const UNION = 'union';
  static const TRAIT = 'trait';
  static const MIXIN = 'mixin';
  static const RECORD = 'record';

  // 🟢 Functional
  static const FUNCTION = 'function';
  static const METHOD = 'method';
  static const CONSTRUCTOR = 'constructor';
  static const DESTRUCTOR = 'destructor';
  static const GETTER = 'getter';
  static const SETTER = 'setter';
  static const LAMBDA = 'lambda';
  static const GENERATOR = 'generator';
  static const OPERATOR_OVERLOAD = 'operator_overload';

  // 🟡 Variables & Constants
  static const VARIABLE = 'variable';
  static const CONSTANT = 'constant';
  static const FIELD = 'field';
  static const STATIC_FIELD = 'static_field';
  static const GLOBAL_VARIABLE = 'global_variable';
  static const PROPERTY = 'property';
  static const PARAMETER = 'parameter';
  static const TYPE_PARAMETER = 'type_parameter';

  // 🟣 Namespace / Modules
  static const MODULE = 'module';
  static const PACKAGE = 'package';
  static const NAMESPACE = 'namespace';
  static const IMPORT = 'import';
  static const EXPORT = 'export';

  // 🟠 Type & Declaration
  static const TYPE_ALIAS = 'type_alias';
  static const TYPEDEF = 'typedef';
  static const ANNOTATION = 'annotation';
  static const DECORATOR = 'decorator';
  static const ATTRIBUTE = 'attribute';
  static const GENERIC_CONSTRAINT = 'generic_constraint';
  static const INTERFACE_IMPLEMENTATION = 'interface_implementation';
  static const INHERITANCE = 'inheritance';
  static const IMPLEMENTS = 'implements';

  // 🔴 Control Flow
  static const LOOP = 'loop';
  static const CONDITIONAL = 'conditional';
  static const EXCEPTION_HANDLER = 'exception_handler';
  static const EXPRESSION = 'expression';
  static const BLOCK = 'block';
  static const RETURN_STATEMENT = 'return_statement';
  static const BREAK = 'break';
  static const CONTINUE = 'continue';

  // 🟤 Documentation
  static const COMMENT = 'comment';
  static const DOCSTRING = 'docstring';
  static const TODO = 'todo';
  static const NOTE = 'note';

  // ⚪ File-Level
  static const FILE = 'file';
  static const DIRECTIVE = 'directive';
  static const METADATA = 'metadata';
  static const SHEBANG = 'shebang';

  // 🔘 Others
  static const MACRO = 'macro';
  static const SYMBOL = 'symbol';
  static const LABEL = 'label';
  static const RESOURCE = 'resource';
}
