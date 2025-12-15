// ===============================
// 🏠 Écran : Accueil Locataire
//
// Ce fichier définit l'interface utilisateur principale pour le locataire.
//
// Dossier : lib/presentation/locataires/pages/
// Rôle : Tableau de bord du locataire
// Utilisé par : Locataires
// ===============================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/appwrite.dart'; // <-- IMPORT AJOUTÉ
import '../../../config/colors.dart';
import '../../../config/theme.dart';
import '../widgets/tenant_scaffold.dart';
import '../../../core/di/providers.dart';
import '../../../core/services/appwrite_service.dart';
import '../../shared/pages/no_connection_page.dart';
import '../../shared/widgets/shared_profile_form.dart';
import 'package:image_picker/image_picker.dart';
import '../../../config/environment.dart';
// Ajoutez cet import
import '../../proprietaires/pages/profile_screen.dart';

class HomeTenantScreen extends ConsumerStatefulWidget {
  const HomeTenantScreen({super.key});

  @override
  ConsumerState<HomeTenantScreen> createState() => _HomeTenantScreenState();
}

class _HomeTenantScreenState extends ConsumerState<HomeTenantScreen> {
  bool _isConnectionError(Object? error) {
    final msg = error.toString().toLowerCase();
    return msg.contains('socket') ||
        msg.contains('network') ||
        msg.contains('connection') ||
        msg.contains('internet');
  }

  int _currentIndex = 0;
  String? _userName;
  bool _isLoading = true;
  // Profile fields
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _adresseController = TextEditingController();
  String _email = '';
  String? _photoUrl;
  String? _userDocId;
  final _imagePicker = ImagePicker();
  bool _isSaving = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final appwriteService = ref.read(appwriteServiceProvider);
      final user = await appwriteService.getCurrentUser();
      if (user != null && mounted) {
        setState(() {
          _userName = user.name;
          _isLoading = false;
        });
      }
      // Charger le profil depuis la collection users
      try {
        final databases = Databases(appwriteService.client);
        if (user != null) {
          try {
            final doc = await databases.getDocument(
              databaseId: Environment.databaseId,
              collectionId: Environment.usersCollectionId,
              documentId: user.$id,
            );
            _userDocId = doc.$id;
            if (mounted) {
              setState(() {
                _nomController.text = doc.data['nom'] ?? '';
                _prenomController.text = doc.data['prenom'] ?? '';
                _telephoneController.text = doc.data['telephone'] ?? '';
                _adresseController.text = doc.data['adresse'] ?? '';
                _email = doc.data['email'] ?? user.email;
                _photoUrl = doc.data['photoUrl'];
              });
            }
          } catch (e) {
            // essayer par email
            final resp = await databases.listDocuments(
              databaseId: Environment.databaseId,
              collectionId: Environment.usersCollectionId,
              queries: [Query.equal('email', user.email)],
            );
            if (resp.documents.isNotEmpty) {
              final doc = resp.documents.first;
              _userDocId = doc.$id;
              if (mounted) {
                setState(() {
                  _nomController.text = doc.data['nom'] ?? '';
                  _prenomController.text = doc.data['prenom'] ?? '';
                  _telephoneController.text = doc.data['telephone'] ?? '';
                  _adresseController.text = doc.data['adresse'] ?? '';
                  _email = doc.data['email'] ?? user.email;
                  _photoUrl = doc.data['photoUrl'];
                });
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Erreur chargement profil: $e');
      }
    } catch (e) {
      if (_isConnectionError(e)) {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const NoConnectionPage()),
            );
          });
        }
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_userDocId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de mettre à jour le profil (profil non trouvé)'),
        ),
      );
      return;
    }

    try {
      setState(() => _isSaving = true);
      final appwriteService = ref.read(appwriteServiceProvider);
      final databases = Databases(appwriteService.client);
      await databases.updateDocument(
        databaseId: Environment.databaseId,
        collectionId: Environment.usersCollectionId,
        documentId: _userDocId!,
        data: {
          'nom': _nomController.text.trim(),
          'prenom': _prenomController.text.trim(),
          'telephone': _telephoneController.text.trim(),
          'adresse': _adresseController.text.trim(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (_) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Prendre une photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerie'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );
      if (source == null) return;

      final picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (picked == null) return;

      setState(() => _isUploadingImage = true);
      final appwriteService = ref.read(appwriteServiceProvider);
      final storage = Storage(appwriteService.client);
      final file = await storage.createFile(
        bucketId: Environment.imagesBucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(
          path: picked.path,
          filename: 'profile_${_userDocId ?? _email}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
        permissions: [Permission.read(Role.any())],
      );
      final imageUrl = '${Environment.appwritePublicEndpoint}/storage/buckets/${Environment.imagesBucketId}/files/${file.$id}/view?project=${Environment.appwriteProjectId}';
      if (_userDocId != null) {
        final databases = Databases(appwriteService.client);
        await databases.updateDocument(
          databaseId: Environment.databaseId,
          collectionId: Environment.usersCollectionId,
          documentId: _userDocId!,
          data: {
            'photoUrl': imageUrl,
            'updatedAt': DateTime.now().toIso8601String(),
          },
        );
        if (mounted) setState(() => _photoUrl = imageUrl);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur upload: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
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
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final appwriteService = ref.read(appwriteServiceProvider);
        await appwriteService.logout();
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login_owner',
            (route) => false,
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
      }
    }
  }

  void _handleNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifications - À implémenter'),
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  String _userInitials() {
    if (_userName == null || _userName!.trim().isEmpty) return '';
    final parts = _userName!.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return TenantScaffold(
      currentIndex: _currentIndex,
      onIndexChanged: (index) => setState(() => _currentIndex = index),
      body: _buildBody(),
      onNotificationsPressed: _handleNotifications,
      onProfilePressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileScreen(),
          ),
        );
      },
      onLogoutPressed: _logout,
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildPaymentsTab();
      case 2:
        return _buildComplaintsTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de bienvenue
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryDark,
                  AppColors.primaryDark.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage: _photoUrl != null ? NetworkImage(_photoUrl!) : null,
                  child: _photoUrl == null
                      ? (_userInitials().isNotEmpty
                          ? Text(
                              _userInitials(),
                              style: TextStyle(
                                color: AppColors.primaryDark,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 35,
                              color: AppColors.primaryDark,
                            ))
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenue,',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _userName ?? 'Locataire',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Carte du logement actuel
          Text(
            'Mon logement',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.home, color: AppColors.primaryDark),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chargement...',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Informations du logement',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Actions rapides
          Text(
            'Actions rapides',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  icon: Icons.payment,
                  label: 'Payer\nle loyer',
                  color: Colors.green,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAction(
                  icon: Icons.report_problem,
                  label: 'Signaler\nun problème',
                  color: Colors.orange,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAction(
                  icon: Icons.receipt_long,
                  label: 'Mes\nquittances',
                  color: Colors.blue,
                  onTap: () {
                    // TODO: Voir les quittances
                    _handleNotifications();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.payment, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Historique des paiements',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Vos paiements apparaîtront ici',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.report_problem, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Mes plaintes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Vos signalements apparaîtront ici',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SharedProfileForm(
      nomController: _nomController,
      prenomController: _prenomController,
      telephoneController: _telephoneController,
      adresseController: _adresseController,
      email: _email,
      photoUrl: _photoUrl, // ENLEVÉ: role: _role,
      isEditable: true,
      isLoading: _isLoading,
      isSaving: _isSaving,
      isUploadingImage: _isUploadingImage,
      isLoggingOut: false,
      onPickImage: _pickAndUploadImage,
      onSave: _saveProfile,
      onLogout: _logout,
      onDelete: null,
    );
  }
}