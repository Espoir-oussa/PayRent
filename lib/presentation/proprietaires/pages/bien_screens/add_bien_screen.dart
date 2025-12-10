// Fichier : lib/presentation/proprietaires/pages/bien_screens/add_bien_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/colors.dart';
import 'add_bien_controller.dart';
import 'add_bien_state.dart';

/// Écran pour ajouter un nouveau bien immobilier
class AddBienScreen extends ConsumerStatefulWidget {
  final int idProprietaire;

  const AddBienScreen({
    Key? key,
    required this.idProprietaire,
  }) : super(key: key);

  @override
  ConsumerState<AddBienScreen> createState() => _AddBienScreenState();
}

class _AddBienScreenState extends ConsumerState<AddBienScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers pour les champs de formulaire
  final _adresseController = TextEditingController();
  final _loyerController = TextEditingController();
  final _chargesController = TextEditingController();

  String? _typeBien;

  @override
  void dispose() {
    _adresseController.dispose();
    _loyerController.dispose();
    _chargesController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      // Récupérer le controller via Riverpod
      ref.read(addBienControllerProvider.notifier).createBien(
            idProprietaire: widget.idProprietaire,
            adresseComplete: _adresseController.text.trim(),
            loyerDeBase: double.parse(_loyerController.text),
            typeBien: _typeBien,
            chargesLocatives: _chargesController.text.isEmpty
                ? 0.0
                : double.parse(_chargesController.text),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observer l'état du controller
    final state = ref.watch(addBienControllerProvider);

    // Écouter les changements d'état pour navigation/messages
    ref.listen<AddBienState>(addBienControllerProvider, (previous, next) {
      if (next.status == AddBienStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Bien créé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        // Retourner à l'écran précédent avec le résultat
        Navigator.pop(context, true);
      } else if (next.status == AddBienStatus.failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('❌ Erreur : ${next.errorMessage ?? "Erreur inconnue"}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajouter un Bien',
          style: TextStyle(
            fontFamily: 'MuseoModerno',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.accentRed,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Titre de section
              Text(
                'Informations du bien',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'MuseoModerno',
                  color: AppColors.accentRed,
                ),
              ),
              const SizedBox(height: 16),

              // Champ Adresse
              TextFormField(
                controller: _adresseController,
                decoration: InputDecoration(
                  labelText: 'Adresse complète *',
                  hintText: 'Ex: 123 Rue de la Paix, Paris 75001',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.location_on),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'L\'adresse est obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Champ Type de bien
              DropdownButtonFormField<String>(
                value: _typeBien,
                decoration: InputDecoration(
                  labelText: 'Type de bien',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.home),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'Appartement', child: Text('Appartement')),
                  DropdownMenuItem(value: 'Maison', child: Text('Maison')),
                  DropdownMenuItem(value: 'Studio', child: Text('Studio')),
                  DropdownMenuItem(
                      value: 'Local commercial',
                      child: Text('Local commercial')),
                  DropdownMenuItem(value: 'Garage', child: Text('Garage')),
                  DropdownMenuItem(value: 'Autre', child: Text('Autre')),
                ],
                onChanged: (value) {
                  setState(() {
                    _typeBien = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Champ Loyer de base
              TextFormField(
                controller: _loyerController,
                decoration: InputDecoration(
                  labelText: 'Loyer de base (€) *',
                  hintText: 'Ex: 850',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.euro),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le loyer est obligatoire';
                  }
                  final loyer = double.tryParse(value);
                  if (loyer == null || loyer <= 0) {
                    return 'Le loyer doit être un nombre supérieur à 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Champ Charges locatives
              TextFormField(
                controller: _chargesController,
                decoration: InputDecoration(
                  labelText: 'Charges locatives (€)',
                  hintText: 'Ex: 50 (optionnel)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.receipt_long),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final charges = double.tryParse(value);
                    if (charges == null || charges < 0) {
                      return 'Les charges doivent être un nombre positif';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Note informative
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '* Champs obligatoires',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Bouton de soumission
              ElevatedButton(
                onPressed: state.status == AddBienStatus.loading
                    ? null
                    : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: state.status == AddBienStatus.loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Créer le bien',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'MuseoModerno',
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
