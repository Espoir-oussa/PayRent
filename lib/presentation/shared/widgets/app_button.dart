// Widgets de boutons réutilisables
import 'package:flutter/material.dart';
import '../../../config/colors.dart';

enum AppButtonVariant { primary, secondary, outline, danger, text }

enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = _getHeight();
    final buttonStyle = _getButtonStyle();
    final textStyle = _getTextStyle();

    Widget child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == AppButtonVariant.outline ||
                        variant == AppButtonVariant.text
                    ? AppColors.accentRed
                    : Colors.white,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: _getIconSize()),
                const SizedBox(width: 8),
              ],
              Text(label, style: textStyle),
            ],
          );

    Widget button;
    
    switch (variant) {
      case AppButtonVariant.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: child,
        );
        break;
      case AppButtonVariant.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: child,
        );
        break;
      default:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: child,
        );
    }

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: button,
      );
    }

    return SizedBox(height: buttonHeight, child: button);
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return 40;
      case AppButtonSize.large:
        return 56;
      case AppButtonSize.medium:
      default:
        return 48;
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.large:
        return 24;
      case AppButtonSize.medium:
      default:
        return 20;
    }
  }

  TextStyle _getTextStyle() {
    double fontSize;
    switch (size) {
      case AppButtonSize.small:
        fontSize = 14;
        break;
      case AppButtonSize.large:
        fontSize = 18;
        break;
      case AppButtonSize.medium:
      default:
        fontSize = 16;
    }

    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
    );
  }

  ButtonStyle _getButtonStyle() {
    Color backgroundColor;
    Color foregroundColor;
    Color? borderColor;

    switch (variant) {
      case AppButtonVariant.secondary:
        backgroundColor = AppColors.primaryDark;
        foregroundColor = Colors.white;
        break;
      case AppButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.accentRed;
        borderColor = AppColors.accentRed;
        break;
      case AppButtonVariant.danger:
        backgroundColor = Colors.red;
        foregroundColor = Colors.white;
        break;
      case AppButtonVariant.text:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.accentRed;
        break;
      case AppButtonVariant.primary:
      default:
        backgroundColor = AppColors.accentRed;
        foregroundColor = Colors.white;
    }

    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      disabledBackgroundColor: backgroundColor.withOpacity(0.5),
      disabledForegroundColor: foregroundColor.withOpacity(0.5),
      elevation: variant == AppButtonVariant.text ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: borderColor != null
            ? BorderSide(color: borderColor)
            : BorderSide.none,
      ),
    );
  }
}

// Bouton icône circulaire
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final String? tooltip;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.accentRed.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: iconColor ?? AppColors.accentRed,
          size: size * 0.5,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}
