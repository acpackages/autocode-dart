import 'package:flutter/material.dart';

/// Top application navigation bar with branding, action links, and mobile responsive collapse.
class AcNavbar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? brand;
  final List<Widget>? navLinks;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final double height;
  final Widget? leading;

  const AcNavbar({
    super.key,
    this.brand,
    this.navLinks,
    this.actions,
    this.backgroundColor,
    this.height = 56.0,
    this.leading,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = backgroundColor ?? theme.colorScheme.surface;

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: bg,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 8),
          ],
          if (brand != null) ...[
            DefaultTextStyle(
              style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
              child: brand!,
            ),
            const SizedBox(width: 24),
          ],
          if (navLinks != null)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: navLinks!.map((link) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: link,
                    );
                  }).toList(),
                ),
              ),
            )
          else
            const Spacer(),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
