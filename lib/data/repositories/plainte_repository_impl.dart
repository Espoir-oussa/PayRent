// Fichier : lib/data/repositories/plainte_repository_impl.dart

// 1. Imports nécessaires pour l'injection et les modèles
import '../../core/services/api_service.dart';
import '../../domain/repositories/plainte_repository.dart';
import '../models/plainte_model.dart';

class PlainteRepositoryImpl implements PlainteRepository {
  final ApiService apiService;

  PlainteRepositoryImpl(this.apiService);

  @override
  Future<List<PlainteModel>> getOwnerComplaints(int ownerId) async {
    // Logique d'appel API réelle vers votre Backend
    // final response = await apiService.get('proprietaires/$ownerId/plaintes');
    // return (response as List).map((json) => PlainteModel.fromJson(json)).toList();

    // Données fictives pour les tests
    await Future.delayed(
        const Duration(milliseconds: 500)); // Simule un appel réseau

    return [
      PlainteModel(
        idPlainte: 1,
        idLocataire: 101,
        idBien: 5,
        idProprietaireGestionnaire: ownerId,
        dateCreation: DateTime.now().subtract(const Duration(days: 3)),
        sujet: 'Fuite d\'eau dans la salle de bain',
        description:
            'Bonjour, il y a une fuite d\'eau importante au niveau du lavabo dans la salle de bain. L\'eau coule en continu même quand le robinet est fermé. Merci de votre intervention rapide.',
        statutPlainte: '1. Ouverte',
      ),
      PlainteModel(
        idPlainte: 2,
        idLocataire: 102,
        idBien: 3,
        idProprietaireGestionnaire: ownerId,
        dateCreation: DateTime.now().subtract(const Duration(days: 7)),
        sujet: 'Problème de chauffage',
        description:
            'Le système de chauffage ne fonctionne plus depuis hier soir. Il fait très froid dans l\'appartement. Pouvez-vous envoyer un technicien ?',
        statutPlainte: '2. Réception',
      ),
      PlainteModel(
        idPlainte: 3,
        idLocataire: 103,
        idBien: 8,
        idProprietaireGestionnaire: ownerId,
        dateCreation: DateTime.now().subtract(const Duration(days: 10)),
        sujet: 'Porte d\'entrée défectueuse',
        description:
            'La serrure de la porte d\'entrée est cassée. J\'ai du mal à fermer la porte correctement. Cela pose un problème de sécurité.',
        statutPlainte: '3. En Cours de Résolution',
      ),
      PlainteModel(
        idPlainte: 4,
        idLocataire: 104,
        idBien: 2,
        idProprietaireGestionnaire: ownerId,
        dateCreation: DateTime.now().subtract(const Duration(days: 15)),
        sujet: 'Panne d\'électricité dans la cuisine',
        description:
            'Plus d\'électricité dans toute la cuisine. Le disjoncteur saute constamment. Impossible d\'utiliser les appareils électroménagers.',
        statutPlainte: '4. Résolue',
      ),
      PlainteModel(
        idPlainte: 5,
        idLocataire: 105,
        idBien: 7,
        idProprietaireGestionnaire: ownerId,
        dateCreation: DateTime.now().subtract(const Duration(days: 20)),
        sujet: 'Fenêtre cassée',
        description:
            'La fenêtre de la chambre principale est fissurée suite à une tempête. Il y a des courants d\'air et le bruit est gênant.',
        statutPlainte: '5. Fermée',
      ),
      PlainteModel(
        idPlainte: 6,
        idLocataire: 106,
        idBien: 4,
        idProprietaireGestionnaire: ownerId,
        dateCreation: DateTime.now().subtract(const Duration(days: 1)),
        sujet: 'Infestation de cafards',
        description:
            'J\'ai remarqué la présence de nombreux cafards dans la cuisine et la salle de bain. C\'est très désagréable. Une désinsectisation est urgente.',
        statutPlainte: '1. Ouverte',
      ),
      PlainteModel(
        idPlainte: 7,
        idLocataire: 107,
        idBien: 6,
        idProprietaireGestionnaire: ownerId,
        dateCreation: DateTime.now().subtract(const Duration(days: 5)),
        sujet: 'Voisinage bruyant',
        description:
            'Les voisins du dessus font beaucoup de bruit la nuit (musique forte, déplacements). Cela perturbe mon sommeil.',
        statutPlainte: '2. Réception',
      ),
      PlainteModel(
        idPlainte: 8,
        idLocataire: 108,
        idBien: 1,
        idProprietaireGestionnaire: ownerId,
        dateCreation: DateTime.now().subtract(const Duration(hours: 12)),
        sujet: 'Ascenseur en panne',
        description:
            'L\'ascenseur de l\'immeuble est en panne depuis ce matin. J\'habite au 5ème étage et c\'est très difficile avec les courses.',
        statutPlainte: '1. Ouverte',
      ),
    ];
  }

  @override
  Future<void> updateComplaintStatus(int complaintId, String newStatus) async {
    // Logique d'appel API réelle : envoi de la mise à jour via PUT
    // await apiService.put(
    //   'plaintes/$complaintId/status',
    //   {
    //     'statut_plainte': newStatus,
    //   },
    // );

    // Simulation de mise à jour pour les tests
    await Future.delayed(const Duration(milliseconds: 800));
    // Dans un vrai système, l'API mettrait à jour la base de données
    print('Plainte #$complaintId mise à jour avec le statut: $newStatus');
  }
}
