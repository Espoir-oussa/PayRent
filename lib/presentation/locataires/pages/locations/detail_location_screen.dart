// ===============================
// 📍 Écran : Détails d'une Location
// ===============================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/colors.dart';
import '../../../../data/models/contrat_location_model.dart';
import '../../../../data/models/bien_model.dart';

class DetailLocationScreen extends ConsumerWidget {
  final ContratLocationModel contrat;
  final BienModel bien;

  const DetailLocationScreen({
    super.key,
    required this.contrat,
    required this.bien,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du Logement'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Adresse et informations principales
            _buildMainInfoCard(context),
            const SizedBox(height: 24),

            // Informations du contrat
            _buildContractInfoSection(context),
            const SizedBox(height: 24),

            // Description du bien
            _buildDescriptionSection(context),
            const SizedBox(height: 24),

            // Caractéristiques
            _buildFeaturesSection(context),
            const SizedBox(height: 32),

            // Boutons d'action
            _buildActionButtons(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMainInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryDark.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.primaryDark),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  bien.adresse,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoPill('Loyer',
                  '${contrat.montantTotalMensuel.toStringAsFixed(0)} €/mois'),
              _buildInfoPill(
                  'Statut', _getStatusLabel(contrat.statut ?? 'actif')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPill(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildContractInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations du Contrat',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        _buildInfoRow('Début du contrat',
            '${contrat.dateDebut.day}/${contrat.dateDebut.month}/${contrat.dateDebut.year}'),
        _buildInfoRow(
            'Fin du contrat',
            contrat.dateFinPrevue != null
                ? '${contrat.dateFinPrevue!.day}/${contrat.dateFinPrevue!.month}/${contrat.dateFinPrevue!.year}'
                : 'Pas de date de fin'),
        _buildInfoRow('Montant mensuel',
            '${contrat.montantTotalMensuel.toStringAsFixed(2)} €'),
        _buildInfoRow(
            'Caution',
            bien.caution != null
                ? '${bien.caution!.toStringAsFixed(2)} €'
                : 'Non spécifiée'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          bien.description ?? 'Aucune description disponible',
          style: TextStyle(color: Colors.grey[700], height: 1.5),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Caractéristiques',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                  Icons.bed, 'Chambres', '${bien.nombreChambres ?? 0}'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFeatureCard(Icons.bathtub, 'Salles de bain',
                  '${bien.nombreSallesDeBain ?? 0}'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFeatureCard(Icons.square_foot, 'Surface',
                  '${bien.surface?.toStringAsFixed(0) ?? 'N/A'} m²'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryDark),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // Navigate to ComplaintCreationScreen
              Navigator.of(context).pushNamed(
                '/complaint-creation',
                arguments: {
                  'contratId': contrat.appwriteId,
                  'bienId': bien.appwriteId,
                  'bienAdresse': bien.adresse,
                },
              );
            },
            icon: const Icon(Icons.report_problem_outlined),
            label: const Text('Ajouter une Plainte'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // Navigate to RentPaymentScreen
              Navigator.of(context).pushNamed(
                '/rent-payment',
                arguments: {
                  'contratId': contrat.appwriteId,
                  'montantLoyer': contrat.montantTotalMensuel,
                  'bienAdresse': bien.adresse,
                },
              );
            },
            icon: const Icon(Icons.payment),
            label: const Text('Payer mon Loyer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  String _getStatusLabel(String statut) {
    switch (statut.toLowerCase()) {
      case 'actif':
        return '✅ Actif';
      case 'termine':
        return '✓ Terminé';
      case 'suspendu':
        return '⚠️ Suspendu';
      default:
        return statut;
    }
  }
}
