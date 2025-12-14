// Fichier : lib/data/models/contrat_location_model.dart

import 'package:appwrite/models.dart' as models;

class ContratLocationModel {
  final String? appwriteId; // ID Appwrite du document
  final int idContrat;
  final String idLocataire; // ID Appwrite du locataire
  final String idBien; // ID Appwrite du bien
  final DateTime dateDebut;
  final DateTime? dateFinPrevue;
  final double montantTotalMensuel;
  final String? statut; // 'actif', 'termine', 'resilie'
  final DateTime? dateCreation;

  ContratLocationModel({
    this.appwriteId,
    required this.idContrat,
    required this.idLocataire,
    required this.idBien,
    required this.dateDebut,
    required this.montantTotalMensuel,
    this.dateFinPrevue,
    this.statut = 'actif',
    this.dateCreation,
  });

  factory ContratLocationModel.fromJson(Map<String, dynamic> json) {
    return ContratLocationModel(
      idContrat: json['id_contrat'],
      idLocataire: json['id_locataire'].toString(),
      idBien: json['id_bien'].toString(),
      dateDebut: DateTime.parse(json['date_debut']),
      dateFinPrevue: json['date_fin_prevue'] != null
          ? DateTime.parse(json['date_fin_prevue'])
          : null,
      montantTotalMensuel: (json['montant_total_mensuel'] as num).toDouble(),
      statut: json['statut'],
    );
  }

  /// Factory pour créer depuis un document Appwrite
  factory ContratLocationModel.fromAppwrite(models.Document doc) {
    final data = doc.data;
    return ContratLocationModel(
      appwriteId: doc.$id,
      idContrat: 0,
      idLocataire: data['id_locataire'] ?? '',
      idBien: data['id_bien'] ?? '',
      dateDebut: DateTime.parse(data['date_debut']),
      dateFinPrevue: data['date_fin_prevue'] != null
          ? DateTime.parse(data['date_fin_prevue'])
          : null,
      montantTotalMensuel: (data['montant_total_mensuel'] as num?)?.toDouble() ?? 0.0,
      statut: data['statut'] ?? 'actif',
      dateCreation: data['date_creation'] != null
          ? DateTime.parse(data['date_creation'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_locataire': idLocataire,
      'id_bien': idBien,
      'date_debut': dateDebut.toIso8601String().split('T')[0],
      'date_fin_prevue': dateFinPrevue?.toIso8601String().split('T')[0],
      'montant_total_mensuel': montantTotalMensuel,
      'statut': statut,
    };
  }

  /// Convertir en Map pour Appwrite
  Map<String, dynamic> toAppwrite() {
    return {
      'id_locataire': idLocataire,
      'id_bien': idBien,
      'date_debut': dateDebut.toIso8601String(),
      'date_fin_prevue': dateFinPrevue?.toIso8601String(),
      'montant_total_mensuel': montantTotalMensuel,
      'statut': statut ?? 'actif',
      'date_creation': dateCreation?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  ContratLocationModel copyWith({
    String? appwriteId,
    int? idContrat,
    String? idLocataire,
    String? idBien,
    DateTime? dateDebut,
    DateTime? dateFinPrevue,
    double? montantTotalMensuel,
    String? statut,
    DateTime? dateCreation,
  }) {
    return ContratLocationModel(
      appwriteId: appwriteId ?? this.appwriteId,
      idContrat: idContrat ?? this.idContrat,
      idLocataire: idLocataire ?? this.idLocataire,
      idBien: idBien ?? this.idBien,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFinPrevue: dateFinPrevue ?? this.dateFinPrevue,
      montantTotalMensuel: montantTotalMensuel ?? this.montantTotalMensuel,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }
}