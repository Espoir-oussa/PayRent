
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Simuler les données utilisateur
  String nom = 'Dupont';
  String prenom = 'Jean';
  String telephone = '+33 6 12 34 56 78';

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Center(
                child: CircleAvatar(
                  radius: 40,
                  child: Icon(Icons.person, size: 60),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                initialValue: nom,
                decoration: const InputDecoration(labelText: 'Nom'),
                onChanged: (value) => nom = value,
                validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: prenom,
                decoration: const InputDecoration(labelText: 'Prénom'),
                onChanged: (value) => prenom = value,
                validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: telephone,
                decoration: const InputDecoration(labelText: 'Téléphone'),
                keyboardType: TextInputType.phone,
                onChanged: (value) => telephone = value,
                validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // TODO: Sauvegarder les modifications
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Modifications enregistrées')),
                          );
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Enregistrer'),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Center(
                child: TextButton.icon(
                  onPressed: () => _showDeleteAccountDialog(context),
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  label: const Text('Supprimer le compte', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: const Text('Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implémenter la suppression réelle du compte
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Compte supprimé (simulation)')),
              );
              // Rediriger vers la page de connexion ou d'accueil
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
