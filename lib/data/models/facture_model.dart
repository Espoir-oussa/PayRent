
// ===============================
// 🧾 Modèle de Donnée : Facture
//
// Ce fichier définit la structure du modèle "Facture"
// pour la couche Data de l'application PayRent.
//
// Sert à la conversion des données reçues de l'API (ou de la base de données)
// en objets Dart utilisables dans l'application.
//
// Dossier : lib/data/models/
// Rôle : Modèle de données (Data Model)
// Utilisé par : Repositories, Use Cases, Présentation
// ===============================

// TODO: Définir la classe FactureModel selon le MLD
// Exemple de structure possible :
// class FactureModel {
//   final String id;
//   final double montant;
//   final DateTime dateEmission;
//   final String locataireId;
//   // ... autres champs
// }


// Fichier : lib/data/models/facture_model.dart

class FactureModel {
  final int idFacture;
  final int idPaiement; // Clé 1-1 avec PAIEMENT 
  final DateTime dateEmission;
  final String cheminFichierPdf; // Chemin d'accès au fichier stocké [cite: 78]

  FactureModel({
    required this.idFacture,
    required this.idPaiement,
    required this.dateEmission,
    required this.cheminFichierPdf,
  });

  factory FactureModel.fromJson(Map<String, dynamic> json) {
    return FactureModel(
      idFacture: json['id_facture'],
      idPaiement: json['id_paiement'],
      dateEmission: DateTime.parse(json['date_emission']),
      cheminFichierPdf: json['chemin_fichier_pdf'],
    );
  }

  // Pas de méthode toJson ici, car les factures sont générées automatiquement par le Backend (BF30) [cite: 73]
}