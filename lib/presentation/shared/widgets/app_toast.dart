// Fichier : lib/presentation/shared/widgets/app_toast.dart
// Composant Toast/Sonner style shadcn - notifications en haut au milieu

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/colors.dart';

/// Types de toast disponibles
enum ToastType { success, error, warning, info }

/// Configuration d'un toast
class ToastConfig {
  final String message;
  final String? title;
  final ToastType type;
  final Duration duration;
  final VoidCallback? onDismiss;

  const ToastConfig({
    required this.message,
    this.title,
    this.type = ToastType.info,
    this.duration = const Duration(seconds: 5),
    this.onDismiss,
  });
}

/// Service global pour afficher les toasts
class AppToast {
  static final AppToast _instance = AppToast._internal();
  factory AppToast() => _instance;
  AppToast._internal();

  static OverlayEntry? _currentOverlay;
  static bool _isVisible = false;

  /// Affiche un toast de succès
  static void success(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 5),
  }) {
    _show(
      context,
      ToastConfig(
        message: message,
        title: title ?? 'Succès',
        type: ToastType.success,
        duration: duration,
      ),
    );
  }

  /// Affiche un toast d'erreur
  static void error(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 5),
  }) {
    _show(
      context,
      ToastConfig(
        message: message,
        title: title ?? 'Erreur',
        type: ToastType.error,
        duration: duration,
      ),
    );
  }

  /// Affiche un toast d'avertissement
  static void warning(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 5),
  }) {
    _show(
      context,
      ToastConfig(
        message: message,
        title: title ?? 'Attention',
        type: ToastType.warning,
        duration: duration,
      ),
    );
  }

  /// Affiche un toast d'information
  static void info(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 5),
  }) {
    _show(
      context,
      ToastConfig(
        message: message,
        title: title ?? 'Information',
        type: ToastType.info,
        duration: duration,
      ),
    );
  }

  /// Méthode principale pour afficher le toast
  static void _show(BuildContext context, ToastConfig config) {
    // Ferme le toast actuel s'il existe
    _dismiss();

    final overlay = Overlay.of(context);

    _currentOverlay = OverlayEntry(
      builder: (context) => _ToastWidget(
        config: config,
        onDismiss: _dismiss,
      ),
    );

    overlay.insert(_currentOverlay!);
    _isVisible = true;

    // Auto-dismiss après la durée spécifiée
    Future.delayed(config.duration, () {
      if (_isVisible) {
        _dismiss();
        config.onDismiss?.call();
      }
    });
  }

  /// Ferme le toast actuel
  static void _dismiss() {
    if (_currentOverlay != null) {
      _currentOverlay!.remove();
      _currentOverlay = null;
      _isVisible = false;
    }
  }

  /// Ferme manuellement le toast (accessible publiquement)
  static void dismiss() => _dismiss();
}

/// Widget du toast avec animation
class _ToastWidget extends StatefulWidget {
  final ToastConfig config;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.config,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  double _dragOffset = 0;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDismiss() async {
    if (_isDismissing) return;
    _isDismissing = true;

    await _controller.reverse();
    widget.onDismiss();
  }

  Color _getBackgroundColor() {
    switch (widget.config.type) {
      case ToastType.success:
        return const Color(0xFF10B981); // Emerald-500
      case ToastType.error:
        return AppColors.accentRed;
      case ToastType.warning:
        return const Color(0xFFF59E0B); // Amber-500
      case ToastType.info:
        return AppColors.primaryDark;
    }
  }

  IconData _getIcon() {
    switch (widget.config.type) {
      case ToastType.success:
        return Icons.check_circle_rounded;
      case ToastType.error:
        return Icons.error_rounded;
      case ToastType.warning:
        return Icons.warning_rounded;
      case ToastType.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final toastWidth = screenWidth > 500 ? 400.0 : screenWidth * 0.9;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: (screenWidth - toastWidth) / 2,
      width: toastWidth,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              setState(() {
                _dragOffset += details.delta.dy;
              });
            },
            onVerticalDragEnd: (details) {
              // Si glissé vers le haut de plus de 50px, dismiss
              if (_dragOffset < -50 ||
                  details.velocity.pixelsPerSecond.dy < -500) {
                _handleDismiss();
              } else {
                // Reset position
                setState(() {
                  _dragOffset = 0;
                });
              }
            },
            onTap: _handleDismiss,
            child: Transform.translate(
              offset: Offset(0, _dragOffset.clamp(-100.0, 0.0)),
              child: Opacity(
                opacity: (1 - (_dragOffset.abs() / 100)).clamp(0.0, 1.0),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: _getBackgroundColor(),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _getBackgroundColor().withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Icône
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getIcon(),
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Contenu
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.config.title != null)
                                Text(
                                  widget.config.title!,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              const SizedBox(height: 2),
                              Text(
                                widget.config.message,
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.95),
                                  fontSize: 13,
                                  height: 1.3,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Bouton fermer
                        GestureDetector(
                          onTap: _handleDismiss,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.close_rounded,
                              color: Colors.white.withOpacity(0.7),
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
