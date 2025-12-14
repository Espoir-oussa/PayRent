// Bottom sheet pour choisir la source d'image
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../config/colors.dart';

/// Affiche un bottom sheet pour choisir entre caméra et galerie
Future<ImageSource?> showImagePickerBottomSheet(BuildContext context) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const ImagePickerBottomSheet(),
  );
}

class ImagePickerBottomSheet extends StatelessWidget {
  const ImagePickerBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Poignée
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            // Titre
            const Text(
              'Choisir une photo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Option Caméra
            _ImageSourceOption(
              icon: Icons.camera_alt,
              label: 'Prendre une photo',
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            
            const SizedBox(height: 8),
            
            // Option Galerie
            _ImageSourceOption(
              icon: Icons.photo_library,
              label: 'Choisir depuis la galerie',
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            
            const SizedBox(height: 16),
            
            // Bouton Annuler
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Annuler',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ),
            
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.accentRed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.accentRed),
      ),
      title: Text(label),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
