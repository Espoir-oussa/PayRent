import 'package:flutter/material.dart';
import '../../../config/colors.dart';

class SharedProfileForm extends StatelessWidget {
  final TextEditingController nomController;
  final TextEditingController prenomController;
  final TextEditingController telephoneController;
  final TextEditingController adresseController;
  final String email;
  final String? photoUrl;
  final bool isEditable;
  final bool isLoading;
  final bool isSaving;
  final bool isUploadingImage;
  final bool isLoggingOut;
  final VoidCallback? onPickImage;
  final VoidCallback? onSave;
  final VoidCallback? onLogout;
  final VoidCallback? onDelete;

  const SharedProfileForm({
    Key? key,
    required this.nomController,
    required this.prenomController,
    required this.telephoneController,
    required this.adresseController,
    required this.email,
    this.photoUrl,
    this.isEditable = true,
    this.isLoading = false,
    this.isSaving = false,
    this.isUploadingImage = false,
    this.isLoggingOut = false,
    this.onPickImage,
    this.onSave,
    this.onLogout,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: isEditable ? onPickImage : null,
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: AppColors.accentRed.withOpacity(0.1),
                    backgroundImage: (photoUrl != null && photoUrl!.isNotEmpty) ? NetworkImage(photoUrl!) : null,
                    child: isUploadingImage
                        ? const CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                        : (photoUrl == null || photoUrl!.isEmpty)
                            ? Text(
                                _getInitials(),
                                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.accentRed),
                              )
                            : null,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  email,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          _buildTextField(
            controller: nomController,
            label: 'Nom',
            icon: Icons.person_outline,
            enabled: isEditable,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: prenomController,
            label: 'Prénom',
            icon: Icons.person_outline,
            enabled: isEditable,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: telephoneController,
            label: 'Téléphone',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            enabled: isEditable,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: adresseController,
            label: 'Adresse',
            icon: Icons.location_on_outlined,
            maxLines: 2,
            enabled: isEditable,
          ),
          const SizedBox(height: 32),

          if (isEditable)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(isSaving ? 'Enregistrement...' : 'Enregistrer'),
              ),
            ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: isLoggingOut ? null : onLogout,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                side: BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: isLoggingOut
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      ),
                    )
                  : const Icon(Icons.logout_outlined),
              label: Text(isLoggingOut ? 'Déconnexion...' : 'Se déconnecter'),
            ),
          ),

          if (isEditable) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Zone de danger',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'La suppression de votre compte est définitive et irréversible.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    label: const Text(
                      'Supprimer mon compte',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getInitials() {
    final prenom = prenomController.text.trim();
    final nom = nomController.text.trim();
    String initials = '';
    if (prenom.isNotEmpty) initials += prenom[0].toUpperCase();
    if (nom.isNotEmpty) initials += nom[0].toUpperCase();
    return initials.isEmpty ? '?' : initials;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.accentRed),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.accentRed, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}