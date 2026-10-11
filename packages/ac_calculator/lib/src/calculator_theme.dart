import 'package:flutter/widgets.dart';

/// Centralized theme class for all calculator styling.
class AcCalculatorTheme {
  final Brightness brightness;

  // Background and Display Colors
  final Color backgroundColor;
  final Color displayBackgroundColor;
  final Color displayTextColor;
  final Color secondaryTextColor;

  // Keypad Button Colors
  final Color numberButtonColor;
  final Color numberButtonTextColor;
  final Color operatorButtonColor;
  final Color operatorButtonTextColor;
  final Color functionButtonColor;
  final Color functionButtonTextColor;
  final Color equalsButtonColor;
  final Color equalsButtonTextColor;

  // Navigation, Toolbar & Panels
  final Color navBackgroundColor;
  final Color navTextColor;
  final Color panelBackgroundColor;
  final Color panelTextColor;
  final Color selectedItemColor;
  final Color borderColor;
  final Color dividerColor;
  final Color errorColor;

  // Graph Colors
  final Color graphBackgroundColor;
  final Color graphGridColor;
  final Color graphAxisColor;
  final List<Color> graphLineColors;

  // Typography
  final double displayFontSize;
  final double secondaryDisplayFontSize;
  final double buttonFontSize;
  final double navFontSize;
  final double panelHeaderFontSize;
  final double bodyFontSize;

  // Dimensions & Spacing
  final double buttonRadius;
  final double panelRadius;
  final double spacing;
  final EdgeInsets displayPadding;
  final EdgeInsets buttonPadding;
  final EdgeInsets panelPadding;
  final double borderThickness;
  final double minTouchTargetSize;

  const AcCalculatorTheme({
    this.brightness = Brightness.light,
    required this.backgroundColor,
    required this.displayBackgroundColor,
    required this.displayTextColor,
    required this.secondaryTextColor,
    required this.numberButtonColor,
    required this.numberButtonTextColor,
    required this.operatorButtonColor,
    required this.operatorButtonTextColor,
    required this.functionButtonColor,
    required this.functionButtonTextColor,
    required this.equalsButtonColor,
    required this.equalsButtonTextColor,
    required this.navBackgroundColor,
    required this.navTextColor,
    required this.panelBackgroundColor,
    required this.panelTextColor,
    required this.selectedItemColor,
    required this.borderColor,
    required this.dividerColor,
    required this.errorColor,
    required this.graphBackgroundColor,
    required this.graphGridColor,
    required this.graphAxisColor,
    required this.graphLineColors,
    this.displayFontSize = 36.0,
    this.secondaryDisplayFontSize = 14.0,
    this.buttonFontSize = 18.0,
    this.navFontSize = 14.0,
    this.panelHeaderFontSize = 16.0,
    this.bodyFontSize = 14.0,
    this.buttonRadius = 4.0,
    this.panelRadius = 6.0,
    this.spacing = 4.0,
    this.displayPadding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 12.0,
    ),
    this.buttonPadding = const EdgeInsets.all(4.0),
    this.panelPadding = const EdgeInsets.all(12.0),
    this.borderThickness = 1.0,
    this.minTouchTargetSize = 44.0,
  });

  /// Windows-inspired Light Theme.
  factory AcCalculatorTheme.windowsLight() {
    return const AcCalculatorTheme(
      brightness: Brightness.light,
      backgroundColor: Color(0xFFF3F3F3),
      displayBackgroundColor: Color(0xFFF3F3F3),
      displayTextColor: Color(0xFF1F1F1F),
      secondaryTextColor: Color(0xFF606060),
      numberButtonColor: Color(0xFFFFFFFF),
      numberButtonTextColor: Color(0xFF1F1F1F),
      operatorButtonColor: Color(0xFFF9F9F9),
      operatorButtonTextColor: Color(0xFF1F1F1F),
      functionButtonColor: Color(0xFFF9F9F9),
      functionButtonTextColor: Color(0xFF1F1F1F),
      equalsButtonColor: Color(0xFF0067C0),
      equalsButtonTextColor: Color(0xFFFFFFFF),
      navBackgroundColor: Color(0xFFEBEBEB),
      navTextColor: Color(0xFF1F1F1F),
      panelBackgroundColor: Color(0xFFF8F8F8),
      panelTextColor: Color(0xFF1F1F1F),
      selectedItemColor: Color(0x200067C0),
      borderColor: Color(0xFFE5E5E5),
      dividerColor: Color(0xFFE0E0E0),
      errorColor: Color(0xFFC42B1C),
      graphBackgroundColor: Color(0xFFFFFFFF),
      graphGridColor: Color(0xFFEEEEEE),
      graphAxisColor: Color(0xFF888888),
      graphLineColors: [
        Color(0xFF0067C0),
        Color(0xFFD83B01),
        Color(0xFF107C10),
        Color(0xFF881798),
      ],
      buttonRadius: 4.0,
      panelRadius: 6.0,
      spacing: 3.0,
      displayFontSize: 38.0,
      buttonFontSize: 16.0,
    );
  }

  /// Windows-inspired Dark Theme.
  factory AcCalculatorTheme.windowsDark() {
    return const AcCalculatorTheme(
      brightness: Brightness.dark,
      backgroundColor: Color(0xFF202020),
      displayBackgroundColor: Color(0xFF202020),
      displayTextColor: Color(0xFFFFFFFF),
      secondaryTextColor: Color(0xFFA0A0A0),
      numberButtonColor: Color(0xFF3B3B3B),
      numberButtonTextColor: Color(0xFFFFFFFF),
      operatorButtonColor: Color(0xFF323232),
      operatorButtonTextColor: Color(0xFFFFFFFF),
      functionButtonColor: Color(0xFF323232),
      functionButtonTextColor: Color(0xFFFFFFFF),
      equalsButtonColor: Color(0xFF4CC2FF),
      equalsButtonTextColor: Color(0xFF000000),
      navBackgroundColor: Color(0xFF181818),
      navTextColor: Color(0xFFFFFFFF),
      panelBackgroundColor: Color(0xFF2B2B2B),
      panelTextColor: Color(0xFFFFFFFF),
      selectedItemColor: Color(0x304CC2FF),
      borderColor: Color(0xFF2E2E2E),
      dividerColor: Color(0xFF333333),
      errorColor: Color(0xFFFF99A4),
      graphBackgroundColor: Color(0xFF1A1A1A),
      graphGridColor: Color(0xFF333333),
      graphAxisColor: Color(0xFF777777),
      graphLineColors: [
        Color(0xFF4CC2FF),
        Color(0xFFFF8C00),
        Color(0xFF6CCB5F),
        Color(0xFFB146C2),
      ],
      buttonRadius: 4.0,
      panelRadius: 6.0,
      spacing: 3.0,
      displayFontSize: 38.0,
      buttonFontSize: 16.0,
    );
  }

  /// iPhone-inspired Light Theme.
  factory AcCalculatorTheme.iphoneLight() {
    return const AcCalculatorTheme(
      brightness: Brightness.light,
      backgroundColor: Color(0xFFF2F2F7),
      displayBackgroundColor: Color(0xFFF2F2F7),
      displayTextColor: Color(0xFF000000),
      secondaryTextColor: Color(0xFF8E8E93),
      numberButtonColor: Color(0xFFE5E5EA),
      numberButtonTextColor: Color(0xFF000000),
      operatorButtonColor: Color(0xFFFF9500),
      operatorButtonTextColor: Color(0xFFFFFFFF),
      functionButtonColor: Color(0xFFD1D1D6),
      functionButtonTextColor: Color(0xFF000000),
      equalsButtonColor: Color(0xFFFF9500),
      equalsButtonTextColor: Color(0xFFFFFFFF),
      navBackgroundColor: Color(0xFFE5E5EA),
      navTextColor: Color(0xFF000000),
      panelBackgroundColor: Color(0xFFFFFFFF),
      panelTextColor: Color(0xFF000000),
      selectedItemColor: Color(0x25FF9500),
      borderColor: Color(0xFFC7C7CC),
      dividerColor: Color(0xFFD1D1D6),
      errorColor: Color(0xFFFF3B30),
      graphBackgroundColor: Color(0xFFFFFFFF),
      graphGridColor: Color(0xFFE5E5EA),
      graphAxisColor: Color(0xFF8E8E93),
      graphLineColors: [
        Color(0xFFFF9500),
        Color(0xFF007AFF),
        Color(0xFF34C759),
        Color(0xFFAF52DE),
      ],
      buttonRadius: 28.0, // Rounded pill / circular
      panelRadius: 14.0,
      spacing: 8.0,
      displayFontSize: 44.0,
      buttonFontSize: 20.0,
    );
  }

  /// iPhone-inspired Dark Theme.
  factory AcCalculatorTheme.iphoneDark() {
    return const AcCalculatorTheme(
      brightness: Brightness.dark,
      backgroundColor: Color(0xFF000000),
      displayBackgroundColor: Color(0xFF000000),
      displayTextColor: Color(0xFFFFFFFF),
      secondaryTextColor: Color(0xFF8E8E93),
      numberButtonColor: Color(0xFF333333),
      numberButtonTextColor: Color(0xFFFFFFFF),
      operatorButtonColor: Color(0xFFFF9F0A),
      operatorButtonTextColor: Color(0xFFFFFFFF),
      functionButtonColor: Color(0xFFA5A5A5),
      functionButtonTextColor: Color(0xFF000000),
      equalsButtonColor: Color(0xFFFF9F0A),
      equalsButtonTextColor: Color(0xFFFFFFFF),
      navBackgroundColor: Color(0xFF1C1C1E),
      navTextColor: Color(0xFFFFFFFF),
      panelBackgroundColor: Color(0xFF1C1C1E),
      panelTextColor: Color(0xFFFFFFFF),
      selectedItemColor: Color(0x35FF9F0A),
      borderColor: Color(0xFF2C2C2E),
      dividerColor: Color(0xFF2C2C2E),
      errorColor: Color(0xFFFF453A),
      graphBackgroundColor: Color(0xFF121212),
      graphGridColor: Color(0xFF2C2C2E),
      graphAxisColor: Color(0xFF636366),
      graphLineColors: [
        Color(0xFFFF9F0A),
        Color(0xFF0A84FF),
        Color(0xFF30D158),
        Color(0xFFBF5AF2),
      ],
      buttonRadius: 28.0,
      panelRadius: 14.0,
      spacing: 8.0,
      displayFontSize: 44.0,
      buttonFontSize: 20.0,
    );
  }

  AcCalculatorTheme copyWith({
    Brightness? brightness,
    Color? backgroundColor,
    Color? displayBackgroundColor,
    Color? displayTextColor,
    Color? secondaryTextColor,
    Color? numberButtonColor,
    Color? numberButtonTextColor,
    Color? operatorButtonColor,
    Color? operatorButtonTextColor,
    Color? functionButtonColor,
    Color? functionButtonTextColor,
    Color? equalsButtonColor,
    Color? equalsButtonTextColor,
    Color? navBackgroundColor,
    Color? navTextColor,
    Color? panelBackgroundColor,
    Color? panelTextColor,
    Color? selectedItemColor,
    Color? borderColor,
    Color? dividerColor,
    Color? errorColor,
    Color? graphBackgroundColor,
    Color? graphGridColor,
    Color? graphAxisColor,
    List<Color>? graphLineColors,
    double? displayFontSize,
    double? secondaryDisplayFontSize,
    double? buttonFontSize,
    double? navFontSize,
    double? panelHeaderFontSize,
    double? bodyFontSize,
    double? buttonRadius,
    double? panelRadius,
    double? spacing,
    EdgeInsets? displayPadding,
    EdgeInsets? buttonPadding,
    EdgeInsets? panelPadding,
    double? borderThickness,
    double? minTouchTargetSize,
  }) {
    return AcCalculatorTheme(
      brightness: brightness ?? this.brightness,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      displayBackgroundColor:
          displayBackgroundColor ?? this.displayBackgroundColor,
      displayTextColor: displayTextColor ?? this.displayTextColor,
      secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
      numberButtonColor: numberButtonColor ?? this.numberButtonColor,
      numberButtonTextColor:
          numberButtonTextColor ?? this.numberButtonTextColor,
      operatorButtonColor: operatorButtonColor ?? this.operatorButtonColor,
      operatorButtonTextColor:
          operatorButtonTextColor ?? this.operatorButtonTextColor,
      functionButtonColor: functionButtonColor ?? this.functionButtonColor,
      functionButtonTextColor:
          functionButtonTextColor ?? this.functionButtonTextColor,
      equalsButtonColor: equalsButtonColor ?? this.equalsButtonColor,
      equalsButtonTextColor:
          equalsButtonTextColor ?? this.equalsButtonTextColor,
      navBackgroundColor: navBackgroundColor ?? this.navBackgroundColor,
      navTextColor: navTextColor ?? this.navTextColor,
      panelBackgroundColor: panelBackgroundColor ?? this.panelBackgroundColor,
      panelTextColor: panelTextColor ?? this.panelTextColor,
      selectedItemColor: selectedItemColor ?? this.selectedItemColor,
      borderColor: borderColor ?? this.borderColor,
      dividerColor: dividerColor ?? this.dividerColor,
      errorColor: errorColor ?? this.errorColor,
      graphBackgroundColor: graphBackgroundColor ?? this.graphBackgroundColor,
      graphGridColor: graphGridColor ?? this.graphGridColor,
      graphAxisColor: graphAxisColor ?? this.graphAxisColor,
      graphLineColors: graphLineColors ?? this.graphLineColors,
      displayFontSize: displayFontSize ?? this.displayFontSize,
      secondaryDisplayFontSize:
          secondaryDisplayFontSize ?? this.secondaryDisplayFontSize,
      buttonFontSize: buttonFontSize ?? this.buttonFontSize,
      navFontSize: navFontSize ?? this.navFontSize,
      panelHeaderFontSize: panelHeaderFontSize ?? this.panelHeaderFontSize,
      bodyFontSize: bodyFontSize ?? this.bodyFontSize,
      buttonRadius: buttonRadius ?? this.buttonRadius,
      panelRadius: panelRadius ?? this.panelRadius,
      spacing: spacing ?? this.spacing,
      displayPadding: displayPadding ?? this.displayPadding,
      buttonPadding: buttonPadding ?? this.buttonPadding,
      panelPadding: panelPadding ?? this.panelPadding,
      borderThickness: borderThickness ?? this.borderThickness,
      minTouchTargetSize: minTouchTargetSize ?? this.minTouchTargetSize,
    );
  }
}
