// Fichier : lib/data/repositories/bien_repository_impl.dart

import '../../core/services/api_service.dart';
import '../../core/services/mock_data_service.dart';
import '../../data/models/bien_model.dart';
import '../../domain/entities/bien_entity.dart';
import '../../domain/repositories/bien_repository.dart';

/// Implémentation concrète du repository pour les biens
///
/// Responsabilité : Récupérer les données depuis l'API et les convertir en entités
/// Pattern : Cette classe implémente l'interface BienRepository
/// Utilisée par : Injection de dépendances (Riverpod)
class BienRepositoryImpl implements BienRepository {
  final ApiService apiService;

  BienRepositoryImpl(this.apiService);

  @override
  Future<List<BienEntity>> getBiensByProprietaire(int idProprietaire) async {
    try {
      // DÉVELOPPEMENT : Utiliser les données mockées
      await Future.delayed(
          const Duration(milliseconds: 800)); // Simuler un délai réseau
      return MockDataService.getMockBiens();

      // PRODUCTION : Décommenter l'appel API réel
      /*
      final response = await apiService.get('biens/proprietaire/$idProprietaire');
      
      // Conversion des données reçues
      final biensList = (response as List)
          .map((bien) => BienModel.fromJson(bien as Map<String, dynamic>))
          .toList();
      
      return biensList;
      */
    } catch (e) {
      throw Exception('Erreur lors de la récupération des biens: $e');
    }
  }

  @override
  Future<BienEntity> getBienById(int idBien) async {
    try {
      final response = await apiService.get('biens/$idBien');
      final bienModel = BienModel.fromJson(response as Map<String, dynamic>);
      return bienModel;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du bien: $e');
    }
  }

  @override
  Future<BienEntity> createBien(BienEntity bien) async {
    try {
      final bienModel = BienModel(
        idBien: bien.idBien,
        idProprietaire: bien.idProprietaire,
        adresseComplete: bien.adresseComplete,
        loyerDeBase: bien.loyerDeBase,
        typeBien: bien.typeBien,
        chargesLocatives: bien.chargesLocatives,
      );

      final response = await apiService.post('biens', bienModel.toJson());
      return BienModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Erreur lors de la création du bien: $e');
    }
  }

  @override
  Future<BienEntity> updateBien(BienEntity bien) async {
    try {
      final bienModel = BienModel(
        idBien: bien.idBien,
        idProprietaire: bien.idProprietaire,
        adresseComplete: bien.adresseComplete,
        loyerDeBase: bien.loyerDeBase,
        typeBien: bien.typeBien,
        chargesLocatives: bien.chargesLocatives,
      );

      final response =
          await apiService.put('biens/${bien.idBien}', bienModel.toJson());
      return BienModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du bien: $e');
    }
  }

  @override
  Future<void> deleteBien(int idBien) async {
    try {
      await apiService.delete('biens/$idBien');
    } catch (e) {
      throw Exception('Erreur lors de la suppression du bien: $e');
    }
  }
}
