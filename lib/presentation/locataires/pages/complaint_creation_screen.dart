// ===============================
// 📝 Écran : Création de Plainte (Locataire)
//
// Ce fichier définit l'interface utilisateur pour la création et le suivi des plaintes par le locataire.
//
// Dossier : lib/presentation/locataires/pages/
// Rôle : UI pour dépôt et suivi des plaintes
// Utilisé par : Locataires
// ===============================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/colors.dart';
import '../../../core/di/providers.dart';
import '../../../data/models/plainte_model.dart';

class ComplaintCreationScreen extends ConsumerStatefulWidget {
  final String locataireId;
  final String bienId;
  final String proprietaireId;

  const ComplaintCreationScreen({
    super.key,
    required this.locataireId,
    required this.bienId,
    required this.proprietaireId,
  });

  @override
  ConsumerState<ComplaintCreationScreen> createState() =>
      _ComplaintCreationScreenState();
}

class _ComplaintCreationScreenState
    extends ConsumerState<ComplaintCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final plainte = PlainteModel(
        idPlainte: 0,
        idLocataire: widget.locataireId,
        idBien: widget.bienId,
        idProprietaireGestionnaire: widget.proprietaireId,
        dateCreation: DateTime.now(),
        sujet: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
        statutPlainte: 'Ouverte',
      );

      final createComplaintUseCase = ref.read(createComplaintUseCaseProvider);
      await createComplaintUseCase(plainte);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plainte déposée avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Déposer une plainte'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Information
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[700]),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Décrivez le problème rencontré dans votre logement',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Sujet
              const Text(
                'Sujet de la plainte',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                  hintText: 'Ex: Problème de plomberie',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le sujet est obligatoire';
                  }
                  if (value.trim().length < 5) {
                    return 'Le sujet doit contenir au moins 5 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Description
              const Text(
                'Description détaillée',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Décrivez en détail le problème rencontré...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La description est obligatoire';
                  }
                  if (value.trim().length < 20) {
                    return 'Veuillez fournir plus de détails (min. 20 caractères)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Bouton de soumission
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitComplaint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Soumettre la plainte',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
