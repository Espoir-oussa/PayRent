// Fichier : lib/domain/repositories/plainte_repository.dart

import '../../data/models/plainte_model.dart';

abstract class PlainteRepository {
  /// Récupérer toutes les plaintes d'un propriétaire
  Future<List<PlainteModel>> getPlaintesByProprietaire(String proprietaireId);

  /// Récupérer toutes les plaintes d'un locataire
  Future<List<PlainteModel>> getPlaintesByLocataire(String locataireId);

  /// Récupérer les plaintes d'un bien
  Future<List<PlainteModel>> getPlaintesByBien(String bienId);

  /// Récupérer une plainte par son ID
  Future<PlainteModel> getPlainteById(String plainteId);

  /// Créer une nouvelle plainte
  Future<PlainteModel> createPlainte(PlainteModel plainte);

  /// Mettre à jour le statut d'une plainte
  Future<PlainteModel> updatePlainteStatut(String plainteId, String newStatus);

  /// Répondre à une plainte
  Future<PlainteModel> repondrePlainte(String plainteId, String reponse);

  /// Récupérer les plaintes par statut
  Future<List<PlainteModel>> getPlaintesByStatut(String statut);

  // === Méthodes legacy pour compatibilité ===
  
  /// Récupérer toutes les plaintes d'un propriétaire (legacy)
  Future<List<PlainteModel>> getOwnerComplaints(int ownerId);

  /// Mettre à jour le statut d'une plainte (legacy)
  Future<void> updateComplaintStatus({
    required int plainteId, 
    required String newStatus,
  });

  /// Créer une plainte (legacy)
  Future<PlainteModel> createComplaint({
    required int locataireId,
    required String sujet,
    required String description,
    required int bienId,
  });
}