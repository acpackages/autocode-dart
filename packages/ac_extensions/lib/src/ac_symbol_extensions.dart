extension AcSymbolExtensions on Symbol {
  /// WARNING: This method depends on Symbol.toString() format,
  /// which is not officially supported and may break in the future.
  String getName() {
    final symbolStr = toString();
    final match = RegExp('"(.*?)"').firstMatch(symbolStr);
    return match?.group(1) ?? symbolStr;
  }
}
