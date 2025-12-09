// Fichier : lib/data/models/contrat_location_model.dart

class ContratLocationModel {
  final int idContrat;
  final int idLocataire; // FK vers UTILISATEUR [cite: 30, 58]
  final int idBien; // FK vers BIEN [cite: 30, 59]
  final DateTime dateDebut; // date_debut [cite: 60]
  final DateTime? dateFinPrevue; // date_fin_prevue [cite: 61]
  final double montantTotalMensuel; // montant_total_mensuel (loyer + charges) [cite: 62]

  ContratLocationModel({
    required this.idContrat,
    required this.idLocataire,
    required this.idBien,
    required this.dateDebut,
    required this.montantTotalMensuel,
    this.dateFinPrevue,
  });

  factory ContratLocationModel.fromJson(Map<String, dynamic> json) {
    return ContratLocationModel(
      idContrat: json['id_contrat'],
      idLocataire: json['id_locataire'],
      idBien: json['id_bien'],
      dateDebut: DateTime.parse(json['date_debut']),
      dateFinPrevue: json['date_fin_prevue'] != null
          ? DateTime.parse(json['date_fin_prevue'])
          : null,
      montantTotalMensuel: (json['montant_total_mensuel'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_locataire': idLocataire,
      'id_bien': idBien,
      // Formatage en string pour le Backend SQL
      'date_debut': dateDebut.toIso8601String().split('T')[0], 
      'date_fin_prevue': dateFinPrevue?.toIso8601String().split('T')[0],
      'montant_total_mensuel': montantTotalMensuel,
    };
  }
}