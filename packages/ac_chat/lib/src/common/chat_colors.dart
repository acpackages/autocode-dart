import 'package:flutter/material.dart';
import 'app_colors.dart';

// ─────────────────────────────────────────────────────────────
// _ChatColors — near-black dark + warm light palette for chat
// ─────────────────────────────────────────────────────────────

class _ChatColors {
  // ── Dark mode (near-black) ──
  static Color darkAppBar       = ChatAppColors.darkSurface;     // #111113
  static Color darkPrimaryColor = ChatAppColors.primary;     // #111113
  static Color darkScaffold     = ChatAppColors.darkSurface;         // #0C0C0F
  static Color darkSurface      = ChatAppColors.darkSurface;    // #161618
  static Color darkInputBar     = ChatAppColors.darkSurface;    // #161618
  static Color darkSentBubble   = ChatAppColors.darkSentBubble; // #1C2B3A  dark navy
  static Color darkRecvBubble   = ChatAppColors.darkSurface2;   // #1C1C1F
  static Color darkText         = ChatAppColors.darkText;        // #EFEFF1
  static Color darkSubText      = ChatAppColors.darkSubText;     // #8E8E96
  static Color darkDivider      = ChatAppColors.darkBorder;      // #252528
  static Color darkSearchFill   = ChatAppColors.darkSurface2;   // #1C1C1F
  static Color darkDateChip     = Color(0xFF17171A);
  static Color darkWallpaper    = Color(0xFF0A0A0D);         // slightly darker than bg
  static Color darkInputFill    = Color(0xFF1A1A1D);

  // ── Light mode ──
  static Color lightAppBar      = ChatAppColors.primary;         // orange brand
  static Color lightScaffold    = ChatAppColors.darkSurface;      // #F5F5F7
  static Color lightSurface     = ChatAppColors.white;
  static Color lightInputBar    = ChatAppColors.background;
  static Color lightSentBubble  = ChatAppColors.lightSentBubble; // #E8F5E9
  static Color lightRecvBubble  = ChatAppColors.white;
  static Color lightText        = ChatAppColors.textPrimary;
  static Color lightSubText     = ChatAppColors.textSecondary;
  static Color lightDivider     = ChatAppColors.border;
  static Color lightSearchFill  = ChatAppColors.white;
  static Color lightDateChip    = Color(0xFFD1EAF3);
  static Color lightWallpaper   = Color(0xFFEFE8DC);
  static Color lightInputFill   = ChatAppColors.white;

  // ── Always ──
  static Color waGreen      = Color(0xFF25D366);  // kept for unread badge only
  static Color readTick     = Color(0xFF53BDEB);
  static Color accentOrange = ChatAppColors.primary;

  // ── Avatar colours ──
  static const List<Color> avatarColors = [
    Color(0xFF6C4AB6),
    Color(0xFF2196F3),
    Color(0xFFE91E63),
    Color(0xFF009688),
    Color(0xFFFF5722),
    Color(0xFF795548),
    Color(0xFF607D8B),
    Color(0xFF4CAF50),
  ];
}

Color avatarColor(dynamic id) {
  if (id == null) return _ChatColors.avatarColors[0];
  int numericId = 0;
  if (id is int) {
    numericId = id;
  } else {
    numericId = id.toString().codeUnits.fold(0, (sum, item) => sum + item);
  }
  return _ChatColors.avatarColors[numericId % _ChatColors.avatarColors.length];
}

// ─────────────────────────────────────────────────────────────
// AcChatTheme — resolved colours
// ─────────────────────────────────────────────────────────────

class AcChatTheme {
  final bool isDark;
  final ThemeData? themeData;
  const AcChatTheme(this.isDark, [this.themeData]);

  bool get _isThemeDark => (themeData?.brightness == Brightness.dark) || isDark;

  Color get appBar => themeData?.appBarTheme.backgroundColor ?? themeData?.colorScheme.surface ?? (_isThemeDark ? _ChatColors.darkAppBar : _ChatColors.lightAppBar);
  Color get activeTabColor => themeData?.colorScheme.primary ?? ChatAppColors.primary;
  Color get activeConversationBackgroundColor => themeData?.colorScheme.surfaceContainer ?? (_isThemeDark ? _ChatColors.darkDivider : _ChatColors.lightDivider);
  Color get pinnedConversationBackgroundColor => themeData?.colorScheme.surfaceContainerLow ?? (_isThemeDark ? ChatAppColors.darkSurface : _ChatColors.lightSurface);
  Color get scaffold    => themeData?.scaffoldBackgroundColor ?? (_isThemeDark ? _ChatColors.darkScaffold : _ChatColors.lightScaffold);
  Color get surface     => themeData?.colorScheme.surface ?? themeData?.cardColor ?? (_isThemeDark ? _ChatColors.darkSurface : _ChatColors.lightSurface);
  Color get inputBar    => themeData?.colorScheme.surfaceContainer ?? (_isThemeDark ? _ChatColors.darkInputBar : _ChatColors.lightInputBar);
  Color get sentBubble  => themeData?.colorScheme.primaryContainer ?? (_isThemeDark ? _ChatColors.darkSentBubble : _ChatColors.lightSentBubble);
  Color get recvBubble  => themeData?.colorScheme.surfaceContainerHighest ?? (_isThemeDark ? _ChatColors.darkRecvBubble : _ChatColors.lightRecvBubble);
  Color get text        => themeData?.colorScheme.onSurface ?? themeData?.textTheme.bodyLarge?.color ?? (_isThemeDark ? _ChatColors.darkText : _ChatColors.lightText);
  Color get subText     => themeData?.colorScheme.onSurfaceVariant ?? themeData?.textTheme.bodyMedium?.color ?? (_isThemeDark ? _ChatColors.darkSubText : _ChatColors.lightSubText);
  Color get divider     => themeData?.dividerColor ?? (_isThemeDark ? _ChatColors.darkDivider : _ChatColors.lightDivider);
  Color get searchFill  => themeData?.colorScheme.surfaceContainerHigh ?? (_isThemeDark ? _ChatColors.darkSearchFill : _ChatColors.lightSearchFill);
  Color get dateChip    => themeData?.colorScheme.secondaryContainer ?? (_isThemeDark ? _ChatColors.darkDateChip : _ChatColors.lightDateChip);
  Color get wallpaper   => themeData?.scaffoldBackgroundColor ?? (_isThemeDark ? _ChatColors.darkWallpaper : _ChatColors.lightWallpaper);
  Color get iconColor   => themeData?.colorScheme.onSurfaceVariant ?? (_isThemeDark ? _ChatColors.darkSubText : _ChatColors.lightSubText);
  Color get inputText   => themeData?.colorScheme.onSurface ?? themeData?.textTheme.bodyLarge?.color ?? (_isThemeDark ? _ChatColors.darkText : _ChatColors.lightText);
  Color get inputHint   => themeData?.colorScheme.onSurfaceVariant.withOpacity(0.6) ?? (_isThemeDark ? _ChatColors.darkSubText : _ChatColors.lightSubText);
  Color get inputFill   => themeData?.colorScheme.surfaceContainerLowest ?? (_isThemeDark ? _ChatColors.darkInputFill : _ChatColors.lightInputFill);

  // Direct and semantic colors derived from theme
  Color get white => Colors.white;
  Color get white70 => Colors.white70;
  Color get white60 => Colors.white60;
  Color get white30 => Colors.white30;
  Color get white24 => Colors.white24;
  Color get white12 => Colors.white12;
  Color get white10 => Colors.white10;
  Color get black => Colors.black;
  Color get black87 => Colors.black87;
  Color get black54 => Colors.black54;
  Color get black38 => Colors.black38;
  Color get black26 => Colors.black26;
  Color get black12 => Colors.black12;
  Color get transparent => Colors.transparent;
  Color get grey => Colors.grey;
  Color get greyShade100 => Colors.grey.shade100;
  Color get greyShade300 => Colors.grey.shade300;
  Color get greyShade900 => Colors.grey.shade900;

  // Custom semantic colors
  Color get chatTabLabelColor => Colors.white;
  Color get chatTabUnselectedLabelColor => Colors.white24;
  Color get chatFloatingActionButtonColor => Colors.white;
  Color get unreadBadgeBg => _ChatColors.waGreen;
  Color get readTick => _ChatColors.readTick;
  Color get messageDestructive => Colors.redAccent;
  Color get messageCheckIcon => Colors.grey;

  // Attachment categories bg
  Color get attachDocumentBg => const Color(0xFF7C4DFF);
  Color get attachCameraBg => const Color(0xFFFF3D00);
  Color get attachGalleryBg => const Color(0xFFE91E63);
  Color get attachAudioBg => const Color(0xFFFF6D00);
  Color get attachLocationBg => const Color(0xFF00897B);
  Color get attachContactBg => const Color(0xFF1565C0);
  Color get attachPaymentBg => _ChatColors.accentOrange;

  // Document types
  Color get docIconPdf => Colors.redAccent;
  Color get docIconExcel => Colors.green;
  Color get docIconWord => Colors.blue;
  Color get docIconPpt => Colors.orange;
  Color get docIconDefault => Colors.blue;

  Color get docBgPdf => Colors.red.withOpacity(0.1);
  Color get docBgExcel => Colors.green.withOpacity(0.1);
  Color get docBgWord => Colors.blue.withOpacity(0.1);
  Color get docBgPpt => Colors.orange.withOpacity(0.1);
  Color get docBgDefault => Colors.blue.withOpacity(0.1);

  // Profile status/indicators/actions
  Color get profileStatusOrange => Colors.orange;
  Color get profileStatusBlue => Colors.blue;
  Color get profileActionRed => Colors.redAccent;

  // New Chat screen custom colors
  Color get newChatGroupIconBg => const Color(0xFF5C6BC0);

  // Custom UI areas
  Color get chatBubbleMenuBg => _isThemeDark ? const Color(0xFF233138) : Colors.white;
  Color get chatHeaderBg => _isThemeDark ? const Color(0xFF1F2C34) : const Color(0xFFF0F2F5);
  Color get messageBubbleSystemBg => _isThemeDark ? const Color(0xFF1E2A30) : Colors.white;
  Color get messageBubbleAttachmentPreviewBg => _isThemeDark ? const Color(0xFF26353D) : const Color(0xFFF0F2F5);
}
