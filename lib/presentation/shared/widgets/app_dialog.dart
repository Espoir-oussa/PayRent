// Widgets de dialogues réutilisables
import 'package:flutter/material.dart';
import '../../../config/colors.dart';

/// Affiche un dialogue de confirmation
Future<bool?> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Confirmer',
  String cancelText = 'Annuler',
  bool isDanger = false,
  IconData? icon,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AppConfirmDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      isDanger: isDanger,
      icon: icon,
    ),
  );
}

class AppConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDanger;
  final IconData? icon;

  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirmer',
    this.cancelText = 'Annuler',
    this.isDanger = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: isDanger ? Colors.red : AppColors.accentRed,
              size: 28,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancelText,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isDanger ? Colors.red : AppColors.accentRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmText),
        ),
      ],
    );
  }
}

/// Affiche un dialogue d'information
Future<void> showAppInfoDialog(
  BuildContext context, {
  required String title,
  required String message,
  String buttonText = 'OK',
  IconData? icon,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.accentRed, size: 28),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: Text(message),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(buttonText),
        ),
      ],
    ),
  );
}

/// Affiche un dialogue de chargement
void showAppLoadingDialog(BuildContext context, {String? message}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AppLoadingDialog(message: message),
  );
}

class AppLoadingDialog extends StatelessWidget {
  final String? message;

  const AppLoadingDialog({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentRed),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ],
      ),
    );
  }
}

/// Bottom sheet avec formulaire
Future<T?> showAppFormBottomSheet<T>(
  BuildContext context, {
  required String title,
  required Widget content,
  IconData? icon,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => AppFormBottomSheet(
      title: title,
      icon: icon,
      content: content,
    ),
  );
}

class AppFormBottomSheet extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget content;

  const AppFormBottomSheet({
    super.key,
    required this.title,
    this.icon,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Header
              Row(
                children: [
                  if (icon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.accentRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: AppColors.accentRed),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Content
              content,
            ],
          ),
        ),
      ),
    );
  }
}
