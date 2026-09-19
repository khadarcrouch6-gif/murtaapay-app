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

  /// Standard button height that scales with screen size.
  double get buttonHeight => 56.0 * fontSizeFactor;

  /// Standard elevated button style.
  ButtonStyle elevatedButtonStyle({
    Color? backgroundColor,
    Color? foregroundColor,
    double? height,
    double? borderRadius,
    double? elevation,
    EdgeInsetsGeometry? padding,
    Size? minimumSize,
    bool fullWidth = true,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      minimumSize: minimumSize ?? (fullWidth ? Size(double.infinity, (height ?? 56.0) * fontSizeFactor) : null),
      padding: padding ?? EdgeInsets.symmetric(horizontal: 16 * fontSizeFactor),
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular((borderRadius ?? 16.0) * fontSizeFactor),
      ),
      textStyle: TextStyle(
        fontSize: 16 * fontSizeFactor,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Standard outlined button style.
  ButtonStyle outlinedButtonStyle({
    Color? foregroundColor,
    double? height,
    double? borderRadius,
    BorderSide? side,
    EdgeInsetsGeometry? padding,
    Size? minimumSize,
    bool fullWidth = true,
  }) {
    return OutlinedButton.styleFrom(
      foregroundColor: foregroundColor,
      minimumSize: minimumSize ?? (fullWidth ? Size(double.infinity, (height ?? 56.0) * fontSizeFactor) : null),
      padding: padding ?? EdgeInsets.symmetric(horizontal: 16 * fontSizeFactor),
      side: side,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular((borderRadius ?? 16.0) * fontSizeFactor),
      ),
      textStyle: TextStyle(
        fontSize: 16 * fontSizeFactor,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Standard text button style.
  ButtonStyle textButtonStyle({
    Color? foregroundColor,
    double? height,
    double? fontSize,
    bool fullWidth = true,
  }) {
    return TextButton.styleFrom(
      foregroundColor: foregroundColor,
      minimumSize: fullWidth ? Size(double.infinity, (height ?? 48.0) * fontSizeFactor) : null,
      textStyle: TextStyle(
        fontSize: (fontSize ?? 15.0) * fontSizeFactor,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  /// Standard button style that respects responsiveness.
  ButtonStyle get responsiveButtonStyle => elevatedButtonStyle();

  /// Standard outlined button style that respects responsiveness.
  ButtonStyle get responsiveOutlinedButtonStyle => outlinedButtonStyle();

  /// Wrap content in a MaxWidthBox for desktop readability.
  Widget responsiveBody({required Widget child, double maxWidth = 1200}) {
    return MaxWidthBox(
      maxWidth: maxWidth,
      child: child,
    );
  }
}
