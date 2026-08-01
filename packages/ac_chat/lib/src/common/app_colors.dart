import 'package:flutter/material.dart';
// ─────────────────────────────────────────────────────────────
// AppColors — static brand tokens (light mode reference values)
// Use Theme.of(context).colorScheme / Theme.of(context).cardColor
// in widgets for dark-mode-aware values.
// ─────────────────────────────────────────────────────────────

class ChatAppColors {
  // Brand
  static const primary = Colors.deepOrange;

  // Semantics (always same regardless of mode)
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const danger  =Color(0xFFEF4444);

  // Light-mode palette
  static const white      = Color(0xFFFFFFFF);
  static const black      = Color(0xFF121212);
  static const background = Color(0xFFF5F5F7);
  static const card       = Color(0xFFFFFFFF);
  static const border     = Color(0xFFE5E5EA);
  static const textPrimary   = Color(0xFF121212);
  static const textSecondary = Color(0xFF6E6E73);

  // ─── Dark-mode near-black palette ───
  static const darkBg       = Color(0xFF0C0C0F); // deepest bg
  static const darkSurface  = Color(0xFF151515); // card/tile bg
  static const darkSurface2 = Color(0xFF1C1C1F); // slightly raised
  static const darkAppBar   = Color(0xFF111113); // app bar
  static const darkBorder   = Color(0xFF252528); // dividers
  static const darkText     = Color(0xFFEFEFF1); // primary text
  static const darkSubText  = Color(0xFF8E8E96); // secondary text

  // Chat bubbles (dark)
  static const darkSentBubble = Color(0xFF1C2B3A); // dark navy-blue
  static const darkRecvBubble = Color(0xFF161618); // same as surface

  // Chat bubbles (light)
  static const lightSentBubble = Color(0xFFE8F5E9); // light green tint
  static const lightRecvBubble = Color(0xFFFFFFFF);
}
