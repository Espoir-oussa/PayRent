// Widget de carte réutilisable
import 'package:flutter/material.dart';
import '../../../config/colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? backgroundColor;
  final double elevation;
  final Widget? header;
  final Widget? footer;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius = 16,
    this.backgroundColor,
    this.elevation = 2,
    this.header,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (header != null) header!,
        Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
        if (footer != null) footer!,
      ],
    );

    return Card(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      elevation: elevation,
      color: backgroundColor ?? Colors.white,
      clipBehavior: Clip.antiAlias,
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              child: content,
            )
          : content,
    );
  }
}

/// Carte avec image en haut
class AppImageCard extends StatelessWidget {
  final String? imageUrl;
  final String? localImagePath;
  final Widget? imagePlaceholder;
  final double imageHeight;
  final Widget child;
  final VoidCallback? onTap;
  final Widget? badge;
  final Widget? menuButton;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const AppImageCard({
    super.key,
    this.imageUrl,
    this.localImagePath,
    this.imagePlaceholder,
    this.imageHeight = 150,
    required this.child,
    this.onTap,
    this.badge,
    this.menuButton,
    this.padding,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Stack(
              children: [
                SizedBox(
                  height: imageHeight,
                  width: double.infinity,
                  child: _buildImage(),
                ),
                if (badge != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: badge!,
                  ),
                if (menuButton != null)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: menuButton!,
                  ),
              ],
            ),
            // Contenu
            Padding(
              padding: padding ?? const EdgeInsets.all(12),
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    if (imagePlaceholder != null) return imagePlaceholder!;
    
    return Container(
      color: AppColors.primaryDark.withOpacity(0.1),
      child: Icon(
        Icons.image_outlined,
        size: 50,
        color: AppColors.primaryDark.withOpacity(0.5),
      ),
    );
  }
}

/// Badge pour les cartes
class AppBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;

  const AppBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
