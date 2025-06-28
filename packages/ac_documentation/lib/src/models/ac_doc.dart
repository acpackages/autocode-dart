import 'package:ac_documentation/ac_documentation.dart';
import 'package:autocode/autocode.dart';

/* AcDoc({
  "description": "Represents structured documentation metadata extracted from code comments in multiple programming languages.",
  "type": "development",
  "author": "AcDocs System"
}) */
class AcDoc {
  // Key Constants
  static const String keyType = "type";
  static const String keySummary = "summary";
  static const String keyDescription = "description";
  static const String keyRemarks = "remarks";
  static const String keySince = "since";
  static const String keyVersion = "version";
  static const String keyAuthor = "author";
  static const String keyAuthors = "authors";
  static const String keyOwner = "owner";
  static const String keyParams = "params";
  static const String keyReturns = "returns";
  static const String keyReturnsType = "returns_type";
  static const String keyThrows = "throws";
  static const String keyExamples = "examples";
  static const String keyTags = "tags";
  static const String keyCategory = "category";
  static const String keyGroup = "group";
  static const String keyFeature = "feature";
  static const String keyPlatforms = "platforms";
  static const String keyVisibility = "visibility";
  static const String keyVisibilityModifiers = "visibility_modifiers";
  static const String keyLicense = "license";
  static const String keyDeprecated = "deprecated";
  static const String keyTodo = "todo";
  static const String keyAnnotations = "annotations";
  static const String keyLinks = "links";
  static const String keyDocs = "docs";
  static const String keySource = "source";
  static const String keyIssues = "issues";
  static const String keySecurityNotes = "security_notes";
  static const String keyCompliance = "compliance";
  static const String keyCompatibility = "compatibility";
  static const String keyIsAsync = "is_async";
  static const String keyIsPure = "is_pure";
  static const String keyIsStatic = "is_static";
  static const String keyIsConstructor = "is_constructor";
  static const String keyIsDeprecated = "is_deprecated";
  static const String keyInheritDoc = "inherit_doc";
  static const String keyIsRequired = "is_required";
  static const String keyIsNullable = "is_nullable";
  static const String keyIsReadonly = "is_readonly";
  static const String keyDefaultValue = "default_value";
  static const String keyOverrides = "overrides";
  static const String keyImplements = "implements";
  static const String keyImplementsInterfaces = "implements_interfaces";
  static const String keyExtends = "extends";
  static const String keyMixins = "mixins";
  static const String keyTypeParams = "type_params";
  static const String keyFilePath = "file_path";
  static const String keySourceLine = "source_line";
  static const String keyAnchorId = "anchor_id";
  static const String keyTargetName = "target_name";
  static const String keyTargetType = "target_type";
  static const String keyEnclosingClass = "enclosing_class";

  /* AcDoc({"description": "The type of documentation entry, e.g., 'usage', 'development'."}) */
  dynamic type;

  /* AcDoc({"description": "Short summary of the documented item."}) */
  late String summary;

  /* AcDoc({"description": "Detailed description of the documented element."}) */
  late String description;

  /* AcDoc({"description": "Additional notes or remarks."}) */
  List<String>? remarks;

  /* AcDoc({"description": "Version since the documented item exists."}) */
  String? since;

  /* AcDoc({"description": "Current version of the documented item."}) */
  String? version;

  /* AcDoc({"description": "Primary author of the documentation."}) */
  String? author;

  /* AcDoc({"description": "List of all authors."}) */
  List<String>? authors;

  /* AcDoc({"description": "Owner or maintainer of the item."}) */
  String? owner;

  /* AcDoc({"description": "Parameters for methods or constructors."}) */
  List<AcParam>? params;

  /* AcDoc({"description": "Textual description of return value."}) */
  String? returns;

  @AcBindJsonProperty(key: AcDoc.keyReturnsType)
  /* AcDoc({"description": "Data type of the return value."}) */
  String? returnsType;

  /* AcDoc({"description": "List of exceptions or errors that might be thrown."}) */
  List<AcThrows>? throwsInfo;

  /* AcDoc({"description": "Examples demonstrating usage."}) */
  List<String>? examples;

  /* AcDoc({"description": "Tags for categorizing documentation."}) */
  List<String>? tags;

  /* AcDoc({"description": "Category name for grouping."}) */
  String? category;

  /* AcDoc({"description": "Group label for organizing related elements."}) */
  String? group;

  /* AcDoc({"description": "Feature this item belongs to."}) */
  String? feature;

  /* AcDoc({"description": "Supported platforms for the item."}) */
  List<String>? platforms;

  /* AcDoc({"description": "Visibility level, e.g., public, private."}) */
  String? visibility;

  @AcBindJsonProperty(key: AcDoc.keyVisibilityModifiers)
  /* AcDoc({"description": "Modifiers like static, final, etc."}) */
  List<String>? visibilityModifiers;

  /* AcDoc({"description": "License information object."}) */
  AcLicense? license;

  /* AcDoc({"description": "Deprecation information object."}) */
  AcDeprecation? deprecated;

  /* AcDoc({"description": "To-do notes for future enhancements."}) */
  List<String>? todo;

  /* AcDoc({"description": "Annotations used in the source."}) */
  List<String>? annotations;

  /* AcDoc({"description": "List of relevant links."}) */
  List<String>? links;

  /* AcDoc({"description": "Inline or external documentation content."}) */
  String? docs;

  /* AcDoc({"description": "Original source code snippet or reference."}) */
  String? source;

  /* AcDoc({"description": "List of known issues."}) */
  List<String>? issues;

  @AcBindJsonProperty(key: AcDoc.keySecurityNotes)
  /* AcDoc({"description": "Security-related concerns or notes."}) */
  String? securityNotes;

  /* AcDoc({"description": "Compliance notes, e.g., GDPR, ISO."}) */
  List<String>? compliance;

  /* AcDoc({"description": "Compatibility notes across platforms or versions."}) */
  List<String>? compatibility;

  @AcBindJsonProperty(key: AcDoc.keyIsAsync)
  /* AcDoc({"description": "Indicates if the method is asynchronous."}) */
  bool? isAsync;

  @AcBindJsonProperty(key: AcDoc.keyIsPure)
  /* AcDoc({"description": "Indicates if the method is side-effect free."}) */
  bool? isPure;

  @AcBindJsonProperty(key: AcDoc.keyIsStatic)
  /* AcDoc({"description": "Indicates if the member is static."}) */
  bool? isStatic;

  @AcBindJsonProperty(key: AcDoc.keyIsConstructor)
  /* AcDoc({"description": "Marks the item as a constructor."}) */
  bool? isConstructor;

  @AcBindJsonProperty(key: AcDoc.keyIsDeprecated)
  /* AcDoc({"description": "Marks the item as deprecated."}) */
  bool? isDeprecated;

  @AcBindJsonProperty(key: AcDoc.keyInheritDoc)
  /* AcDoc({"description": "Inherit documentation from parent or interface."}) */
  bool? inheritDoc;

  @AcBindJsonProperty(key: AcDoc.keyIsRequired)
  /* AcDoc({"description": "Indicates if the parameter is required."}) */
  bool? isRequired;

  @AcBindJsonProperty(key: AcDoc.keyIsNullable)
  /* AcDoc({"description": "Indicates if the parameter can be null."}) */
  bool? isNullable;

  @AcBindJsonProperty(key: AcDoc.keyIsReadonly)
  /* AcDoc({"description": "Marks the field as read-only."}) */
  bool? isReadonly;

  @AcBindJsonProperty(key: AcDoc.keyDefaultValue)
  /* AcDoc({"description": "Default value of the parameter or property."}) */
  String? defaultValue;

  /* AcDoc({"description": "Indicates what this overrides from its superclass."}) */
  String? overrides;

  /* AcDoc({"description": "Interfaces that this element implements."}) */
  List<String>? implements_;

  @AcBindJsonProperty(key: AcDoc.keyImplementsInterfaces)
  /* AcDoc({"description": "Fully qualified interfaces implemented."}) */
  List<String>? implementsInterfaces;

  /* AcDoc({"description": "Superclass this extends from."}) */
  String? extends_;

  /* AcDoc({"description": "List of mixins applied to this item."}) */
  List<String>? mixins;

  @AcBindJsonProperty(key: AcDoc.keyTypeParams)
  /* AcDoc({"description": "Generic type parameter mappings."}) */
  Map<String, String>? typeParams;

  @AcBindJsonProperty(key: AcDoc.keyFilePath)
  /* AcDoc({"description": "Path to the source file this doc came from."}) */
  String? filePath;

  @AcBindJsonProperty(key: AcDoc.keySourceLine)
  /* AcDoc({"description": "Line number in the source file."}) */
  int? sourceLine;

  @AcBindJsonProperty(key: AcDoc.keyAnchorId)
  /* AcDoc({"description": "Unique anchor ID used in HTML generation."}) */
  String? anchorId;

  @AcBindJsonProperty(key: AcDoc.keyTargetName)
  /* AcDoc({"description": "Name of the method, class, or field documented."}) */
  String? targetName;

  @AcBindJsonProperty(key: AcDoc.keyTargetType)
  /* AcDoc({"description": "Type of the target: method, class, or field."}) */
  String? targetType;

  @AcBindJsonProperty(key: AcDoc.keyEnclosingClass)
  /* AcDoc({"description": "Name of the enclosing class, if any."}) */
  String? enclosingClass;

  /* AcDoc({"description": "Constructs a new AcDoc instance."}) */
  AcDoc();

  /* AcDoc({"description": "Creates an instance of AcDoc from a JSON map."}) */
  factory AcDoc.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcDoc();
    instance.fromJson(jsonData:jsonData);
    return instance;
  }

  /* AcDoc({"description": "Populates this instance with values from a JSON map."}) */
  AcDoc fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  /* AcDoc({"description": "Converts this instance to a JSON map."}) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({"description": "Returns a pretty JSON string representation of the object."}) */
  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
