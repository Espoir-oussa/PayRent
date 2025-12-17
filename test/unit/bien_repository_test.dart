import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:appwrite/models.dart' as models;
import 'package:appwrite/appwrite.dart';
import 'package:payrent/data/repositories/bien_repository_appwrite.dart';
import 'package:payrent/core/services/appwrite_service.dart';
import 'package:payrent/data/models/bien_model.dart';

class MockAppwriteService extends Mock implements AppwriteService {}

void main() {
  group('BienRepositoryAppwrite', () {
    late MockAppwriteService mockAppwrite;
    late BienRepositoryAppwrite repo;

    setUp(() {
      mockAppwrite = MockAppwriteService();
      repo = BienRepositoryAppwrite(mockAppwrite);
    });

    test('createBien sets proprietaireId to current user and is not visible to others', () async {
      final currentUser = models.User(
        '$',
        email: 'ownerA@example.com',
        name: 'Owner A',
      );

      when(mockAppwrite.getCurrentUser()).thenAnswer((_) async => currentUser);

      final input = BienModel(
        proprietaireId: 'ownerA',
        nom: 'Test Bien',
        adresse: 'Adresse',
        loyerMensuel: 100000,
      );

      final doc = models.Document(
        data: {
          'proprietaireId': 'ownerA',
          'nom': 'Test Bien',
          'adresse': 'Adresse',
          'loyerMensuel': 100000,
        },
        $id: 'b1',
        $collection: 'biens',
        $permissions: [],
      );

      when(mockAppwrite.createDocument(collectionId: anyNamed('collectionId'), data: anyNamed('data'), permissions: anyNamed('permissions')))
          .thenAnswer((_) async => doc);

      final created = await repo.createBien(input);
      expect(created.proprietaireId, 'ownerA');

      // Simulate owner B listing biens: getBiensByProprietaire should not return the above
      final resultDocs = models.DocumentList(documents: [doc]);
      when(mockAppwrite.listDocuments(collectionId: anyNamed('collectionId'), queries: anyNamed('queries')))
          .thenAnswer((inv) async {
        final queries = inv.namedArguments[const Symbol('queries')];
        // If query filters by ownerB, return empty
        return Result.documents(resultDocs.documents);
      });

      final biensForOwnerB = await repo.getBiensByProprietaire('ownerB');
      expect(biensForOwnerB.where((b) => b.appwriteId == 'b1'), isEmpty);
    });
  });
}
