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
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../config/colors.dart';

class BienManagementScreen extends StatefulWidget {
  const BienManagementScreen({super.key});

  @override
  State<BienManagementScreen> createState() => _BienManagementScreenState();
}

class _BienManagementScreenState extends State<BienManagementScreen> {
  final List<Map<String, dynamic>> _biens = [];

  final List<String> _typesBien = [
    'Appartement',
    'Maison',
    'Studio',
    'Villa',
    'Duplex',
    'Local commercial',
    'Bureau',
    'Terrain',
  ];

  // TODO: Fonction pour modifier un bien
  void _modifierBien(Map<String, dynamic> bien, int index) {
    print('Modifier le bien: $index');
    // TODO: Implémenter la logique de modification
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modification'),
        content: const Text('Fonctionnalité de modification à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // TODO: Fonction pour gérer les locataires
  void _gererLocataires(Map<String, dynamic> bien) {
    print('Gérer les locataires du bien');
    // TODO: Implémenter la gestion des locataires
  }

  // TODO: Fonction pour voir les paiements
  void _voirPaiements(Map<String, dynamic> bien) {
    print('Voir les paiements du bien');
    // TODO: Implémenter la vue des paiements
  }

  void _openAddBienModal() {
    final _formKey = GlobalKey<FormState>();
    String adresse = '';
    String? typeBien;
    String loyer = '';
    String charges = '';
    String? imagePath;
    final ImagePicker _picker = ImagePicker();
    XFile? pickedImage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
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
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Ajouter un bien',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Image Picker
                    GestureDetector(
                      onTap: () async {
                        final XFile? image = await _picker.pickImage(
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
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: pickedImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.photo_camera_outlined,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Ajouter une photo',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Cliquez pour sélectionner',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              )
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
                    if (pickedImage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: TextButton(
                          onPressed: () async {
                            final XFile? image = await _picker.pickImage(
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
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_outlined, size: 16),
                              SizedBox(width: 6),
                              Text('Changer la photo'),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Form Fields
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Adresse complète',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      maxLines: 2,
                      validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
                      onChanged: (value) => adresse = value,
                    ),
                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Type de bien',
                        prefixIcon: const Icon(Icons.home_work_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      items: _typesBien.map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      )).toList(),
                      onChanged: (value) => typeBien = value,
                      validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Loyer de base',
                              prefixIcon: const Icon(Icons.euro_outlined),
                              suffixText: '€',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Champ requis';
                              if (double.tryParse(value) == null) return 'Nombre invalide';
                              if (double.parse(value) <= 0) return 'Doit être supérieur à 0';
                              return null;
                            },
                            onChanged: (value) => loyer = value,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Charges',
                              prefixIcon: const Icon(Icons.bolt_outlined),
                              suffixText: '€',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            keyboardType: TextInputType.number,
                            initialValue: '0',
                            validator: (value) {
                              if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                                return 'Nombre invalide';
                              }
                              return null;
                            },
                            onChanged: (value) => charges = value,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            child: const Text('Annuler'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                if (imagePath == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Veuillez sélectionner une photo'),
                                      backgroundColor: AppColors.accentRed,
                                    ),
                                  );
                                  return;
                                }
                                setState(() {
                                  _biens.add({
                                    'adresse': adresse,
                                    'type': typeBien,
                                    'loyer': double.tryParse(loyer) ?? 0.0,
                                    'charges': double.tryParse(charges) ?? 0.0,
                                    'image': imagePath,
                                    'dateAjout': DateTime.now(),
                                    'locataires': [], // Liste des locataires
                                  });
                                });
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Bien ajouté avec succès'),
                                    backgroundColor: Colors.green,
                                  ),
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
                'Ajoutez votre premier bien pour commencer\ngérer vos locations',
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
                label: const Text('Ajouter un bien', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
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

  Widget _buildBienList() {
    return SafeArea(
      child: Column(
        children: [
          // Header simple
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
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_biens.length} propriété${_biens.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Barre de recherche
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Rechercher un bien...',
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Colors.grey.shade500),
                        suffixIcon: Icon(Icons.filter_list, color: Colors.grey.shade500),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Liste des biens - NOUVELLE VERSION AMÉLIORÉE
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: _biens.length,
              itemBuilder: (context, index) {
                final bien = _biens[index];
                final locatairesCount = (bien['locataires'] as List?)?.length ?? 0;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Image en haut
                          Container(
                            height: 160,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(File(bien['image'] ?? '')),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Overlay sombre pour meilleure lisibilité
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.6),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                // Badge numéro
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '#${index + 1}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                  ),
                                ),
                                // Type de bien en bas de l'image
                                Positioned(
                                  bottom: 12,
                                  left: 12,
                                  child: Text(
                                    bien['type'] ?? 'Bien',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Contenu sous l'image
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Adresse
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        bien['adresse'] ?? '',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                          height: 1.4,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Informations statistiques
                                Row(
                                  children: [
                                    // Locataires
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            '$locatairesCount',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primaryDark,
                                            ),
                                          ),
                                          Text(
                                            'Locataire${locatairesCount > 1 ? 's' : ''}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Date d'ajout
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.calendar_today_outlined,
                                            size: 20,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatDate(bien['dateAjout']),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Statut
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Icon(
                                            locatairesCount > 0 
                                              ? Icons.check_circle 
                                              : Icons.hourglass_empty,
                                            size: 20,
                                            color: locatairesCount > 0 
                                              ? Colors.green 
                                              : Colors.orange,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            locatairesCount > 0 ? 'Occupé' : 'Libre',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: locatairesCount > 0 
                                                ? Colors.green 
                                                : Colors.orange,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Boutons d'action horizontaux
                                Row(
                                  children: [
                                    // Bouton Inviter
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _inviterLocataire(bien),
                                        icon: const Icon(Icons.person_add_outlined, size: 16),
                                        label: const Text('Inviter'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primaryDark,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Bouton Options
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: PopupMenuButton<String>(
                                        padding: EdgeInsets.zero,
                                        icon: Icon(
                                          Icons.more_vert,
                                          color: Colors.grey.shade600,
                                        ),
                                        onSelected: (value) {
                                          _handleOptionSelection(value, bien, index);
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'modifier',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
                                                SizedBox(width: 8),
                                                Text('Modifier'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'locataires',
                                            child: Row(
                                              children: [
                                                Icon(Icons.people_outlined, size: 18, color: Colors.green),
                                                SizedBox(width: 8),
                                                Text('Locataires'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'paiements',
                                            child: Row(
                                              children: [
                                                Icon(Icons.payments_outlined, size: 18, color: Colors.orange),
                                                SizedBox(width: 8),
                                                Text('Paiements'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuDivider(),
                                          const PopupMenuItem(
                                            value: 'supprimer',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                                SizedBox(width: 8),
                                                Text('Supprimer'),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleOptionSelection(String value, Map<String, dynamic> bien, int index) {
    switch (value) {
      case 'modifier':
        _modifierBien(bien, index);
        break;
      case 'locataires':
        _gererLocataires(bien);
        break;
      case 'paiements':
        _voirPaiements(bien);
        break;
      case 'supprimer':
        _showDeleteConfirmation(bien);
        break;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '--/--/----';
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return "Aujourd'hui";
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _inviterLocataire(Map<String, dynamic> bien) {
    final TextEditingController emailController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) => Padding(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Inviter un locataire',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Pour le bien : ${bien['type']}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email du locataire',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    hintText: 'exemple@email.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Champ requis';
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                      return 'Email invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Message personnalisé (optionnel)',
                    prefixIcon: const Icon(Icons.message_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    hintText: 'Bonjour, je vous invite à rejoindre PayRent...',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (emailController.text.isNotEmpty) {
                            setState(() {
                              bien['locataires'] = [...(bien['locataires'] as List? ?? []), {
                                'email': emailController.text,
                                'dateInvitation': DateTime.now(),
                                'statut': 'en attente',
                              }];
                            });
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Invitation envoyée à ${emailController.text}'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Envoyer'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> bien) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le bien'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce bien ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _biens.remove(bien);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bien supprimé avec succès'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Pas d'AppBar ici
      body: _biens.isEmpty
          ? _buildEmptyState()
          : _buildBienList(),
      // Pas de FloatingActionButton ici
    );
  }
}