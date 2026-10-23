import 'package:flutter/material.dart';

/// Single item within [AcTabs].
class AcTabItem {
  final Widget label;
  final Widget? icon;
  final Widget? badge;
  final Widget content;

  const AcTabItem({
    required this.label,
    this.icon,
    this.badge,
    required this.content,
  });
}

/// A tabbed navigation widget combining headers, optional badges/icons, and content views.
class AcTabs extends StatefulWidget {
  final List<AcTabItem> tabs;
  final int initialIndex;
  final ValueChanged<int>? onTabChanged;
  final bool isScrollable;

  const AcTabs({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.onTabChanged,
    this.isScrollable = false,
  });

  @override
  State<AcTabs> createState() => _AcTabsState();
}

class _AcTabsState extends State<AcTabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabs.length,
      initialIndex: widget.initialIndex,
      vsync: this,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        widget.onTabChanged?.call(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: theme.dividerColor)),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: widget.isScrollable,
            tabs: widget.tabs.map((tab) {
              return Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (tab.icon != null) ...[
                      tab.icon!,
                      const SizedBox(width: 8),
                    ],
                    tab.label,
                    if (tab.badge != null) ...[
                      const SizedBox(width: 8),
                      tab.badge!,
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.tabs.map((t) => t.content).toList(),
          ),
        ),
      ],
    );
  }
}
