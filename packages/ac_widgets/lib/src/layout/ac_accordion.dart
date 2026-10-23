import 'package:flutter/material.dart';

/// Single item within an [AcAccordion].
class AcAccordionItem {
  final Widget title;
  final Widget content;
  final Widget? leading;
  final bool initiallyExpanded;

  const AcAccordionItem({
    required this.title,
    required this.content,
    this.leading,
    this.initiallyExpanded = false,
  });
}

/// An accordion widget providing collapsible panels with single or multiple expansion.
class AcAccordion extends StatefulWidget {
  final List<AcAccordionItem> items;
  final bool allowMultipleExpanded;
  final EdgeInsetsGeometry padding;

  const AcAccordion({
    super.key,
    required this.items,
    this.allowMultipleExpanded = false,
    this.padding = EdgeInsets.zero,
  });

  @override
  State<AcAccordion> createState() => _AcAccordionState();
}

class _AcAccordionState extends State<AcAccordion> {
  late List<bool> _expandedStates;

  @override
  void initState() {
    super.initState();
    _expandedStates = widget.items.map((it) => it.initiallyExpanded).toList();
  }

  void _onToggle(int index) {
    setState(() {
      if (!widget.allowMultipleExpanded) {
        final current = _expandedStates[index];
        for (int i = 0; i < _expandedStates.length; i++) {
          _expandedStates[i] = false;
        }
        _expandedStates[index] = !current;
      } else {
        _expandedStates[index] = !_expandedStates[index];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.items.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: theme.dividerColor),
        itemBuilder: (context, i) {
          final item = widget.items[i];
          final isExpanded = _expandedStates[i];

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => _onToggle(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  child: Row(
                    children: [
                      if (item.leading != null) ...[
                        item.leading!,
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: DefaultTextStyle(
                          style: theme.textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),
                          child: item.title,
                        ),
                      ),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(Icons.expand_more, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity, height: 0),
                secondChild: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: item.content,
                ),
                crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
            ],
          );
        },
      ),
    );
  }
}
