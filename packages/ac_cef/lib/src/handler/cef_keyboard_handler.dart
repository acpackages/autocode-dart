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

/// Implement this interface to handle keyboard events.
///
/// Mirrors JCEF's `org.cef.handler.CefKeyboardHandler` and `CefKeyboardHandlerAdapter`.
abstract class CefKeyboardHandler {
  /// Called before a keyboard event is sent to the renderer. Return true to consume.
  bool onPreKeyEvent(
    CefBrowser browser,
    CefKeyEvent event,
  ) => false;

  /// Called after a keyboard event is processed by the renderer. Return true if handled.
  bool onKeyEvent(
    CefBrowser browser,
    CefKeyEvent event,
  ) => false;
}

/// Convenience alias matching JCEF's adapter class name.
typedef CefKeyboardHandlerAdapter = CefKeyboardHandler;
