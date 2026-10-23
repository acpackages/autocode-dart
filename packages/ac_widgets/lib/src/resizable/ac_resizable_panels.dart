import 'package:flutter/material.dart';

/// Individual panel within an [AcResizablePanels] layout.
class AcResizablePanel {
  final Widget child;

  /// Initial size ratio (relative flex weight among panels, default 1.0).
  final double initialWeight;

  /// Minimum allowed pixel size for this panel.
  final double minSize;

  /// Maximum allowed pixel size for this panel.
  final double maxSize;

  const AcResizablePanel({
    required this.child,
    this.initialWeight = 1.0,
    this.minSize = 40.0,
    this.maxSize = double.infinity,
  });
}

/// A split-view widget with interactive draggable dividers between panels.
class AcResizablePanels extends StatefulWidget {
  final Axis direction;
  final List<AcResizablePanel> panels;
  final double dividerThickness;
  final Color? dividerColor;

  AcResizablePanels({
    super.key,
    this.direction = Axis.horizontal,
    required this.panels,
    this.dividerThickness = 6.0,
    this.dividerColor,
  }) : assert(panels.length >= 2, 'AcResizablePanels must have at least 2 panels');

  @override
  State<AcResizablePanels> createState() => _AcResizablePanelsState();
}

class _AcResizablePanelsState extends State<AcResizablePanels> {
  late List<double> _weights;

  @override
  void initState() {
    super.initState();
    _resetWeights();
  }

  @override
  void didUpdateWidget(covariant AcResizablePanels oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.panels.length != oldWidget.panels.length) {
      _resetWeights();
    }
  }

  void _resetWeights() {
    final total = widget.panels.fold<double>(0, (sum, p) => sum + p.initialWeight);
    _weights = widget.panels.map((p) => p.initialWeight / (total > 0 ? total : 1)).toList();
  }

  void _onDividerDrag(int dividerIndex, double deltaPixels, double totalAvailablePixels) {
    if (totalAvailablePixels <= 0) return;

    final deltaWeight = deltaPixels / totalAvailablePixels;
    setState(() {
      final leftIndex = dividerIndex;
      final rightIndex = dividerIndex + 1;

      final newLeftWeight = _weights[leftIndex] + deltaWeight;
      final newRightWeight = _weights[rightIndex] - deltaWeight;

      final leftMinWeight = widget.panels[leftIndex].minSize / totalAvailablePixels;
      final rightMinWeight = widget.panels[rightIndex].minSize / totalAvailablePixels;

      if (newLeftWeight >= leftMinWeight && newRightWeight >= rightMinWeight) {
        _weights[leftIndex] = newLeftWeight;
        _weights[rightIndex] = newRightWeight;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHorizontal = widget.direction == Axis.horizontal;
    final dividerPaintColor = widget.dividerColor ?? theme.dividerColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSize = isHorizontal ? constraints.maxWidth : constraints.maxHeight;
        final totalDividersThickness = (widget.panels.length - 1) * widget.dividerThickness;
        final availableSize = (totalSize - totalDividersThickness).clamp(0.0, double.infinity);

        final List<Widget> children = [];

        for (int i = 0; i < widget.panels.length; i++) {
          final panel = widget.panels[i];
          final panelSize = (availableSize * _weights[i]).clamp(0.0, availableSize);

          // Panel content
          children.add(
            SizedBox(
              width: isHorizontal ? panelSize : null,
              height: !isHorizontal ? panelSize : null,
              child: panel.child,
            ),
          );

          // Divider between panels
          if (i < widget.panels.length - 1) {
            final dividerIndex = i;
            children.add(
              MouseRegion(
                cursor: isHorizontal ? SystemMouseCursors.resizeLeftRight : SystemMouseCursors.resizeUpDown,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (details) {
                    final delta = isHorizontal ? details.delta.dx : details.delta.dy;
                    _onDividerDrag(dividerIndex, delta, availableSize);
                  },
                  child: Container(
                    width: isHorizontal ? widget.dividerThickness : null,
                    height: !isHorizontal ? widget.dividerThickness : null,
                    color: dividerPaintColor,
                    child: Center(
                      child: Container(
                        width: isHorizontal ? 2 : 24,
                        height: !isHorizontal ? 2 : 24,
                        decoration: BoxDecoration(
                          color: theme.hintColor.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        }

        return Flex(
          direction: widget.direction,
          children: children,
        );
      },
    );
  }
}
