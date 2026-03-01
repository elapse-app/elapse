import 'dart:math';

import 'package:flutter/material.dart';

enum LoadingSize { fullScreen, section }

class ElapseLoadingIndicator extends StatefulWidget {
  const ElapseLoadingIndicator({
    super.key,
    required this.message,
    this.size = LoadingSize.section,
    this.icon,
  });

  final String message;
  final LoadingSize size;
  final IconData? icon;

  @override
  State<ElapseLoadingIndicator> createState() => _ElapseLoadingIndicatorState();
}

class _ElapseLoadingIndicatorState extends State<ElapseLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.size == LoadingSize.fullScreen) {
      return _buildFullScreen(context);
    }
    return _buildSection(context);
  }

  Widget _buildFullScreen(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = widget.icon ?? Icons.hourglass_empty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _BreathingIcon(icon: icon, color: colorScheme.secondary),
          const SizedBox(height: 20),
          Text(
            widget.message,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          _PulsingDots(controller: _controller, color: colorScheme.secondary),
          const SizedBox(height: 16),
          SizedBox(
            width: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                minHeight: 3,
                color: colorScheme.secondary,
                backgroundColor: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            widget.message,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon with a gentle breathing opacity animation (0.4 → 1.0, 2s, easeInOut).
class _BreathingIcon extends StatefulWidget {
  const _BreathingIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  State<_BreathingIcon> createState() => _BreathingIconState();
}

class _BreathingIconState extends State<_BreathingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Icon(
        widget.icon,
        size: 48,
        color: widget.color,
      ),
    );
  }
}

/// Three dots that pulse opacity in a wave pattern (120° phase offset each).
class _PulsingDots extends StatelessWidget {
  const _PulsingDots({required this.controller, required this.color});

  final AnimationController controller;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            // Phase offset: 0°, 120°, 240°
            final phase = index * 2 * pi / 3;
            final sinValue = sin(controller.value * 2 * pi - phase);
            // Map sin [-1, 1] to opacity [0.2, 1.0]
            final opacity = 0.2 + (sinValue + 1) / 2 * 0.8;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: opacity),
              ),
            );
          }),
        );
      },
    );
  }
}
