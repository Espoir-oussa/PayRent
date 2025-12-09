// Fichier : lib/core/services/mock_data_service.dart

import '../../domain/entities/bien_entity.dart';

/// Service pour fournir des données mockées (pour le développement)
/// À supprimer une fois le backend intégré
class MockDataService {
  /// Retourne une liste de biens fictifs pour tester
  static List<BienEntity> getMockBiens() {
    return [
      const BienEntity(
        idBien: 1,
        idProprietaire: 1,
        adresseComplete: '123 Rue de la Paix, 75000 Paris',
        loyerDeBase: 850.00,
        typeBien: 'Appartement',
        chargesLocatives: 150.00,
      ),
      const BienEntity(
        idBien: 2,
        idProprietaire: 1,
        adresseComplete: '456 Avenue des Champs, 75008 Paris',
        loyerDeBase: 1200.00,
        typeBien: 'Studio',
        chargesLocatives: 100.00,
      ),
      const BienEntity(
        idBien: 3,
        idProprietaire: 1,
        adresseComplete: '789 Boulevard Saint-Germain, 75005 Paris',
        loyerDeBase: 950.00,
        typeBien: 'T2',
        chargesLocatives: 120.00,
      ),
      const BienEntity(
        idBien: 4,
        idProprietaire: 1,
        adresseComplete: '321 Rue de Rivoli, 75001 Paris',
        loyerDeBase: 1100.00,
        typeBien: 'Duplex',
        chargesLocatives: 200.00,
      ),
    ];
  }
}
