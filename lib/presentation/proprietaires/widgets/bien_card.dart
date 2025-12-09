// Fichier : lib/presentation/proprietaires/widgets/bien_card.dart

import 'package:flutter/material.dart';
import '../../../config/colors.dart';
import '../../../domain/entities/bien_entity.dart';

/// Widget réutilisable : Carte d'affichage d'un bien
///
/// Affiche les informations principales d'un bien immobilier
/// Peut être utilisé dans une liste ou une grille
class BienCard extends StatelessWidget {
  final BienEntity bien;
  final VoidCallback? onTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onDeleteTap;

  const BienCard({
    super.key,
    required this.bien,
    this.onTap,
    this.onEditTap,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec adresse et type
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Adresse
                        Text(
                          bien.adresseComplete,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Type de bien
                        if (bien.typeBien != null)
                          Text(
                            bien.typeBien!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors.primaryDark.withOpacity(0.6),
                                ),
                          ),
                      ],
                    ),
                  ),
                  // Icône
                  Icon(
                    Icons.apartment,
                    color: AppColors.accentRed,
                    size: 32,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Divider
              Divider(
                color: AppColors.primaryDark.withOpacity(0.1),
                height: 1,
              ),
              const SizedBox(height: 12),

              // Informations de loyer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Loyer de base
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Loyer de base',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${bien.loyerDeBase.toStringAsFixed(2)} €',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentRed,
                            ),
                      ),
                    ],
                  ),
                  // Charges locatives
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Charges',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${bien.chargesLocatives.toStringAsFixed(2)} €',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  // Loyer total
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${bien.loyerTotal.toStringAsFixed(2)} €',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Actions (Modifier, Supprimer)
              if (onEditTap != null || onDeleteTap != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEditTap != null)
                      TextButton.icon(
                        onPressed: onEditTap,
                        icon: const Icon(Icons.edit),
                        label: const Text('Modifier'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.accentRed,
                        ),
                      ),
                    const SizedBox(width: 8),
                    if (onDeleteTap != null)
                      TextButton.icon(
                        onPressed: onDeleteTap,
                        icon: const Icon(Icons.delete),
                        label: const Text('Supprimer'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
