import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// A utility widget that automatically renders either a standard [Icon] or
/// a [FaIcon] depending on the type of icon data provided.
///
/// This simplifies the migration to font_awesome_flutter v11.0.0+ where
/// [FaIconData] is no longer directly compatible with the [Icon] widget.
class AdaptiveIcon extends StatelessWidget {
  final dynamic icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  const AdaptiveIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (icon == null) return const SizedBox.shrink();

    if (icon is FaIconData) {
      return FaIcon(
        icon as FaIconData,
        size: size,
        color: color,
        semanticLabel: semanticLabel,
      );
    }

    if (icon is IconData) {
      return Icon(
        icon as IconData,
        size: size,
        color: color,
        semanticLabel: semanticLabel,
      );
    }

    // Fallback for cases where it might be wrapped or dynamic
    try {
      return FaIcon(
        icon,
        size: size,
        color: color,
        semanticLabel: semanticLabel,
      );
    } catch (_) {
      return Icon(
        icon,
        size: size,
        color: color,
        semanticLabel: semanticLabel,
      );
    }
  }
}
