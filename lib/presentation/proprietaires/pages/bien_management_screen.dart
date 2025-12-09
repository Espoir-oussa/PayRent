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
import '../../../config/colors.dart';
import '../../../core/di/providers.dart';
import '../../../domain/entities/bien_entity.dart';
import '../widgets/bien_card.dart';
import '../../../presentation/proprietaires/widgets/empty_state_widget.dart';
import 'bien_screens/bien_list_state.dart';

class BienManagementScreen extends ConsumerStatefulWidget {
  const BienManagementScreen({super.key});

  @override
  ConsumerState<BienManagementScreen> createState() =>
      _BienManagementScreenState();
}

class _BienManagementScreenState extends ConsumerState<BienManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Initialiser le controller et charger les données
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBiens();
    });
  }

  void _loadBiens() {
    // TODO: Remplacer 1 par l'ID réel du propriétaire connecté
    // Pour l'instant, on simule avec l'ID 1
    ref.read(bienListControllerProvider.notifier).loadBiens(1);
  }

  @override
  Widget build(BuildContext context) {
    // Provider pour l'état du bien
    final bienListState = ref.watch(bienListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Biens'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _buildBody(bienListState),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Naviguer vers l'écran d'ajout de bien
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ajouter un bien - À implémenter')),
          );
        },
        backgroundColor: AppColors.accentRed,
        tooltip: 'Ajouter un bien',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BienListState state) {
    if (state.status == BienStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.status == BienStatus.failure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.accentRed,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              state.errorMessage ?? 'Une erreur est survenue',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadBiens,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (state.biens.isEmpty) {
      return const EmptyStateWidget(
        title: 'Aucun bien',
        message:
            'Vous n\'avez pas encore ajouté de bien immobilier. Appuyez sur le bouton + pour en ajouter un.',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadBiens();
        // Attendre que le chargement soit terminé
        await Future.delayed(const Duration(seconds: 2));
      },
      child: ListView.builder(
        itemCount: state.biens.length,
        padding: const EdgeInsets.only(bottom: 80), // Espace pour le FAB
        itemBuilder: (context, index) {
          final bien = state.biens[index];
          return BienCard(
            bien: bien,
            onTap: () => _showBienDetails(bien),
            onEditTap: () => _editBien(bien),
            onDeleteTap: () => _confirmDeleteBien(bien),
          );
        },
      ),
    );
  }

  void _showBienDetails(BienEntity bien) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Détails du bien',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Adresse', bien.adresseComplete),
              _buildDetailRow('Type', bien.typeBien ?? 'N/A'),
              _buildDetailRow('Loyer de base', '${bien.loyerDeBase} €'),
              _buildDetailRow('Charges', '${bien.chargesLocatives} €'),
              _buildDetailRow('Loyer total', '${bien.loyerTotal} €'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fermer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  void _editBien(BienEntity bien) {
    // TODO: Naviguer vers l'écran d'édition du bien
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Éditer le bien - À implémenter')),
    );
  }

  void _confirmDeleteBien(BienEntity bien) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le bien'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer ${bien.adresseComplete} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Appeler le Use Case de suppression
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Suppression - À implémenter')),
              );
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
