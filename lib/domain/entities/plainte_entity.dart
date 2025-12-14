// Fichier : lib/domain/entities/plainte_entity.dart

class PlainteEntity {
  final int idPlainte;
  final int idLocataire; 
  final int idBien; 
  final int idProprietaireGestionnaire;
  final DateTime dateCreation;
  final String sujet;
  final String description;
  final String statutPlainte; // 'Ouverte', 'Résolue', 'Fermée', etc.

  const PlainteEntity({
    required this.idPlainte,
    required this.idLocataire,
    required this.idBien,
    required this.idProprietaireGestionnaire,
    required this.dateCreation,
    required this.sujet,
    required this.description,
    required this.statutPlainte,
  });
}