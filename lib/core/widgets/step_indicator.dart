import 'package:flutter/material.dart';
import '../responsive_utils.dart';

class StepIndicator extends StatelessWidget {
  final int step;
  final String label;
  final bool isActive;
  final bool isCompleted;
  final bool isHeader;

  const StepIndicator({
    super.key,
    required this.step,
    required this.label,
    required this.isActive,
    required this.isCompleted,
    this.isHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSizeFactor = context.fontSizeFactor;
    
    Color activeColor = isHeader ? Colors.white : theme.colorScheme.secondary;
    Color inactiveColor = isHeader 
        ? Colors.white.withOpacity(0.3) 
        : theme.dividerColor.withOpacity(0.1);
    
    Color textColor = isHeader 
        ? (isActive ? Colors.white : Colors.white.withOpacity(0.6)) 
        : (isActive ? theme.colorScheme.secondary : theme.textTheme.bodySmall?.color ?? Colors.grey);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32 * fontSizeFactor,
          height: 32 * fontSizeFactor,
          decoration: BoxDecoration(
            color: isActive || isCompleted ? activeColor : inactiveColor,
            shape: BoxShape.circle,
            border: isActive 
                ? Border.all(
                    color: activeColor.withOpacity(0.2), 
                    width: 4 * fontSizeFactor
                  ) 
                : null,
          ),
          child: Center(
            child: isCompleted && !isActive
                ? Icon(
                    Icons.check,
                    color: isHeader ? theme.colorScheme.secondary : Colors.white,
                    size: 18 * fontSizeFactor,
                  )
                : Text(
                    "$step",
                    style: TextStyle(
                      color: isHeader 
                          ? (isActive || isCompleted ? theme.colorScheme.secondary : Colors.white) 
                          : Colors.white,
                      fontSize: 14 * fontSizeFactor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 4 * fontSizeFactor),
        SizedBox(
          width: 60 * fontSizeFactor,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10 * fontSizeFactor,
              fontWeight: isActive ? FontWeight.w900 : FontWeight.bold,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class StepLine extends StatelessWidget {
  final bool isCompleted;
  final bool isHeader;

  const StepLine({
    super.key,
    required this.isCompleted,
    this.isHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontSizeFactor = context.fontSizeFactor;
    
    Color color = isHeader
        ? (isCompleted ? Colors.white : Colors.white.withOpacity(0.3))
        : (isCompleted 
            ? theme.colorScheme.secondary 
            : theme.dividerColor.withOpacity(0.1));

    return Expanded(
      child: Container(
        height: 3 * fontSizeFactor,
        margin: EdgeInsets.symmetric(horizontal: 6 * fontSizeFactor),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10 * fontSizeFactor),
        ),
      ),
    );
  }
}
