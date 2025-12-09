// Fichier : lib/domain/repositories/plainte_repository.dart

import '../../data/models/plainte_model.dart'; // Assurez-vous d'importer votre modèle

abstract class PlainteRepository {
  // Récupérer toutes les plaintes d'un propriétaire
  Future<List<PlainteModel>> getOwnerComplaints(int ownerId);

  // Mettre à jour le statut d'une plainte (BF18)
  // Prend l'ID de la plainte et le nouveau statut
  Future<void> updateComplaintStatus({
    required int plainteId, 
    required String newStatus,
  });

  // Pour la phase 2 : création d'une plainte par le locataire
  Future<PlainteModel> createComplaint({
    required int locataireId,
    required String sujet,
    required String description,
    required int bienId,
  });
}