// Fichier : lib/data/models/invitation_model.dart
// Modèle pour les invitations de locataires

import 'package:appwrite/models.dart' as models;

/// Statuts possibles d'une invitation
enum InvitationStatus {
  pending,   // En attente d'acceptation
  accepted,  // Acceptée par le locataire
  rejected,  // Refusée par le locataire
  expired,   // Expirée (non acceptée dans le délai)
  cancelled, // Annulée par le propriétaire
}

extension InvitationStatusExtension on InvitationStatus {
  String get value {
    switch (this) {
      case InvitationStatus.pending:
        return 'pending';
      case InvitationStatus.accepted:
        return 'accepted';
      case InvitationStatus.rejected:
        return 'rejected';
      case InvitationStatus.expired:
        return 'expired';
      case InvitationStatus.cancelled:
        return 'cancelled';
    }
  }

  static InvitationStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return InvitationStatus.pending;
      case 'accepted':
        return InvitationStatus.accepted;
      case 'rejected':
        return InvitationStatus.rejected;
      case 'expired':
        return InvitationStatus.expired;
      case 'cancelled':
        return InvitationStatus.cancelled;
      default:
        return InvitationStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case InvitationStatus.pending:
        return 'En attente';
      case InvitationStatus.accepted:
        return 'Acceptée';
      case InvitationStatus.rejected:
        return 'Refusée';
      case InvitationStatus.expired:
        return 'Expirée';
      case InvitationStatus.cancelled:
        return 'Annulée';
    }
  }
}

class InvitationModel {
  final String? id;
  final String bienId;
  final String bienNom;
  final String proprietaireId;
  final String proprietaireNom;
  final String emailLocataire;
  final String? nomLocataire;
  final String? prenomLocataire;
  final String? telephoneLocataire;
  final InvitationStatus statut;
  final String token; // Token unique pour le lien d'invitation
  final DateTime dateCreation;
  final DateTime dateExpiration;
  final double loyerMensuel;
  final double? charges;
  final String? message; // Message personnalisé du propriétaire
  final String? connectionCodeHash; // Hash du code de connexion stocké en DB
  final DateTime? connectionCodeExpiry;
  final bool? connectionCodeUsed;

  InvitationModel({
    this.id,
    required this.bienId,
    required this.bienNom,
    required this.proprietaireId,
    required this.proprietaireNom,
    required this.emailLocataire,
    this.nomLocataire,
    this.prenomLocataire,
    this.telephoneLocataire,
    this.statut = InvitationStatus.pending,
    required this.token,
    required this.dateCreation,
    required this.dateExpiration,
    required this.loyerMensuel,
    this.charges,
    this.message,
    this.connectionCodeHash,
    this.connectionCodeExpiry,
    this.connectionCodeUsed,
  });

  /// Créer depuis un document Appwrite
  factory InvitationModel.fromAppwrite(models.Document doc) {
    final data = doc.data;
    return InvitationModel(
      id: doc.$id,
      bienId: data['bienId'] ?? '',
      bienNom: data['bienNom'] ?? '',
      proprietaireId: data['proprietaireId'] ?? '',
      proprietaireNom: data['proprietaireNom'] ?? '',
      emailLocataire: data['emailLocataire'] ?? '',
      nomLocataire: data['nomLocataire'],
      prenomLocataire: data['prenomLocataire'],
      telephoneLocataire: data['telephoneLocataire'],
      statut: InvitationStatusExtension.fromString(data['statut'] ?? 'pending'),
      token: data['token'] ?? '',
      dateCreation: DateTime.parse(data['dateCreation']),
      dateExpiration: DateTime.parse(data['dateExpiration']),
      loyerMensuel: (data['loyerMensuel'] as num?)?.toDouble() ?? 0.0,
      charges: (data['charges'] as num?)?.toDouble(),
      message: data['message'],
      connectionCodeHash: data['connectionCodeHash'],
      connectionCodeExpiry: data['connectionCodeExpiry'] != null ? DateTime.parse(data['connectionCodeExpiry']) : null,
      connectionCodeUsed: (data['connectionCodeUsed'] as bool?) ?? false,
    );
  }

  /// Convertir en Map pour Appwrite
  Map<String, dynamic> toAppwrite() {
    return {
      'bienId': bienId,
      'bienNom': bienNom,
      'proprietaireId': proprietaireId,
      'proprietaireNom': proprietaireNom,
      'emailLocataire': emailLocataire,
      'nomLocataire': nomLocataire,
      'prenomLocataire': prenomLocataire,
      'telephoneLocataire': telephoneLocataire,
      'statut': statut.value,
      'token': token,
      'dateCreation': dateCreation.toIso8601String(),
      'dateExpiration': dateExpiration.toIso8601String(),
      'loyerMensuel': loyerMensuel,
      'charges': charges,
      'message': message,
      'connectionCodeHash': connectionCodeHash,
      'connectionCodeExpiry': connectionCodeExpiry?.toIso8601String(),
      'connectionCodeUsed': connectionCodeUsed ?? false,
    };
  }

  /// Vérifier si l'invitation est expirée
  bool get isExpired => DateTime.now().isAfter(dateExpiration);

  /// Vérifier si l'invitation peut être acceptée
  bool get canBeAccepted => 
      statut == InvitationStatus.pending && !isExpired;

  /// Créer une copie avec des modifications
  InvitationModel copyWith({
    String? id,
    String? bienId,
    String? bienNom,
    String? proprietaireId,
    String? proprietaireNom,
    String? emailLocataire,
    String? nomLocataire,
    String? prenomLocataire,
    String? telephoneLocataire,
    InvitationStatus? statut,
    String? token,
    DateTime? dateCreation,
    DateTime? dateExpiration,
    double? loyerMensuel,
    double? charges,
    String? message,
    String? connectionCodeHash,
    DateTime? connectionCodeExpiry,
    bool? connectionCodeUsed,
  }) {
    return InvitationModel(
      id: id ?? this.id,
      bienId: bienId ?? this.bienId,
      bienNom: bienNom ?? this.bienNom,
      proprietaireId: proprietaireId ?? this.proprietaireId,
      proprietaireNom: proprietaireNom ?? this.proprietaireNom,
      emailLocataire: emailLocataire ?? this.emailLocataire,
      nomLocataire: nomLocataire ?? this.nomLocataire,
      prenomLocataire: prenomLocataire ?? this.prenomLocataire,
      telephoneLocataire: telephoneLocataire ?? this.telephoneLocataire,
      statut: statut ?? this.statut,
      token: token ?? this.token,
      dateCreation: dateCreation ?? this.dateCreation,
      dateExpiration: dateExpiration ?? this.dateExpiration,
      loyerMensuel: loyerMensuel ?? this.loyerMensuel,
      charges: charges ?? this.charges,
      message: message ?? this.message,
      connectionCodeHash: connectionCodeHash ?? this.connectionCodeHash,
      connectionCodeExpiry: connectionCodeExpiry ?? this.connectionCodeExpiry,
      connectionCodeUsed: connectionCodeUsed ?? this.connectionCodeUsed,
    );
  }

  /// Convertir en Map pour Appwrite (n'inclut que le hash/expiry)
  Map<String, dynamic> toAppwriteWithHash() {
    final map = toAppwrite();
    if (connectionCodeHash != null) map['connectionCodeHash'] = connectionCodeHash;
    if (connectionCodeExpiry != null) map['connectionCodeExpiry'] = connectionCodeExpiry!.toIso8601String();
    if (connectionCodeUsed != null) map['connectionCodeUsed'] = connectionCodeUsed;
    return map;
  }
}
