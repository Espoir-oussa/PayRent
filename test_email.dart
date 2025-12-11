// Script de test pour vérifier l'envoi d'email Gmail SMTP
// Exécuter avec: dart run test_email.dart

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

void main() async {
  // Configuration Gmail
  const gmailEmail = 'oussachadrac@gmail.com';
  const gmailAppPassword = 'nsbfccxdpqmrfzur'; // Sans espaces
  
  // Email du destinataire à tester
  const destinataire = 'oussabenie@gmail.com';
  
  print('📧 Test d\'envoi email via Gmail SMTP...');
  print('   De: $gmailEmail');
  print('   À: $destinataire');
  print('');
  
  try {
    // Configuration du serveur SMTP Gmail
    final smtpServer = gmail(gmailEmail, gmailAppPassword);
    
    print('🔌 Connexion au serveur SMTP Gmail...');
    
    // Créer le message
    final message = Message()
      ..from = Address(gmailEmail, 'PayRent Test')
      ..recipients.add(destinataire)
      ..subject = '🧪 Test PayRent - ${DateTime.now()}'
      ..html = '''
<!DOCTYPE html>
<html>
<body style="font-family: Arial, sans-serif; padding: 20px;">
  <h1 style="color: #1a237e;">🏠 Test PayRent</h1>
  <p>Ceci est un email de test envoyé depuis PayRent.</p>
  <p>Si vous recevez cet email, la configuration Gmail SMTP fonctionne correctement !</p>
  <p>Date: ${DateTime.now()}</p>
</body>
</html>
''';

    // Envoyer l'email
    print('📤 Envoi en cours...');
    final sendReport = await send(message, smtpServer);
    
    print('');
    print('✅ EMAIL ENVOYÉ AVEC SUCCÈS !');
    print('📧 Rapport: $sendReport');
    print('');
    print('👉 Vérifiez la boîte de réception de $destinataire');
    print('   (Aussi dans les SPAMS !)');
    
  } on MailerException catch (e) {
    print('');
    print('❌ ERREUR D\'ENVOI EMAIL');
    print('   Message: ${e.message}');
    print('');
    print('   Problèmes détaillés:');
    for (var p in e.problems) {
      print('   - ${p.code}: ${p.msg}');
    }
    print('');
    print('💡 Solutions possibles:');
    print('   1. Vérifiez que le mot de passe d\'application est correct');
    print('   2. Vérifiez que la vérification en 2 étapes est activée sur Gmail');
    print('   3. Le mot de passe doit être sans espaces: nsbfccxdpqmrfzur');
    
  } catch (e) {
    print('');
    print('❌ EXCEPTION INATTENDUE: $e');
  }
}
