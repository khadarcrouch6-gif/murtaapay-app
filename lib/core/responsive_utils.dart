import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

extension ResponsiveUtils on BuildContext {
  /// Check if the current screen is mobile.
  bool get isMobile => ResponsiveBreakpoints.of(this).isMobile;

  /// Check if the current screen is tablet.
  bool get isTablet => ResponsiveBreakpoints.of(this).isTablet;

  /// Check if the current screen is desktop.
  bool get isDesktop => ResponsiveBreakpoints.of(this).isDesktop;

  /// Get a responsive value based on the current breakpoint.
  T responsiveValue<T>({
    required T mobile,
    T? tablet,
    T? desktop,
    T? ultra,
  }) {
    return ResponsiveValue<T>(
      this,
      defaultValue: mobile,
      conditionalValues: [
        if (tablet != null) Condition.largerThan(name: MOBILE, value: tablet),
        if (desktop != null) Condition.largerThan(name: TABLET, value: desktop),
        if (ultra != null) Condition.largerThan(name: DESKTOP, value: ultra),
      ],
    ).value;
  }

  /// Standard horizontal margin that scales with screen size.
  double get horizontalPadding => responsiveValue(
        mobile: 24.0,
        tablet: 48.0,
        desktop: 80.0,
      );

  /// Standard vertical spacing that scales with screen size.
  double get verticalPadding => responsiveValue(
        mobile: 24.0,
        tablet: 32.0,
        desktop: 40.0,
      );

  /// Responsive font size factor.
  double get fontSizeFactor => responsiveValue(
        mobile: 1.0,
        tablet: 1.1,
        desktop: 1.25,
      );

  /// Wrap content in a MaxWidthBox for desktop readability.
  Widget responsiveBody({required Widget child, double maxWidth = 1200}) {
    return MaxWidthBox(
      maxWidth: maxWidth,
      child: child,
    );
  }
}
