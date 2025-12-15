// ===============================
// 📦 Modèle de Donnée : Bien
//
// Ce fichier définit la structure du modèle "Bien" (propriété immobilière)
// pour la couche Data de l'application PayRent.
//
// Il sert à la conversion des données reçues de l'API (ou de la base de données)
// en objets Dart utilisables dans l'application.
//
// Dossier : lib/data/models/
// Rôle : Modèle de données (Data Model)
// Utilisé par : Repositories, Use Cases, Présentation
// ===============================

import 'package:appwrite/models.dart' as models;

class BienModel {
  final String? appwriteId; // ID Appwrite du document
  final int idBien;
  final String proprietaireId; // ID Appwrite du propriétaire
  final String nom;
  final String adresse;
  final String? type;
  final String? description;
  final double? surface;
  final int? nombrePieces;
  final int? nombreChambres;
  final int? nombreSallesDeBain;
  final double loyerMensuel;
  final double? charges;
  final double? caution;
  final String? statut;
  final List<String>? photosUrls;
  final List<String>? equipements;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BienModel({
    this.appwriteId,
    this.idBien = 0,
    required this.proprietaireId,
    required this.nom,
    required this.adresse,
    required this.loyerMensuel,
    this.type,
    this.description,
    this.surface,
    this.nombrePieces,
    this.nombreChambres,
    this.nombreSallesDeBain,
    this.charges,
    this.caution,
    this.statut = 'disponible',
    this.photosUrls,
    this.equipements,
    this.createdAt,
    this.updatedAt,
  });

  factory BienModel.fromJson(Map<String, dynamic> json) {
    return BienModel(
      idBien: json['id_bien'] ?? 0,
      proprietaireId: json['proprietaireId']?.toString() ?? '',
      nom: json['nom'] ?? '',
      adresse: json['adresse'] ?? '',
      type: json['type'],
      description: json['description'],
      photosUrls: _parsePhotosFromJson(json['photosUrls']),
      surface: (json['surface'] as num?)?.toDouble(),
      nombrePieces: json['nombrePieces'],
      nombreChambres: json['nombreChambres'],
      nombreSallesDeBain: json['nombreSallesDeBain'],
      loyerMensuel: (json['loyerMensuel'] as num?)?.toDouble() ?? 0.0,
      charges: (json['charges'] as num?)?.toDouble(),
      caution: (json['caution'] as num?)?.toDouble(),
      statut: json['statut'],
    );
  }

  /// Factory pour créer un BienModel depuis un document Appwrite
  factory BienModel.fromAppwrite(models.Document doc) {
    final data = doc.data;

    // Parser les listes stockées comme strings séparées par virgules
    List<String>? parseStringList(dynamic value) {
      if (value == null || value == '') return null;
      if (value is List) return value.map((e) => e.toString()).toList();
      if (value is String && value.isNotEmpty) {
        // Parser les strings séparées par virgules
        return value.split(',').where((s) => s.trim().isNotEmpty).toList();
      }
      return null;
    }

    return BienModel(
      appwriteId: doc.$id,
      idBien: 0,
      proprietaireId: data['proprietaireId'] ?? '',
      nom: data['nom'] ?? '',
      adresse: data['adresse'] ?? '',
      type: data['type'],
      description: data['description'],
      surface: (data['surface'] as num?)?.toDouble(),
      nombrePieces: data['nombrePieces'],
      nombreChambres: data['nombreChambres'],
      nombreSallesDeBain: data['nombreSallesDeBain'],
      loyerMensuel: (data['loyerMensuel'] as num?)?.toDouble() ?? 0.0,
      charges: (data['charges'] as num?)?.toDouble(),
      caution: (data['caution'] as num?)?.toDouble(),
      statut: data['statut'] ?? 'disponible',
      photosUrls: parseStringList(data['photosUrls']),
      equipements: parseStringList(data['equipements']),
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'])
          : null,
      updatedAt: data['updatedAt'] != null
          ? DateTime.tryParse(data['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'proprietaireId': proprietaireId,
      'nom': nom,
      'adresse': adresse,
      'photosUrls': photosUrls,
      'type': type,
      'loyerMensuel': loyerMensuel,
      'charges': charges,
      'statut': statut,
    };
  }

  static List<String>? _parsePhotosFromJson(dynamic value) {
    if (value == null) return null;
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is String && value.isNotEmpty) {
      // Could be comma-separated or a single url
      if (value.contains(',')) {
        return value.split(',').where((s) => s.trim().isNotEmpty).toList();
      }
      return [value];
    }
    return null;
  }

  /// Convertir en Map pour Appwrite
  Map<String, dynamic> toAppwrite() {
    return {
      'proprietaireId': proprietaireId,
      'nom': nom,
      'adresse': adresse,
      'type': type ?? 'appartement',
      'description': description ?? '',
      'surface': surface,
      'nombrePieces': nombrePieces,
      'nombreChambres': nombreChambres,
      'nombreSallesDeBain': nombreSallesDeBain,
      'loyerMensuel': loyerMensuel,
      'charges': charges ?? 0.0,
      'caution': caution ?? 0.0,
      'statut': statut ?? 'disponible',
      'photosUrls': photosUrls?.join(',') ?? '',
      'equipements': equipements?.join(',') ?? '',
      'createdAt':
          createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Créer une copie avec des modifications
  BienModel copyWith({
    String? appwriteId,
    int? idBien,
    String? proprietaireId,
    String? nom,
    String? adresse,
    String? type,
    String? description,
    double? surface,
    int? nombrePieces,
    int? nombreChambres,
    int? nombreSallesDeBain,
    double? loyerMensuel,
    double? charges,
    double? caution,
    String? statut,
    List<String>? photosUrls,
    List<String>? equipements,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BienModel(
      appwriteId: appwriteId ?? this.appwriteId,
      idBien: idBien ?? this.idBien,
      proprietaireId: proprietaireId ?? this.proprietaireId,
      nom: nom ?? this.nom,
      adresse: adresse ?? this.adresse,
      type: type ?? this.type,
      description: description ?? this.description,
      surface: surface ?? this.surface,
      nombrePieces: nombrePieces ?? this.nombrePieces,
      nombreChambres: nombreChambres ?? this.nombreChambres,
      nombreSallesDeBain: nombreSallesDeBain ?? this.nombreSallesDeBain,
      loyerMensuel: loyerMensuel ?? this.loyerMensuel,
      charges: charges ?? this.charges,
      caution: caution ?? this.caution,
      statut: statut ?? this.statut,
      photosUrls: photosUrls ?? this.photosUrls,
      equipements: equipements ?? this.equipements,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
