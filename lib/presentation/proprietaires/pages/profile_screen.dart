import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/appwrite_service.dart';
import '../../../config/colors.dart';
import '../../../config/environment.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _appwriteService = AppwriteService();
  final _imagePicker = ImagePicker();

  // Controllers pour les champs de formulaire
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _adresseController = TextEditingController();

  String _email = '';
  String _role = '';
  String? _userDocId;
  String? _photoUrl;
  String? _userId;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingImage = false;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() => _isLoading = true);

      // Récupérer l'utilisateur connecté
      final account = Account(_appwriteService.client);
      final user = await account.get();

      // Afficher l'email de l'utilisateur comme fallback
      _email = user.email;
      _userId = user.$id;

      // Récupérer les données du profil depuis la collection users
      try {
        final databases = Databases(_appwriteService.client);

        // D'abord essayer de récupérer par ID du document (= ID utilisateur)
        try {
          final doc = await databases.getDocument(
            databaseId: 'payrent_db',
            collectionId: 'users',
            documentId: user.$id,
          );

          _userDocId = doc.$id;
          setState(() {
            _nomController.text = doc.data['nom'] ?? '';
            _prenomController.text = doc.data['prenom'] ?? '';
            _telephoneController.text = doc.data['telephone'] ?? '';
            _adresseController.text = doc.data['adresse'] ?? '';
            _email = doc.data['email'] ?? user.email;
            _role = doc.data['role'] ?? 'proprietaire';
            _photoUrl = doc.data['photoUrl'];
          });
        } catch (docError) {
          // Si pas trouvé par ID, essayer par email
          debugPrint('Document non trouvé par ID, recherche par email...');
          final response = await databases.listDocuments(
            databaseId: 'payrent_db',
            collectionId: 'users',
            queries: [
              Query.equal('email', user.email),
            ],
          );

          if (response.documents.isNotEmpty) {
            final doc = response.documents.first;
            _userDocId = doc.$id;

            setState(() {
              _nomController.text = doc.data['nom'] ?? '';
              _prenomController.text = doc.data['prenom'] ?? '';
              _telephoneController.text = doc.data['telephone'] ?? '';
              _adresseController.text = doc.data['adresse'] ?? '';
              _email = doc.data['email'] ?? user.email;
              _role = doc.data['role'] ?? 'proprietaire';
              _photoUrl = doc.data['photoUrl'];
            });
          } else {
            // Si pas de document user, utiliser les données de l'account
            final nameParts = user.name.split(' ');
            setState(() {
              if (nameParts.isNotEmpty)
                _prenomController.text = nameParts.first;
              if (nameParts.length > 1)
                _nomController.text = nameParts.sublist(1).join(' ');
              _role = 'proprietaire';
            });
          }
        }
      } catch (dbError) {
        // Erreur de base de données - afficher quand même les infos de compte
        debugPrint('Erreur DB profil: $dbError');
        final nameParts = user.name.split(' ');
        setState(() {
          if (nameParts.isNotEmpty) _prenomController.text = nameParts.first;
          if (nameParts.length > 1)
            _nomController.text = nameParts.sublist(1).join(' ');
          _role = 'proprietaire';
        });
      }
    } catch (e) {
      debugPrint('Erreur chargement profil: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_userDocId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de mettre à jour le profil'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() => _isSaving = true);

      final databases = Databases(_appwriteService.client);
      await databases.updateDocument(
        databaseId: 'payrent_db',
        collectionId: 'users',
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
          SnackBar(
            content: const Text('Profil mis à jour avec succès'),
            backgroundColor: Colors.green.shade600,
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
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // Méthode pour choisir et uploader une image de profil
  Future<void> _pickAndUploadImage() async {
    try {
      // Afficher le choix de source
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Choisir une photo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accentRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.camera_alt, color: AppColors.accentRed),
                  ),
                  title: const Text('Prendre une photo'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accentRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                        Icon(Icons.photo_library, color: AppColors.accentRed),
                  ),
                  title: const Text('Choisir depuis la galerie'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      );

      if (source == null) return;

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile == null) return;

      setState(() => _isUploadingImage = true);

      // Uploader l'image vers Appwrite Storage avec les permissions
      final storage = Storage(_appwriteService.client);
      final file = await storage.createFile(
        bucketId: Environment.imagesBucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(
          path: pickedFile.path,
          filename:
              'profile_${_userId ?? 'user'}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
        permissions: [
          Permission.read(Role.any()), // Lecture publique pour afficher l'image
          Permission.update(Role.user(_userId!)),
          Permission.delete(Role.user(_userId!)),
        ],
      );

      // Construire l'URL de l'image
      final imageUrl =
          '${Environment.appwritePublicEndpoint}/storage/buckets/${Environment.imagesBucketId}/files/${file.$id}/view?project=${Environment.appwriteProjectId}';

      // Mettre à jour le document utilisateur avec l'URL de la photo
      if (_userDocId != null) {
        final databases = Databases(_appwriteService.client);
        await databases.updateDocument(
          databaseId: 'payrent_db',
          collectionId: 'users',
          documentId: _userDocId!,
          data: {
            'photoUrl': imageUrl,
            'updatedAt': DateTime.now().toIso8601String(),
          },
        );

        setState(() {
          _photoUrl = imageUrl;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Photo de profil mise à jour'),
              backgroundColor: Colors.green.shade600,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Erreur upload image: $e');
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
        setState(() => _isUploadingImage = false);
      }
    }
  }

  // Widget pour afficher l'avatar avec possibilité de modification
  Widget _buildProfileAvatar() {
    return Stack(
      children: [
        GestureDetector(
          onTap: _isUploadingImage ? null : _pickAndUploadImage,
          child: CircleAvatar(
            radius: 55,
            backgroundColor: AppColors.accentRed.withOpacity(0.1),
            backgroundImage: _photoUrl != null && _photoUrl!.isNotEmpty
                ? NetworkImage(_photoUrl!)
                : null,
            child: _isUploadingImage
                ? const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : (_photoUrl == null || _photoUrl!.isEmpty)
                    ? Text(
                        _getInitials(),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentRed,
                        ),
                      )
                    : null,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _isUploadingImage ? null : _pickAndUploadImage,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accentRed,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        backgroundColor: AppColors.accentRed,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar et email
                    Center(
                      child: Column(
                        children: [
                          _buildProfileAvatar(),
                          const SizedBox(height: 12),
                          Text(
                            _email,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accentRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _role == 'proprietaire'
                                  ? 'Propriétaire'
                                  : 'Locataire',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.accentRed,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Champs de formulaire
                    _buildTextField(
                      controller: _nomController,
                      label: 'Nom',
                      icon: Icons.person_outline,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Le nom est requis'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _prenomController,
                      label: 'Prénom',
                      icon: Icons.person_outline,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Le prénom est requis'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _telephoneController,
                      label: 'Téléphone',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _adresseController,
                      label: 'Adresse',
                      icon: Icons.location_on_outlined,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 32),

                    // Bouton Enregistrer
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentRed,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                            _isSaving ? 'Enregistrement...' : 'Enregistrer'),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bouton Déconnexion
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _isLoggingOut ? null : _logout,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: _isLoggingOut
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.grey.shade700),
                                ),
                              )
                            : const Icon(Icons.logout_outlined),
                        label: Text(_isLoggingOut
                            ? 'Déconnexion...'
                            : 'Se déconnecter'),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Section danger
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
                            onPressed: () => _showDeleteAccountDialog(context),
                            icon: const Icon(Icons.delete_forever,
                                color: Colors.red),
                            label: const Text(
                              'Supprimer mon compte',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.accentRed),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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

  Future<void> _logout() async {
    try {
      setState(() => _isLoggingOut = true);

      await _appwriteService.logout();

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/login_owner', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la déconnexion: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  String _getInitials() {
    final nom = _nomController.text.trim();
    final prenom = _prenomController.text.trim();

    String initials = '';
    if (prenom.isNotEmpty) initials += prenom[0].toUpperCase();
    if (nom.isNotEmpty) initials += nom[0].toUpperCase();

    return initials.isEmpty ? '?' : initials;
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Supprimer le compte',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer votre compte ? '
          'Toutes vos données seront définitivement perdues. '
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteAccount();
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      if (_userId == null) {
        throw Exception('Utilisateur non identifié');
      }

      final databases = Databases(_appwriteService.client);

      // 1. Récupérer tous les biens du propriétaire pour supprimer les données liées
      List<String> bienIds = [];
      try {
        final biens = await databases.listDocuments(
          databaseId: Environment.databaseId,
          collectionId: Environment.biensCollectionId,
          queries: [Query.equal('proprietaireId', _userId!)],
        );
        bienIds = biens.documents.map((doc) => doc.$id).toList();
      } catch (e) {
        debugPrint('Erreur récupération biens: $e');
      }

      // 2. Supprimer tous les paiements liés aux biens
      for (final bienId in bienIds) {
        try {
          final paiements = await databases.listDocuments(
            databaseId: Environment.databaseId,
            collectionId: Environment.paiementsCollectionId,
            queries: [Query.equal('bienId', bienId)],
          );
          for (final doc in paiements.documents) {
            await databases.deleteDocument(
              databaseId: Environment.databaseId,
              collectionId: Environment.paiementsCollectionId,
              documentId: doc.$id,
            );
          }
        } catch (e) {
          debugPrint('Erreur suppression paiements: $e');
        }
      }

      // 3. Supprimer toutes les factures liées aux biens
      for (final bienId in bienIds) {
        try {
          final factures = await databases.listDocuments(
            databaseId: Environment.databaseId,
            collectionId: Environment.facturesCollectionId,
            queries: [Query.equal('bienId', bienId)],
          );
          for (final doc in factures.documents) {
            await databases.deleteDocument(
              databaseId: Environment.databaseId,
              collectionId: Environment.facturesCollectionId,
              documentId: doc.$id,
            );
          }
        } catch (e) {
          debugPrint('Erreur suppression factures: $e');
        }
      }

      // 4. Supprimer toutes les plaintes du propriétaire
      try {
        final plaintes = await databases.listDocuments(
          databaseId: Environment.databaseId,
          collectionId: Environment.plaintesCollectionId,
          queries: [Query.equal('proprietaireId', _userId!)],
        );
        for (final doc in plaintes.documents) {
          await databases.deleteDocument(
            databaseId: Environment.databaseId,
            collectionId: Environment.plaintesCollectionId,
            documentId: doc.$id,
          );
        }
      } catch (e) {
        debugPrint('Erreur suppression plaintes: $e');
      }

      // 5. Supprimer toutes les invitations du propriétaire
      try {
        final invitations = await databases.listDocuments(
          databaseId: Environment.databaseId,
          collectionId: Environment.invitationsCollectionId,
          queries: [Query.equal('proprietaireId', _userId!)],
        );
        for (final doc in invitations.documents) {
          await databases.deleteDocument(
            databaseId: Environment.databaseId,
            collectionId: Environment.invitationsCollectionId,
            documentId: doc.$id,
          );
        }
      } catch (e) {
        debugPrint('Erreur suppression invitations: $e');
      }

      // 6. Supprimer tous les contrats du propriétaire
      try {
        final contrats = await databases.listDocuments(
          databaseId: Environment.databaseId,
          collectionId: Environment.contratsCollectionId,
          queries: [Query.equal('proprietaireId', _userId!)],
        );
        for (final doc in contrats.documents) {
          await databases.deleteDocument(
            databaseId: Environment.databaseId,
            collectionId: Environment.contratsCollectionId,
            documentId: doc.$id,
          );
        }
      } catch (e) {
        debugPrint('Erreur suppression contrats: $e');
      }

      // 7. Supprimer tous les biens du propriétaire
      for (final bienId in bienIds) {
        try {
          await databases.deleteDocument(
            databaseId: Environment.databaseId,
            collectionId: Environment.biensCollectionId,
            documentId: bienId,
          );
        } catch (e) {
          debugPrint('Erreur suppression bien $bienId: $e');
        }
      }

      // 8. Supprimer le document utilisateur
      if (_userDocId != null) {
        await databases.deleteDocument(
          databaseId: Environment.databaseId,
          collectionId: Environment.usersCollectionId,
          documentId: _userDocId!,
        );
      }

      // 9. Supprimer/désactiver le compte Auth Appwrite
      try {
        await _appwriteService.deleteCurrentAccount();
      } catch (e) {
        debugPrint('Erreur désactivation compte Auth: $e');
        // Continuer même si ça échoue - on déconnecte quand même
      }

      // 10. Déconnecter l'utilisateur
      try {
        await _appwriteService.logout();
      } catch (e) {
        // Session peut déjà être invalide après deleteCurrentAccount
        debugPrint('Logout après suppression: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compte supprimé définitivement'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(
            context, '/login_owner', (route) => false);
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
