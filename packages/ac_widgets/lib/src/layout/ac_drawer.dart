import 'package:flutter/material.dart';

/// Placement options for [AcDrawer].
enum AcDrawerPlacement {
  left,
  right,
  top,
  bottom,
}

/// A slide-out panel container that opens from any screen edge with an animated backdrop.
class AcDrawer extends StatelessWidget {
  final Widget child;
  final Widget? header;
  final Widget? footer;
  final double size;
  final VoidCallback? onClose;

  const AcDrawer({
    super.key,
    required this.child,
    this.header,
    this.footer,
    this.size = 320.0,
    this.onClose,
  });

  /// Displays the drawer modally from the specified placement.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    Widget? title,
    AcDrawerPlacement placement = AcDrawerPlacement.right,
    double size = 320.0,
  }) {
    if (placement == AcDrawerPlacement.bottom) {
      return showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => ConstrainedBox(
          constraints: BoxConstraints(maxHeight: size),
          child: child,
        ),
      );
    }

    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, _, __) {
        final isRight = placement == AcDrawerPlacement.right;
        return Align(
          alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
          child: Material(
            elevation: 16,
            child: SizedBox(
              width: size,
              height: double.infinity,
              child: Column(
                children: [
                  AppBar(
                    title: title,
                    automaticallyImplyLeading: false,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim, _, dialogChild) {
        final isRight = placement == AcDrawerPlacement.right;
        final begin = isRight ? const Offset(1, 0) : const Offset(-1, 0);
        return SlideTransition(
          position: Tween<Offset>(begin: begin, end: Offset.zero).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
          ),
          child: dialogChild,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      elevation: 4,
      child: Column(
        children: [
          if (header != null) ...[
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: header!,
            ),
            Divider(height: 1, color: theme.dividerColor),
          ],
          Expanded(child: child),
          if (footer != null) ...[
            Divider(height: 1, color: theme.dividerColor),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: footer!,
            ),
          ],
        ],
      ),
    );
  }
}
