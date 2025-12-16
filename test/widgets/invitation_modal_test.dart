import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payrent/core/di/providers.dart';
import 'package:payrent/data/models/bien_model.dart';
import 'package:payrent/core/services/invitation_service.dart';
import 'package:payrent/core/services/appwrite_service.dart';
import 'package:payrent/data/models/invitation_model.dart';
import 'package:payrent/domain/repositories/bien_repository.dart';
import 'package:payrent/presentation/shared/widgets/invitation_modal.dart';

class FakeInvitationService extends InvitationService {
  FakeInvitationService(): super(AppwriteService());

  @override
  Future<InvitationResult> createInvitation({
    required BienModel bien,
    required String emailLocataire,
    String? nomLocataire,
    String? prenomLocataire,
    String? telephoneLocataire,
    String? message,
    int expirationDays = 7,
  }) async {
    throw Exception("L'email $emailLocataire n'est pas associé à un utilisateur PayRent. Aucune invitation ne sera créée ni envoyée.");
  }
}

void main() {
  testWidgets('Affiche message quand l\'email n\'est pas utilisateur', (WidgetTester tester) async {
    final fake = FakeInvitationService();

    final b = BienModel(appwriteId: 'b1', proprietaireId: 'owner1', nom: 'Test Bien', adresse: 'Adresse test', loyerMensuel: 100000);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        invitationServiceProvider.overrideWithValue(fake),
        bienRepositoryProvider.overrideWithValue(FakeBienRepository(b)),
      ],
      child: MaterialApp(
        home: Consumer(
          builder: (context, ref, child) {
            // Ouvrir le modal après le premier frame
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showInvitationModal(context: context, ref: ref, bien: b);
            });

            return const Scaffold();
          },
        ),
      ),
    ));

    await tester.pumpAndSettle();

    // Saisir un email
    final emailField = find.byType(TextFormField);
    expect(emailField, findsOneWidget);
    await tester.enterText(emailField, 'nouveau@example.com');
    await tester.pumpAndSettle();

    // Appuyer sur envoyer
    final sendText = find.text('Envoyer l\'invitation');
    expect(sendText, findsOneWidget);
    await tester.tap(sendText);

    await tester.pumpAndSettle();

    // Vérifier que le message est affiché
    expect(find.text('Cet email n\'est pas associé à un utilisateur PayRent. Aucune invitation n\'a été créée ni envoyée.'), findsOneWidget);
  });

  testWidgets('Affiche confirmation quand l\'invitation est envoyée via notification', (WidgetTester tester) async {
    // Fake qui renvoie un résultat d'invitation réussi
    final success = _FakeSuccessInvitationService();

    final b = BienModel(appwriteId: 'b1', proprietaireId: 'owner1', nom: 'Test Bien', adresse: 'Adresse test', loyerMensuel: 100000);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        invitationServiceProvider.overrideWithValue(success),
        bienRepositoryProvider.overrideWithValue(FakeBienRepository(b)),
      ],
      child: MaterialApp(
        home: Consumer(
          builder: (context, ref, child) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showInvitationModal(context: context, ref: ref, bien: b);
            });
            return const Scaffold();
          },
        ),
      ),
    ));

    await tester.pumpAndSettle();

    // Saisir un email
    final emailField = find.byType(TextFormField);
    expect(emailField, findsOneWidget);
    await tester.enterText(emailField, 'existant@example.com');
    await tester.pumpAndSettle();

    // Appuyer sur envoyer
    final sendText = find.text('Envoyer l\'invitation');
    expect(sendText, findsOneWidget);
    await tester.tap(sendText);

    await tester.pumpAndSettle();

    // Vérifier que le message de confirmation s'affiche
    expect(find.text('✅ Invitation envoyée via notification à existant@example.com'), findsOneWidget);
  });
}

class _FakeSuccessInvitationService extends InvitationService {
  _FakeSuccessInvitationService(): super(AppwriteService());

  @override
  Future<InvitationResult> createInvitation({
    required BienModel bien,
    required String emailLocataire,
    String? nomLocataire,
    String? prenomLocataire,
    String? telephoneLocataire,
    String? message,
    int expirationDays = 7,
  }) async {
    final now = DateTime.now();
    final invitation = InvitationModel(
      id: 'i1',
      bienId: bien.appwriteId ?? '',
      bienNom: bien.nom,
      proprietaireId: 'owner1',
      proprietaireNom: 'Owner Test',
      emailLocataire: emailLocataire,
      token: 'token123',
      dateCreation: now,
      dateExpiration: now.add(Duration(days: 7)),
      loyerMensuel: bien.loyerMensuel,
    );

    // Simulate creating notification/doc creation on server
    return InvitationResult(invitation: invitation, targetUserExists: true);
  }
}

class FakeBienRepository implements BienRepository {
  final BienModel _b;
  FakeBienRepository(this._b);

  @override
  Future<List<BienModel>> getBiensByProprietaire(String proprietaireId) async => [_b];

  @override
  Future<BienModel> getBienById(String bienId) async => _b;

  @override
  Future<BienModel> createBien(BienModel bien) async => _b;

  @override
  Future<BienModel> updateBien(String bienId, BienModel bien) async => bien;

  @override
  Future<void> deleteBien(String bienId) async {}

  @override
  Future<List<BienModel>> searchBiens({String? typeBien, double? loyerMin, double? loyerMax, String? adresse}) async => [_b];
}
