// Fichier : lib/domain/entities/bien_entity.dart

class BienEntity {
  final int idBien;
  final int idProprietaire;
  final String adresse;
  final double loyer;
  final String description;
  final int nombreChambres;
  final int nombreSallesBain;
  final String statutBien; // Ex: 'Loué', 'Vacant', 'En Maintenance'

  const BienEntity({
    required this.idBien,
    required this.idProprietaire,
    required this.adresse,
    required this.loyer,
    required this.description,
    required this.nombreChambres,
    required this.nombreSallesBain,
    required this.statutBien,
  });
}