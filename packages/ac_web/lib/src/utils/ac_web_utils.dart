import 'dart:convert';

class AcWebUtils{
  static String getContentStringFromBase64({required String base64String}) {
    String sanitized = base64String;

    if (sanitized.startsWith('base64:')) {
      sanitized = sanitized.substring(7); // "base64:".length is 7
    }

    // Strip Data URI prefix if present
    if (sanitized.contains(',')) {
      sanitized = sanitized.split(',').last;
    }

    // Remove whitespace and newline characters
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), '');

    // Safely decode to HTML
    return utf8.decode(base64.decode(sanitized));
  }
}