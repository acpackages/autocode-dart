import 'dart:async';
import 'package:flutter/material.dart';

/// Carousel / slider widget for images, banners, or interactive cards.
class AcSlides extends StatefulWidget {
  final List<Widget> slides;
  final double height;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final bool showIndicators;
  final bool showArrows;
  final ValueChanged<int>? onPageChanged;

  const AcSlides({
    super.key,
    required this.slides,
    this.height = 200.0,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.showIndicators = true,
    this.showArrows = true,
    this.onPageChanged,
  });

  @override
  State<AcSlides> createState() => _AcSlidesState();
}

class _AcSlidesState extends State<AcSlides> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (widget.autoPlay && widget.slides.length > 1) {
      _timer?.cancel();
      _timer = Timer.periodic(widget.autoPlayInterval, (_) {
        if (_pageController.hasClients) {
          final next = (_currentIndex + 1) % widget.slides.length;
          _pageController.animateToPage(
            next,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slides.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return SizedBox(
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.slides.length,
            onPageChanged: (i) {
              setState(() {
                _currentIndex = i;
              });
              widget.onPageChanged?.call(i);
            },
            itemBuilder: (context, i) => widget.slides[i],
          ),

          // Previous arrow
          if (widget.showArrows && widget.slides.length > 1)
            Positioned(
              left: 8,
              child: IconButton.filledTonal(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  final prev = (_currentIndex - 1 + widget.slides.length) % widget.slides.length;
                  _pageController.animateToPage(
                    prev,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),

          // Next arrow
          if (widget.showArrows && widget.slides.length > 1)
            Positioned(
              right: 8,
              child: IconButton.filledTonal(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  final next = (_currentIndex + 1) % widget.slides.length;
                  _pageController.animateToPage(
                    next,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),

          // Dots indicator
          if (widget.showIndicators && widget.slides.length > 1)
            Positioned(
              bottom: 12,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.slides.length, (i) {
                  final isSelected = i == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isSelected ? 18 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isSelected ? theme.colorScheme.primary : theme.hintColor.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
