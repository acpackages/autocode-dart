import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// ThemeProvider — app-wide dark/light mode state
// ─────────────────────────────────────────────────────────────

class ThemeProvider extends StatefulWidget {
  final Widget child;
  const ThemeProvider({super.key, required this.child});

  @override
  State<ThemeProvider> createState() => _ThemeProviderState();

  static _ThemeProviderState of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<_ThemeInherited>();
    if (inherited == null) {
      return _ThemeProviderState().._isDark = true;
    }
    return inherited.state;
  }
}

class _ThemeProviderState extends State<ThemeProvider> {
  // Default: dark mode
  bool _isDark = true;

  bool get isDark => _isDark;

  void toggleTheme() {
    if (mounted) {
      setState(() => _isDark = !_isDark);
    } else {
      _isDark = !_isDark;
    }
  }

  void setDark(bool v) {
    if (mounted) {
      setState(() => _isDark = v);
    } else {
      _isDark = v;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ThemeInherited(state: this, child: widget.child);
  }
}

class _ThemeInherited extends InheritedWidget {
  final _ThemeProviderState state;

  const _ThemeInherited({required this.state, required super.child});

  @override
  bool updateShouldNotify(_ThemeInherited old) => true;
}

// ─────────────────────────────────────────────────────────────
// AcChatApiProvider — context provider for AcChatApi
// ─────────────────────────────────────────────────────────────

class AcChatApiProvider extends InheritedWidget {
  final dynamic api;

  const AcChatApiProvider({
    super.key,
    required this.api,
    required super.child,
  });

  static dynamic of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AcChatApiProvider>();
    assert(provider != null, 'No AcChatApiProvider found in context');
    return provider!.api;
  }

  @override
  bool updateShouldNotify(AcChatApiProvider oldWidget) => api != oldWidget.api;
}
