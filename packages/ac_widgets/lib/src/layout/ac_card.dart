import 'package:flutter/material.dart';

/// A card container with structured header, body, footer, actions, and media.
class AcCard extends StatelessWidget {
  final Widget? header;
  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Widget? media;
  final Widget? body;
  final Widget? footer;
  final List<Widget>? actions;
  final EdgeInsetsGeometry contentPadding;
  final VoidCallback? onTap;

  const AcCard({
    super.key,
    this.header,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.media,
    this.body,
    this.footer,
    this.actions,
    this.contentPadding = const EdgeInsets.all(16.0),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (media != null) media!,

        if (header != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: header!,
          ),
          Divider(height: 1, color: theme.dividerColor),
        ] else if (title != null) ...[
          ListTile(
            leading: leading,
            title: title,
            subtitle: subtitle,
            trailing: trailing,
          ),
        ],

        if (body != null)
          Padding(
            padding: contentPadding,
            child: body!,
          ),

        if (actions != null && actions!.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions!,
            ),
          ),
        ],

        if (footer != null) ...[
          Divider(height: 1, color: theme.dividerColor),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: footer!,
          ),
        ],
      ],
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: onTap != null ? InkWell(onTap: onTap, child: content) : content,
    );
  }
}
