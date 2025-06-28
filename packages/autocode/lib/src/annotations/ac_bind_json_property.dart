import 'package:meta/meta.dart';

/* AcDoc({
  "author": "Sanket Patel",
  "summary": "An annotation to customize JSON serialization for a class field.",
  "description": "Binds a Dart field to a specific JSON key and controls its inclusion/exclusion and type handling during serialization from, and deserialization to, a JSON object. This is typically used by a code generation tool.",
  "examples": [
    "class User {",
    "  // Bind 'id' field to 'user_id' key in JSON",
    "  @AcBindJsonProperty(key: 'user_id')",
    "  final int id;",
    "",
    "  // Do not include 'password' when writing to JSON",
    "  @AcBindJsonProperty(skipInToJson: true)",
    "  final String password;",
    "}"
  ]
}) */
@immutable
class AcBindJsonProperty {
  /* AcDoc({
    "summary": "The JSON key name for this field.",
    "description": "Specifies the key to be used in the JSON object. If this is null or not provided, the Dart field's name is used as the key."
  }) */
  final String? key;

  /* AcDoc({
    "summary": "The type of elements in a List or Map.",
    "description": "Used by the deserializer to correctly instantiate elements within a generic collection (e.g., `List<User>`)."
  }) */
  final Type? arrayType;

  /* AcDoc({
    "summary": "Excludes this field when reading from JSON.",
    "description": "If `true`, the deserializer will ignore any value for this key in the JSON source and will not attempt to populate the Dart field."
  }) */
  final bool skipInFromJson;

  /* AcDoc({
    "summary": "Excludes this field when writing to JSON.",
    "description": "If `true`, the serializer will omit this field from the resulting JSON output. Useful for sensitive data or temporary state."
  }) */
  final bool skipInToJson;

  /* AcDoc({
    "summary": "Creates a `const` instance of the annotation.",
    "description": "Initializes the annotation's properties to configure JSON binding behavior for a field.",
    "params": [
      { "name": "key", "description": "The custom JSON key name to use instead of the field name." },
      { "name": "arrayType", "description": "The type of elements in a collection, used for deserialization of lists." },
      { "name": "skipInFromJson", "description": "Set to true to skip this field during deserialization." },
      { "name": "skipInToJson", "description": "Set to true to skip this field during serialization." }
    ]
  }) */
  const AcBindJsonProperty({
    this.key,
    this.arrayType,
    this.skipInFromJson = false,
    this.skipInToJson = false,
  });
}