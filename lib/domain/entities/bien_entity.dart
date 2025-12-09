// Fichier : lib/domain/entities/bien_entity.dart

class BienEntity {
  final int idBien;
  final int idProprietaire;
  final String adresseComplete;
  final String? typeBien;
  final double loyerDeBase;
  final double chargesLocatives;

  const BienEntity({
    required this.idBien,
    required this.idProprietaire,
    required this.adresseComplete,
    required this.loyerDeBase,
    this.typeBien,
    this.chargesLocatives = 0.0,
  });

  // Getter pour loyer total
  double get loyerTotal => loyerDeBase + chargesLocatives;
}
