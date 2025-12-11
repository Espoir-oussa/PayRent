// ===============================
// 🏢 Écran : Gestion des Biens (Propriétaire)
//
// Ce fichier définit l'interface utilisateur pour la gestion des biens immobiliers par le propriétaire.
//
// Dossier : lib/presentation/proprietaires/pages/
// Rôle : UI pour gestion des biens et ajout de locataires
// Utilisé par : Propriétaires
// ===============================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../config/colors.dart';
import '../../../core/di/providers.dart';
import '../../../data/models/bien_model.dart';
import '../../shared/widgets/invitation_modal.dart';
import 'bien_detail_screen.dart';
import '../../shared/pages/no_connection_page.dart';

class BienManagementScreen extends ConsumerStatefulWidget {
  const BienManagementScreen({super.key});

  @override
  ConsumerState<BienManagementScreen> createState() =>
      _BienManagementScreenState();
}

class _BienManagementScreenState extends ConsumerState<BienManagementScreen> {
  bool _isLoading = false;

  final List<String> _typesBien = [
    'appartement',
    'maison',
    'studio',
    'villa',
    'duplex',
    'local_commercial',
    'bureau',
    'terrain',
  ];

  String _getTypeDisplay(String type) {
    final map = {
      'appartement': 'Appartement',
      'maison': 'Maison',
      'studio': 'Studio',
      'villa': 'Villa',
      'duplex': 'Duplex',
      'local_commercial': 'Local commercial',
      'bureau': 'Bureau',
      'terrain': 'Terrain',
    };
    return map[type] ?? type;
  }

  String _formatMontant(double montant) {
    return '${montant.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        )} FCFA';
  }

  // Fonction pour supprimer un bien
  Future<void> _supprimerBien(BienModel bien) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.shade400),
            const SizedBox(width: 8),
            const Text('Supprimer le bien'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Voulez-vous vraiment supprimer "${bien.nom}" ?'),
            const SizedBox(height: 8),
            Text(
              'Cette action est irréversible.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true && bien.appwriteId != null) {
      try {
        setState(() => _isLoading = true);
        final bienRepository = ref.read(bienRepositoryProvider);
        await bienRepository.deleteBien(bien.appwriteId!);
        ref.invalidate(proprietaireBiensProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bien supprimé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
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
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // Modal pour inviter un locataire
  Future<void> _inviterLocataire(BienModel bien) async {
    final invitation = await showInvitationModal(
      context: context,
      ref: ref,
      bien: bien,
    );

    if (invitation != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invitation envoyée avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Modal pour modifier un bien
  void _modifierBien(BienModel bien) {
    final formKey = GlobalKey<FormState>();
    String nom = bien.nom;
    String adresse = bien.adresse;
    String? typeBien = bien.type;
    String loyer = bien.loyerMensuel.toStringAsFixed(0);
    String? description = bien.description;
    String? imagePath =
        bien.photosUrls?.isNotEmpty == true ? bien.photosUrls!.first : null;
    final ImagePicker picker = ImagePicker();
    XFile? pickedImage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.edit, color: Colors.blue),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Modifier le bien',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
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

                    // Image
                    GestureDetector(
                      onTap: () async {
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 85,
                        );
                        if (image != null) {
                          setModalState(() {
                            pickedImage = image;
                            imagePath = image.path;
                          });
                        }
                      },
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: pickedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.file(
                                  File(pickedImage!.path),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              )
                            : imagePath != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.file(
                                      File(imagePath!),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (_, __, ___) =>
                                          _buildImagePlaceholder(),
                                    ),
                                  )
                                : _buildImagePlaceholder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Nom
                    TextFormField(
                      initialValue: nom,
                      decoration: InputDecoration(
                        labelText: 'Nom du bien *',
                        prefixIcon: const Icon(Icons.home_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) =>
                          value?.isEmpty == true ? 'Champ requis' : null,
                      onChanged: (value) => nom = value,
                    ),
                    const SizedBox(height: 16),

                    // Adresse
                    TextFormField(
                      initialValue: adresse,
                      decoration: InputDecoration(
                        labelText: 'Adresse *',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) =>
                          value?.isEmpty == true ? 'Champ requis' : null,
                      onChanged: (value) => adresse = value,
                    ),
                    const SizedBox(height: 16),

                    // Type
                    DropdownButtonFormField<String>(
                      value: typeBien,
                      decoration: InputDecoration(
                        labelText: 'Type de bien *',
                        prefixIcon: const Icon(Icons.home_work_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      items: _typesBien
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(_getTypeDisplay(type)),
                              ))
                          .toList(),
                      onChanged: (value) => typeBien = value,
                    ),
                    const SizedBox(height: 16),

                    // Loyer
                    TextFormField(
                      initialValue: loyer,
                      decoration: InputDecoration(
                        labelText: 'Loyer mensuel (FCFA) *',
                        prefixIcon: const Icon(Icons.payments_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty == true) return 'Champ requis';
                        if (double.tryParse(value!) == null)
                          return 'Nombre invalide';
                        return null;
                      },
                      onChanged: (value) => loyer = value,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      initialValue: description,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        prefixIcon: const Icon(Icons.description_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      maxLines: 2,
                      onChanged: (value) => description = value,
                    ),
                    const SizedBox(height: 24),

                    // Boutons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Annuler'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                Navigator.pop(context);
                                await _updateBien(
                                  bienId: bien.appwriteId!,
                                  nom: nom,
                                  adresse: adresse,
                                  type: typeBien!,
                                  loyer: double.parse(loyer),
                                  description: description,
                                  imagePath: imagePath,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryDark,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Enregistrer'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined,
            size: 40, color: Colors.grey.shade400),
        const SizedBox(height: 8),
        Text('Ajouter une photo',
            style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }

  Future<void> _updateBien({
    required String bienId,
    required String nom,
    required String adresse,
    required String type,
    required double loyer,
    String? description,
    String? imagePath,
  }) async {
    try {
      setState(() => _isLoading = true);

      final userId = await ref.read(currentUserIdProvider.future);
      if (userId == null) throw Exception('Utilisateur non connecté');

      final updatedBien = BienModel(
        appwriteId: bienId,
        proprietaireId: userId,
        nom: nom,
        adresse: adresse,
        type: type,
        description: description ?? '',
        loyerMensuel: loyer,
        statut: 'disponible',
        photosUrls: imagePath != null ? [imagePath] : null,
        updatedAt: DateTime.now(),
      );

      final bienRepository = ref.read(bienRepositoryProvider);
      await bienRepository.updateBien(bienId, updatedBien);
      ref.invalidate(proprietaireBiensProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bien modifié avec succès'),
            backgroundColor: Colors.green,
          ),
        );
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openAddBienModal() {
    final formKey = GlobalKey<FormState>();
    String nom = '';
    String adresse = '';
    String? typeBien;
    String loyer = '';
    String? description;
    String? imagePath;
    final ImagePicker picker = ImagePicker();
    XFile? pickedImage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.add_home,
                              color: AppColors.primaryDark),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Ajouter un bien',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
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

                    // Image Picker
                    GestureDetector(
                      onTap: () async {
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 85,
                        );
                        if (image != null) {
                          setModalState(() {
                            pickedImage = image;
                            imagePath = image.path;
                          });
                        }
                      },
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: pickedImage == null
                            ? _buildImagePlaceholder()
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.file(
                                  File(pickedImage!.path),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Nom du bien
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Nom du bien *',
                        prefixIcon: const Icon(Icons.home_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) =>
                          value?.isEmpty == true ? 'Champ requis' : null,
                      onChanged: (value) => nom = value,
                    ),
                    const SizedBox(height: 16),

                    // Adresse
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Adresse *',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) =>
                          value?.isEmpty == true ? 'Champ requis' : null,
                      onChanged: (value) => adresse = value,
                    ),
                    const SizedBox(height: 16),

                    // Type de bien
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Type de bien *',
                        prefixIcon: const Icon(Icons.home_work_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      items: _typesBien
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(_getTypeDisplay(type)),
                              ))
                          .toList(),
                      onChanged: (value) => typeBien = value,
                      validator: (value) =>
                          value == null ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 16),

                    // Loyer
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Loyer mensuel (FCFA) *',
                        prefixIcon: const Icon(Icons.payments_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty == true) return 'Champ requis';
                        if (double.tryParse(value!) == null)
                          return 'Nombre invalide';
                        if (double.parse(value) <= 0) return 'Doit être > 0';
                        return null;
                      },
                      onChanged: (value) => loyer = value,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Description (optionnel)',
                        prefixIcon: const Icon(Icons.description_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      maxLines: 2,
                      onChanged: (value) => description = value,
                    ),
                    const SizedBox(height: 24),

                    // Boutons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Annuler'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                Navigator.pop(context);
                                await _createBien(
                                  nom: nom,
                                  adresse: adresse,
                                  type: typeBien!,
                                  loyer: double.parse(loyer),
                                  description: description,
                                  imagePath: imagePath,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryDark,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Enregistrer'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createBien({
    required String nom,
    required String adresse,
    required String type,
    required double loyer,
    String? description,
    String? imagePath,
  }) async {
    try {
      setState(() => _isLoading = true);

      final userId = await ref.read(currentUserIdProvider.future);
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      debugPrint('🏠 Création bien avec proprietaireId: $userId');

      final bien = BienModel(
        proprietaireId: userId,
        nom: nom,
        adresse: adresse,
        type: type,
        description: description ?? '',
        loyerMensuel: loyer,
        statut: 'disponible',
        photosUrls: imagePath != null ? [imagePath] : null,
        createdAt: DateTime.now(),
      );

      final bienRepository = ref.read(bienRepositoryProvider);
      await bienRepository.createBien(bien);

      // Rafraîchir la liste des biens
      ref.invalidate(proprietaireBiensProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bien ajouté avec succès'),
            backgroundColor: Colors.green,
          ),
        );
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildEmptyState() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.home_work_outlined,
                  size: 60,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Aucun bien enregistré',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Ajoutez votre premier bien pour commencer\nà gérer vos locations',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _openAddBienModal,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Ajouter un bien',
                    style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBienList(List<BienModel> biens) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mes Biens',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${biens.length} propriété${biens.length > 1 ? 's' : ''}',
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _openAddBienModal,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Ajouter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Liste des biens en grille
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: biens.length,
              itemBuilder: (context, index) {
                final bien = biens[index];
                return _buildBienCard(bien);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBienCard(BienModel bien) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BienDetailScreen(bien: bien),
          ),
        ).then((_) {
          ref.invalidate(proprietaireBiensProvider);
        });
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image en haut (prend tout l'espace restant)
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  bien.photosUrls != null && bien.photosUrls!.isNotEmpty
                      ? Image.file(
                          File(bien.photosUrls!.first),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.primaryDark.withOpacity(0.1),
                            child: Icon(
                              Icons.home,
                              size: 50,
                              color: AppColors.primaryDark.withOpacity(0.5),
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.primaryDark.withOpacity(0.1),
                          child: Icon(
                            Icons.home,
                            size: 50,
                            color: AppColors.primaryDark.withOpacity(0.5),
                          ),
                        ),
                  // Badge type
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getTypeDisplay(bien.type ?? 'autre'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  // Menu
                  Positioned(
                    top: 4,
                    right: 4,
                    child: PopupMenuButton<String>(
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.more_vert,
                            color: Colors.white, size: 18),
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            _modifierBien(bien);
                            break;
                          case 'invite':
                            _inviterLocataire(bien);
                            break;
                          case 'delete':
                            _supprimerBien(bien);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 20),
                              SizedBox(width: 8),
                              Text('Modifier'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'invite',
                          child: Row(
                            children: [
                              Icon(Icons.person_add_outlined, size: 20),
                              SizedBox(width: 8),
                              Text('Inviter locataire'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline,
                                  size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Supprimer',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Infos en bas
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nom
                  Text(
                    bien.nom,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Localisation
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 11, color: Colors.grey.shade600),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          bien.adresse,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Montant
                  Text(
                    _formatMontant(bien.loyerMensuel),
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(String error) {
    if (_isConnectionError(error)) {
      // Naviguer vers la page NoConnectionPage
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const NoConnectionPage()),
        );
      });
      return const SizedBox.shrink();
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Erreur',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(proprietaireBiensProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  bool _isConnectionError(Object? error) {
    final msg = error.toString().toLowerCase();
    return msg.contains('socket') ||
        msg.contains('network') ||
        msg.contains('connection') ||
        msg.contains('internet');
  }

  @override
  Widget build(BuildContext context) {
    final biensAsync = ref.watch(proprietaireBiensProvider);

    return Scaffold(
      body: Stack(
        children: [
          biensAsync.when(
            data: (biens) {
              if (biens.isEmpty) {
                return _buildEmptyState();
              }
              return _buildBienList(biens);
            },
            loading: () => _buildLoadingState(),
            error: (error, _) => _buildErrorState(error.toString()),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
