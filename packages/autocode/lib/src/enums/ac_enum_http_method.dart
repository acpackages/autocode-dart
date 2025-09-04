import 'package:ac_mirrors/ac_mirrors.dart';

/* AcDoc({
  "description": "Enumeration of standard HTTP methods used in RESTful services.",
  "author": "Sanket Patel",
  "type": "development"
}) */
@AcReflectable()
enum AcEnumHttpMethod {
  /* AcDoc({"description": "Establishes a tunnel to the server identified by a given URI."}) */
  connect('CONNECT'),
  /* AcDoc({"description": "Deletes the specified resource."}) */
  delete('DELETE'),
  /* AcDoc({"description": "Requests data from a specified resource."}) */
  get('GET'),
  /* AcDoc({"description": "Same as GET but returns only HTTP headers and no document body."}) */
  head('HEAD'),
  /* AcDoc({"description": "Describes the communication options for the target resource."}) */
  options('OPTIONS'),
  /* AcDoc({"description": "Applies partial modifications to a resource."}) */
  patch('PATCH'),
  /* AcDoc({"description": "Submits data to be processed to a specified resource."}) */
  post('POST'),
  /* AcDoc({"description": "Replaces all current representations of the target resource with the uploaded content."}) */
  put('PUT'),
  /* AcDoc({"description": "Performs a message loop-back test along the path to the target resource."}) */
  trace('TRACE');

  /* AcDoc({"description": "The string representation of the HTTP method."}) */
  final String value;

  /* AcDoc({"description": "Constructor that sets the string value for the HTTP method."}) */
  const AcEnumHttpMethod(this.value);

  /* AcDoc({
    "description": "Finds the HTTP method enum that matches the given string.",
    "params": [{"name": "value", "description": "The string value to match."}],
    "returns": "The matching enum or null if no match."
  }) */
  static AcEnumHttpMethod? fromValue(String value) {
    try {
      return AcEnumHttpMethod.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }

  /* AcDoc({
    "description": "Checks if this enum's string value is equal to another string.",
    "params": [{"name": "other", "description": "The string to compare."}],
    "returns": "true if equal, false otherwise."
  }) */
  bool equals(String other) => value == other;

  /* AcDoc({"description": "Returns the HTTP method as a string."}) */
  @override
  String toString() => value;
}
