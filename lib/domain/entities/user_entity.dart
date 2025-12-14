// Fichier : lib/domain/entities/user_entity.dart

class UserEntity {
  final int idUtilisateur;
  final String typeRole;
  final String email;
  final String nom;
  final String prenom;
  final String? telephone;
  final String? token; // Ajout du token

  const UserEntity({
    required this.idUtilisateur,
    required this.typeRole,
    required this.email,
    required this.nom,
    required this.prenom,
    this.telephone,
    this.token,
  });
}