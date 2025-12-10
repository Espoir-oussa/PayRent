// ===============================
// 🏠 Écran : Détails d'un Bien
//
// Ce fichier affiche les détails complets d'un bien immobilier
// avec la liste des locataires associés.
//
// Dossier : lib/presentation/proprietaires/pages/
// Rôle : UI pour afficher les détails d'un bien
// Utilisé par : Propriétaires
// ===============================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../config/colors.dart';
import '../../../data/models/bien_model.dart';
import '../../../data/models/invitation_model.dart';
import '../../../core/di/providers.dart';

class BienDetailScreen extends ConsumerStatefulWidget {
  final BienModel bien;

  const BienDetailScreen({super.key, required this.bien});

  @override
  ConsumerState<BienDetailScreen> createState() => _BienDetailScreenState();
}

class _BienDetailScreenState extends ConsumerState<BienDetailScreen> {
  bool _isLoading = false;

  // Liste fictive de locataires pour la démo
  // TODO: Remplacer par les vrais locataires depuis Appwrite
  List<Map<String, dynamic>> _locataires = [];

  @override
  void initState() {
    super.initState();
    _loadLocataires();
  }

  Future<void> _loadLocataires() async {
    // TODO: Charger les locataires depuis Appwrite via les contrats
    // Pour l'instant, on simule des données
    setState(() {
      _locataires = [
        // Exemple de locataires (vide par défaut)
      ];
    });
  }

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

  Future<void> _retirerLocataire(Map<String, dynamic> locataire) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Retirer le locataire'),
        content: Text(
          'Voulez-vous vraiment retirer ${locataire['nom']} de ce bien ?',
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
            child: const Text('Retirer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        setState(() => _isLoading = true);
        // TODO: Implémenter la suppression du locataire dans Appwrite
        setState(() {
          _locataires.removeWhere((l) => l['id'] == locataire['id']);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${locataire['nom']} a été retiré'),
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

  void _inviterLocataire() {
    final emailController = TextEditingController();
    final nomController = TextEditingController();
    final prenomController = TextEditingController();
    final telephoneController = TextEditingController();
    final messageController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

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
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
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
                        child: Icon(Icons.person_add, color: AppColors.primaryDark),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Inviter un locataire',
                              style:
                                  Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                            ),
                            Text(
                              widget.bien.nom,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Email (requis)
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email du locataire *',
                      hintText: 'exemple@email.com',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Email invalide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Nom et Prénom (optionnels)
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: prenomController,
                          decoration: InputDecoration(
                            labelText: 'Prénom',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: nomController,
                          decoration: InputDecoration(
                            labelText: 'Nom',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Téléphone (optionnel)
                  TextFormField(
                    controller: telephoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Téléphone',
                      hintText: '+229 XX XX XX XX',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Message personnalisé (optionnel)
                  TextFormField(
                    controller: messageController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Message personnalisé',
                      hintText: 'Bienvenue dans votre nouveau logement...',
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 50),
                        child: Icon(Icons.message_outlined),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Info loyer
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Loyer: ${_formatMontant(widget.bien.loyerMensuel)}${widget.bien.charges != null ? ' + ${_formatMontant(widget.bien.charges!)} de charges' : ''}',
                            style: TextStyle(color: Colors.blue.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (formKey.currentState!.validate()) {
                              setModalState(() => isLoading = true);
                              
                              try {
                                final invitationService = ref.read(invitationServiceProvider);
                                final invitation = await invitationService.createInvitation(
                                  bien: widget.bien,
                                  emailLocataire: emailController.text.trim(),
                                  nomLocataire: nomController.text.trim().isNotEmpty 
                                      ? nomController.text.trim() 
                                      : null,
                                  prenomLocataire: prenomController.text.trim().isNotEmpty 
                                      ? prenomController.text.trim() 
                                      : null,
                                  telephoneLocataire: telephoneController.text.trim().isNotEmpty 
                                      ? telephoneController.text.trim() 
                                      : null,
                                  message: messageController.text.trim().isNotEmpty 
                                      ? messageController.text.trim() 
                                      : null,
                                );
                                
                                if (mounted) {
                                  Navigator.pop(context);
                                  _showInvitationSuccessDialog(invitation);
                                }
                              } catch (e) {
                                setModalState(() => isLoading = false);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Erreur: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(isLoading ? 'Envoi en cours...' : 'Envoyer l\'invitation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Affiche un dialogue de succès avec le lien d'invitation
  void _showInvitationSuccessDialog(InvitationModel invitation) {
    final invitationLink = 'payrent://accept-invitation?token=${invitation.token}';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: Colors.green.shade700),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('Invitation envoyée !')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                children: [
                  const TextSpan(text: 'Un email a été envoyé à '),
                  TextSpan(
                    text: invitation.emailLocataire,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' avec les boutons '),
                  const TextSpan(
                    text: 'Accepter',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' et '),
                  const TextSpan(
                    text: 'Refuser',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.email_outlined, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Le locataire peut accepter ou refuser directement depuis son email.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Lien d\'invitation (backup):',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      invitationLink,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: invitationLink));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lien copié !'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    tooltip: 'Copier le lien',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'L\'invitation expire le ${invitation.dateExpiration.day}/${invitation.dateExpiration.month}/${invitation.dateExpiration.year}.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: invitationLink));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Lien copié dans le presse-papiers !'),
                  duration: Duration(seconds: 2),
                ),
              );
              Navigator.pop(context);
            },
            icon: const Icon(Icons.share),
            label: const Text('Partager'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bien = widget.bien;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // AppBar avec image
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: AppColors.primaryDark,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      bien.photosUrls != null && bien.photosUrls!.isNotEmpty
                          ? Image.file(
                              File(bien.photosUrls!.first),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.primaryDark.withOpacity(0.3),
                                child: const Icon(
                                  Icons.home,
                                  size: 80,
                                  color: Colors.white54,
                                ),
                              ),
                            )
                          : Container(
                              color: AppColors.primaryDark.withOpacity(0.3),
                              child: const Icon(
                                Icons.home,
                                size: 80,
                                color: Colors.white54,
                              ),
                            ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      // Infos en bas
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryDark,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getTypeDisplay(bien.type ?? 'autre'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              bien.nom,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    bien.adresse,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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

              // Contenu
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Loyer
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Loyer mensuel',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'par mois',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _formatMontant(bien.loyerMensuel),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Description
                    if (bien.description != null &&
                        bien.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              bien.description!,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),

                    // Caractéristiques
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Caractéristiques',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              if (bien.surface != null)
                                _buildCaracteristique(
                                  Icons.square_foot,
                                  '${bien.surface!.toStringAsFixed(0)} m²',
                                ),
                              if (bien.nombrePieces != null)
                                _buildCaracteristique(
                                  Icons.meeting_room,
                                  '${bien.nombrePieces} pièces',
                                ),
                              if (bien.nombreChambres != null)
                                _buildCaracteristique(
                                  Icons.bed,
                                  '${bien.nombreChambres} chambres',
                                ),
                              if (bien.nombreSallesDeBain != null)
                                _buildCaracteristique(
                                  Icons.bathroom,
                                  '${bien.nombreSallesDeBain} SDB',
                                ),
                              _buildCaracteristique(
                                Icons.home_work,
                                _getTypeDisplay(bien.type ?? 'autre'),
                              ),
                              _buildCaracteristique(
                                bien.statut == 'disponible'
                                    ? Icons.check_circle
                                    : Icons.person,
                                bien.statut == 'disponible'
                                    ? 'Disponible'
                                    : 'Occupé',
                                color: bien.statut == 'disponible'
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section Locataires
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Locataires',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          TextButton.icon(
                            onPressed: _inviterLocataire,
                            icon: const Icon(Icons.person_add, size: 18),
                            label: const Text('Inviter'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Liste des locataires
                    if (_locataires.isEmpty)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.person_off_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Aucun locataire',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Invitez un locataire pour ce bien',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _inviterLocataire,
                              icon: const Icon(Icons.person_add, size: 18),
                              label: const Text('Inviter un locataire'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryDark,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _locataires.length,
                        itemBuilder: (context, index) {
                          final locataire = _locataires[index];
                          return _buildLocataireCard(locataire);
                        },
                      ),

                    const SizedBox(height: 100), // Espace pour le FAB
                  ],
                ),
              ),
            ],
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildCaracteristique(IconData icon, String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (color ?? AppColors.primaryDark).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color ?? AppColors.primaryDark),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color ?? AppColors.primaryDark,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocataireCard(Map<String, dynamic> locataire) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryDark.withOpacity(0.1),
          child: Text(
            (locataire['nom'] as String).substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          locataire['nom'],
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(locataire['email'] ?? ''),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
          onPressed: () => _retirerLocataire(locataire),
          tooltip: 'Retirer',
        ),
      ),
    );
  }
}
