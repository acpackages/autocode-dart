import '../cef_browser.dart';

enum CefKeyEventType {
  keyEventRawKeyDown,
  keyEventKeyDown,
  keyEventKeyUp,
  keyEventChar,
}

class CefKeyEvent {
  final CefKeyEventType type;
  final int modifiers;
  final int windowsKeyCode;
  final int nativeKeyCode;
  final bool isSystemKey;
  final int character;
  final int unmodifiedCharacter;
  final bool focusOnEditableField;

  CefKeyEvent({
    required this.type,
    required this.modifiers,
    required this.windowsKeyCode,
    required this.nativeKeyCode,
    required this.isSystemKey,
    required this.character,
    required this.unmodifiedCharacter,
    required this.focusOnEditableField,
  });
}

abstract class CefKeyboardHandler {
  bool onPreKeyEvent(
    CefBrowser browser,
    CefKeyEvent event,
  );

  bool onKeyEvent(
    CefBrowser browser,
    CefKeyEvent event,
  );
}
