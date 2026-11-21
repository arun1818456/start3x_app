import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Breakpoints for responsive design
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

/// Returns true if the current screen width is considered "wide" (tablet/desktop)
bool isWideScreen(BuildContext context) {
  return MediaQuery.of(context).size.width >= Breakpoints.mobile;
}

/// Returns true if running on web with a desktop-sized window
bool isDesktopWeb(BuildContext context) {
  return kIsWeb && MediaQuery.of(context).size.width >= Breakpoints.tablet;
}

/// A wrapper that constrains content to a max width and centers it.
/// Useful for making mobile-designed screens look good on wide web layouts.
class WebContentWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final Color? backgroundColor;

  const WebContentWrapper({
    super.key,
    required this.child,
    this.maxWidth = 500,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;

    return Container(
      color: backgroundColor ?? Colors.grey.shade100,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}

/// A wrapper that provides a max-width constraint for page content
/// while letting it fill the available space on mobile.
class ResponsivePageWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsivePageWrapper({
    super.key,
    required this.child,
    this.maxWidth = 900,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (!kIsWeb || screenWidth < Breakpoints.mobile) {
      return child;
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}
