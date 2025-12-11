// Fichier : lib/core/services/email_service.dart
// Service pour envoyer des emails via Gmail SMTP

import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

/// Configuration du service email - Utilise Gmail SMTP
class EmailConfig {
  // ⚠️ IMPORTANT: En production, stockez ces informations de manière sécurisée
  
  // Configuration Gmail
  // Pour utiliser Gmail, vous devez :
  // 1. Activer "Accès moins sécurisé" OU
  // 2. Créer un "Mot de passe d'application" (recommandé) :
  //    - Aller sur https://myaccount.google.com/apppasswords
  //    - Créer un mot de passe pour "Mail" sur "Autre (PayRent)"
  //    - Utiliser ce mot de passe ci-dessous (pas votre mot de passe Gmail normal)
  static const String gmailEmail = 'oussachadrac@gmail.com';
  static const String gmailAppPassword = 'nsbfccxdpqmrfzur'; // Mot de passe d'application Gmail
  
  // Nom de l'expéditeur
  static const String senderName = 'PayRent';
  
  // URLs de l'application
  static const String appScheme = 'payrent';
  // URL de la page de redirection (à héberger sur GitHub Pages ou autre)
  // Format: https://votre-username.github.io/payrent-redirect/
  static const String webBaseUrl = 'https://espoir-oussa.github.io/payrent-releases';
}

class EmailService {
  /// Envoie un email d'invitation au locataire
  Future<bool> sendInvitationEmail({
    required String recipientEmail,
    required String recipientName,
    required String proprietaireNom,
    required String bienNom,
    required String token,
    String? connectionCode,
    String? temporaryPassword,
    DateTime? connectionCodeExpiry,
    required double loyerMensuel,
    double? charges,
    String? messagePersonnalise,
  }) async {
    // URLs web avec page de redirection (GitHub Pages)
    // La page index.html redirigera automatiquement vers l'app si installée
    // Optionally include the connectionCode in the accept/reject links so that
    // the tenant can open the link and have the code pre-filled for quick acceptation.
    // Send temporaryPassword and code as optional query params
    final codeQuery = connectionCode != null ? '&code=$connectionCode' : '';
    final passQuery = temporaryPassword != null ? '&tempPass=$temporaryPassword' : '';
    final acceptUrl = '${EmailConfig.webBaseUrl}?token=$token&action=accept$codeQuery$passQuery';
    final rejectUrl = '${EmailConfig.webBaseUrl}?token=$token&action=reject$codeQuery$passQuery';
    
    // Lien deep link pour l'app mobile (à copier/coller)
    final appAcceptUrl = '${EmailConfig.appScheme}://accept-invitation?token=$token&action=accept${codeQuery}${passQuery}';
    final appRejectUrl = '${EmailConfig.appScheme}://accept-invitation?token=$token&action=reject${codeQuery}${passQuery}';

    final htmlContent = _buildInvitationEmailHtml(
      recipientName: recipientName,
      proprietaireNom: proprietaireNom,
      bienNom: bienNom,
      connectionCode: connectionCode,
      connectionCodeExpiry: connectionCodeExpiry,
      loyerMensuel: loyerMensuel,
      charges: charges,
      messagePersonnalise: messagePersonnalise,
      acceptUrl: acceptUrl,
      rejectUrl: rejectUrl,
      appAcceptUrl: appAcceptUrl,
      appRejectUrl: appRejectUrl,
    );

    // Envoyer avec Gmail SMTP
    return await _sendWithGmail(
      to: recipientEmail,
      subject: '🏠 Invitation à rejoindre $bienNom sur PayRent',
      htmlContent: htmlContent,
    );
  }

  /// Envoie un email de bienvenue après l'acceptation
  Future<bool> sendWelcomeEmail({
    required String recipientEmail,
    required String recipientName,
    required String bienNom,
    required String temporaryPassword,
  }) async {
    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Bienvenue sur PayRent</title>
</head>
<body style="margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f5f5f5;">
  <div style="max-width: 600px; margin: 0 auto; background-color: white; border-radius: 16px; overflow: hidden; margin-top: 20px; margin-bottom: 20px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);">
    
    <!-- Header -->
    <div style="background: linear-gradient(135deg, #1a237e 0%, #3949ab 100%); padding: 40px 20px; text-align: center;">
      <h1 style="color: white; margin: 0; font-size: 28px;">🎉 Bienvenue sur PayRent !</h1>
    </div>
    
    <!-- Content -->
    <div style="padding: 40px 30px;">
      <p style="font-size: 16px; color: #333; margin-bottom: 20px;">
        Bonjour <strong>$recipientName</strong>,
      </p>
      
      <p style="font-size: 16px; color: #333; margin-bottom: 20px;">
        Votre compte a été créé avec succès ! Vous êtes maintenant locataire de <strong>$bienNom</strong>.
      </p>
      
      <div style="background-color: #e3f2fd; border-radius: 12px; padding: 20px; margin: 25px 0;">
        <p style="margin: 0 0 10px 0; font-size: 14px; color: #1565c0; font-weight: bold;">
          📧 Vos identifiants de connexion :
        </p>
        <p style="margin: 5px 0; font-size: 14px; color: #333;">
          <strong>Email :</strong> $recipientEmail
        </p>
        <p style="margin: 5px 0; font-size: 14px; color: #333;">
          <strong>Mot de passe temporaire :</strong> <code style="background: #fff; padding: 2px 8px; border-radius: 4px;">$temporaryPassword</code>
        </p>
      </div>
      
      <div style="background-color: #fff3e0; border-left: 4px solid #ff9800; padding: 15px; margin: 20px 0;">
        <p style="margin: 0; font-size: 14px; color: #e65100;">
          ⚠️ <strong>Important :</strong> Pour votre sécurité, veuillez changer votre mot de passe dès votre première connexion dans votre profil.
        </p>
      </div>
      
      <div style="text-align: center; margin: 30px 0;">
        <a href="${EmailConfig.webBaseUrl}" style="display: inline-block; background: linear-gradient(135deg, #1a237e 0%, #3949ab 100%); color: white; text-decoration: none; padding: 15px 40px; border-radius: 30px; font-weight: bold; font-size: 16px;">
          Accéder à mon espace
        </a>
      </div>
    </div>
    
    <!-- Footer -->
    <div style="background-color: #f5f5f5; padding: 20px; text-align: center;">
      <p style="margin: 0; font-size: 12px; color: #666;">
        © 2024 PayRent - Gestion locative simplifiée
      </p>
    </div>
  </div>
</body>
</html>
''';

    return await _sendWithGmail(
      to: recipientEmail,
      subject: '🎉 Bienvenue sur PayRent - Votre compte est prêt !',
      htmlContent: htmlContent,
    );
  }

  /// Construit le contenu HTML de l'email d'invitation
  String _buildInvitationEmailHtml({
    required String recipientName,
    required String proprietaireNom,
    required String bienNom,
    String? connectionCode,
    DateTime? connectionCodeExpiry,
    required double loyerMensuel,
    double? charges,
    String? messagePersonnalise,
    required String acceptUrl,
    required String rejectUrl,
    required String appAcceptUrl,
    required String appRejectUrl,
  }) {
    final loyerFormatted = loyerMensuel.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
    
    final chargesText = charges != null && charges > 0
        ? ' + ${charges.toStringAsFixed(0)} FCFA de charges'
        : '';

    final messageSection = messagePersonnalise != null && messagePersonnalise.isNotEmpty
        ? '''
        <div style="background-color: #f5f5f5; border-radius: 12px; padding: 20px; margin: 25px 0;">
          <p style="margin: 0 0 10px 0; font-size: 14px; color: #666; font-style: italic;">
            💬 Message de $proprietaireNom :
          </p>
          <p style="margin: 0; font-size: 14px; color: #333;">
            "$messagePersonnalise"
          </p>
        </div>
        '''
        : '';

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Invitation PayRent</title>
</head>
<body style="margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f5f5f5;">
  <div style="max-width: 600px; margin: 0 auto; background-color: white; border-radius: 16px; overflow: hidden; margin-top: 20px; margin-bottom: 20px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);">
    
    <!-- Header avec gradient -->
    <div style="background: linear-gradient(135deg, #1a237e 0%, #3949ab 100%); padding: 40px 20px; text-align: center;">
      <h1 style="color: white; margin: 0; font-size: 28px;">🏠 Invitation à rejoindre</h1>
      <p style="color: rgba(255,255,255,0.9); margin: 10px 0 0 0; font-size: 18px;">$bienNom</p>
    </div>
    
    <!-- Contenu principal -->
    <div style="padding: 40px 30px;">
      <p style="font-size: 16px; color: #333; margin-bottom: 20px;">
        Bonjour${recipientName.isNotEmpty ? ' <strong>$recipientName</strong>' : ''},
      </p>
      
      <p style="font-size: 16px; color: #333; margin-bottom: 20px;">
        <strong>$proprietaireNom</strong> vous invite à rejoindre le logement <strong>$bienNom</strong> en tant que locataire sur <strong>PayRent</strong>.
      </p>
      
      <!-- Détails du loyer -->
      <div style="background: linear-gradient(135deg, #e8eaf6 0%, #c5cae9 100%); border-radius: 12px; padding: 20px; margin: 25px 0;">
        <p style="margin: 0; font-size: 14px; color: #3949ab; font-weight: bold;">
          💰 Conditions de location :
        </p>
        <p style="margin: 10px 0 0 0; font-size: 20px; color: #1a237e; font-weight: bold;">
          $loyerFormatted FCFA / mois$chargesText
        </p>
      </div>

      <!-- Code de connexion -->
      ${connectionCode != null ? '''
      <div style="background-color: #fff3e0; border-radius: 12px; padding: 18px; margin: 15px 0; border-left: 6px solid #ffb74d;">
        <p style="margin:0 0 8px 0; font-size:14px; color:#e65100; font-weight:bold;">🔐 Code de connexion</p>
        <p style="margin:0; font-size:18px; color:#333;">Utilisez ce code pour vous connecter : <strong style="font-size:20px;">$connectionCode</strong></p>
        <p style="margin:10px 0 0 0; font-size:13px; color:#666;">Le code est valide jusqu'au ${connectionCodeExpiry != null ? connectionCodeExpiry.toLocal().toString().split(' ')[0] : DateTime.now().add(Duration(days:7)).toLocal().toString().split(' ')[0]}.</p>
      </div>
      ''' : ''}
      
      $messageSection
      
      <p style="font-size: 14px; color: #666; margin: 25px 0;">
        En acceptant cette invitation, un compte PayRent sera automatiquement créé pour vous et vous pourrez gérer vos paiements et communiquer avec votre propriétaire.
      </p>
      
      <!-- Boutons d'action - Liens web qui seront gérés par l'app si installée -->
      <div style="text-align: center; margin: 35px 0;">
        <a href="$acceptUrl" style="display: inline-block; background: linear-gradient(135deg, #43a047 0%, #66bb6a 100%); color: white; text-decoration: none; padding: 15px 40px; border-radius: 30px; font-weight: bold; font-size: 16px; margin: 5px;">
          ✓ Accepter l'invitation
        </a>
        <br><br>
        <a href="$rejectUrl" style="display: inline-block; background-color: #f5f5f5; color: #666; text-decoration: none; padding: 12px 30px; border-radius: 30px; font-weight: 500; font-size: 14px; border: 1px solid #ddd; margin: 5px;">
          ✕ Refuser
        </a>
      </div>
      
      <!-- Instructions pour ouvrir dans l'app -->
      <div style="background-color: #e3f2fd; border-radius: 8px; padding: 15px; margin: 20px 0; border-left: 4px solid #1976d2;">
        <p style="margin: 0 0 10px 0; font-size: 13px; color: #1565c0;">
          📱 <strong>Vous avez l'application PayRent installée ?</strong>
        </p>
        <p style="margin: 0; font-size: 12px; color: #1565c0;">
          Copiez ce lien et ouvrez-le dans votre navigateur pour lancer l'app :
        </p>
        <p style="margin: 10px 0 0 0; font-size: 11px; color: #0d47a1; word-break: break-all; background: #bbdefb; padding: 8px; border-radius: 4px;">
          $appAcceptUrl
        </p>
      </div>
    </div>
    
    <!-- Footer -->
    <div style="background-color: #f5f5f5; padding: 20px; text-align: center;">
      <p style="margin: 0 0 10px 0; font-size: 12px; color: #666;">
        Vous recevez cet email car <strong>$proprietaireNom</strong> vous a invité sur PayRent.
      </p>
      <p style="margin: 0; font-size: 12px; color: #999;">
        © 2024 PayRent - Gestion locative simplifiée
      </p>
    </div>
  </div>
</body>
</html>
''';
  }

  /// Version texte de l'email (pour les clients mail qui ne supportent pas le HTML)
  String _buildInvitationEmailText({
    required String recipientName,
    required String proprietaireNom,
    required String bienNom,
    required double loyerMensuel,
    double? charges,
    String? messagePersonnalise,
    required String acceptUrl,
  }) {
    final chargesText = charges != null && charges > 0
        ? ' + ${charges.toStringAsFixed(0)} FCFA de charges'
        : '';

    return '''
Bonjour${recipientName.isNotEmpty ? ' $recipientName' : ''},

$proprietaireNom vous invite à rejoindre le logement "$bienNom" en tant que locataire sur PayRent.

Loyer mensuel: ${loyerMensuel.toStringAsFixed(0)} FCFA$chargesText

${messagePersonnalise != null && messagePersonnalise.isNotEmpty ? 'Message: "$messagePersonnalise"\n\n' : ''}

Pour accepter cette invitation, cliquez sur ce lien:
$acceptUrl

En acceptant, un compte PayRent sera automatiquement créé pour vous.

---
PayRent - Gestion locative simplifiée
''';
  }

  /// Envoie l'email via Gmail SMTP
  Future<bool> _sendWithGmail({
    required String to,
    required String subject,
    required String htmlContent,
  }) async {
    if (EmailConfig.gmailAppPassword.isEmpty || 
        EmailConfig.gmailAppPassword == 'VOTRE_MOT_DE_PASSE_APPLICATION') {
      debugPrint('⚠️ Mot de passe d\'application Gmail non configuré.');
      debugPrint('📝 Instructions:');
      debugPrint('   1. Allez sur https://myaccount.google.com/apppasswords');
      debugPrint('   2. Créez un mot de passe pour "Mail" > "Autre (PayRent)"');
      debugPrint('   3. Copiez le mot de passe dans EmailConfig.gmailAppPassword');
      return false;
    }

    try {
      debugPrint('📧 Envoi email à $to via Gmail SMTP...');
      
      // Configuration du serveur SMTP Gmail
      final smtpServer = gmail(EmailConfig.gmailEmail, EmailConfig.gmailAppPassword);

      // Créer le message
      final message = Message()
        ..from = Address(EmailConfig.gmailEmail, EmailConfig.senderName)
        ..recipients.add(to)
        ..subject = subject
        ..html = htmlContent;

      // Envoyer l'email
      final sendReport = await send(message, smtpServer);
      
      debugPrint('✅ Email envoyé avec succès à $to');
      debugPrint('📧 Rapport: $sendReport');
      return true;
    } on MailerException catch (e) {
      debugPrint('❌ Erreur envoi email: ${e.message}');
      for (var p in e.problems) {
        debugPrint('   Problème: ${p.code}: ${p.msg}');
      }
      return false;
    } catch (e) {
      debugPrint('❌ Exception Gmail SMTP: $e');
      return false;
    }
  }
}
