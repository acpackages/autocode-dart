import 'package:flutter/material.dart';

/// Supported modal dialog sizes.
enum AcModalSize {
  small,
  medium,
  large,
  fullScreen,
}

/// A structured dialog container with header, body, footer actions, and responsive sizing.
class AcModal extends StatelessWidget {
  final Widget? title;
  final Widget body;
  final List<Widget>? actions;
  final AcModalSize size;
  final bool showCloseButton;
  final VoidCallback? onClose;

  const AcModal({
    super.key,
    this.title,
    required this.body,
    this.actions,
    this.size = AcModalSize.medium,
    this.showCloseButton = true,
    this.onClose,
  });

  /// Displays the modal dialog.
  static Future<T?> show<T>({
    required BuildContext context,
    Widget? title,
    required Widget body,
    List<Widget>? actions,
    AcModalSize size = AcModalSize.medium,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (ctx) => AcModal(
        title: title,
        body: body,
        actions: actions,
        size: size,
        onClose: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  double _getMaxWidth() {
    switch (size) {
      case AcModalSize.small:
        return 400.0;
      case AcModalSize.medium:
        return 600.0;
      case AcModalSize.large:
        return 860.0;
      case AcModalSize.fullScreen:
        return double.infinity;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxWidth = _getMaxWidth();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: DefaultTextStyle(
                      style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                      child: title ?? const SizedBox(),
                    ),
                  ),
                  if (showCloseButton)
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: onClose ?? () => Navigator.of(context).pop(),
                      splashRadius: 16,
                    ),
                ],
              ),
            ),
            Divider(height: 1, color: theme.dividerColor),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: body,
              ),
            ),

            // Footer
            if (actions != null && actions!.isNotEmpty) ...[
              Divider(height: 1, color: theme.dividerColor),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
