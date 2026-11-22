import 'package:flutter/material.dart';

import '../theme.dart';

const double kDesktopBreakpoint = 900;

bool isDesktop(BuildContext context) =>
    MediaQuery.of(context).size.width >= kDesktopBreakpoint;

/// Centered, width-limited scrolling page. Wider padding on desktop.
class PageList extends StatelessWidget {
  const PageList({super.key, required this.children, this.maxWidth = 1180});
  final List<Widget> children;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final desktop = isDesktop(context);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ListView(
          padding: desktop
              ? const EdgeInsets.fromLTRB(32, 12, 32, 40)
              : const EdgeInsets.fromLTRB(18, 14, 18, 24),
          children: children,
        ),
      ),
    );
  }
}

/// Two columns on desktop, stacked on mobile.
class TwoColumn extends StatelessWidget {
  const TwoColumn(
      {super.key,
      required this.left,
      required this.right,
      this.leftFlex = 1,
      this.rightFlex = 1});
  final Widget left;
  final Widget right;
  final int leftFlex;
  final int rightFlex;

  @override
  Widget build(BuildContext context) {
    if (!isDesktop(context)) {
      return Column(children: [left, const SizedBox(height: 18), right]);
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(flex: leftFlex, child: left),
      const SizedBox(width: 24),
      Expanded(flex: rightFlex, child: right),
    ]);
  }
}

/// Raised / pressed neumorphic surface.
class NeuSurface extends StatelessWidget {
  const NeuSurface(
      {super.key,
      required this.child,
      this.radius = 20,
      this.inset = false,
      this.padding = const EdgeInsets.all(12),
      this.gradient});
  final Widget child;
  final double radius;
  final bool inset;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: inset ? AppColors.inset : AppColors.surface,
          gradient: gradient ??
              (inset
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFDDE0F2), Color(0xFFF2F3FC)])
                  : null),
          boxShadow: inset ? null : softShadow(.55),
        ),
        child: child,
      );
}

class NeuIconButton extends StatelessWidget {
  const NeuIconButton(
      {super.key, required this.icon, required this.onPressed, this.tooltip, this.dot = false});
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final bool dot;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip ?? '',
        child: GestureDetector(
          onTap: onPressed,
          child: Stack(clipBehavior: Clip.none, children: [
            NeuSurface(
                radius: 16,
                padding: const EdgeInsets.all(11),
                child: Icon(icon, size: 22, color: AppColors.text)),
            if (dot)
              Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                          color: AppColors.purple, shape: BoxShape.circle))),
          ]),
        ),
      );
}
