abstract class CefFrame {
  void dispose();
  String? getIdentifier();
  String getURL();
  String getName();
  bool isMain();
  bool isValid();
  bool isFocused();
  CefFrame? getParent();
  void executeJavaScript(String code, String url, int line);
  void undo();
  void redo();
  void cut();
  void copy();
  void paste();
  void delete();
  void selectAll();
}
