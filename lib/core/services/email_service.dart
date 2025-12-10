// Fichier : lib/core/services/email_service.dart
// Service pour envoyer des emails via Resend API

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Configuration du service email - Utilise Resend
class EmailConfig {
  // ⚠️ IMPORTANT: En production, stockez ces clés de manière sécurisée
  // (variables d'environnement, Appwrite Functions, ou backend sécurisé)
  
  // Resend API - Service principal
  static const String resendApiKey = 're_ZzgufrTg_2D3iVhiL5a37ry1uxDd5BKtV';
  static const String resendApiUrl = 'https://api.resend.com/emails';
  
  // Expéditeur (doit être un domaine vérifié sur Resend)
  static const String senderEmail = 'contact@igoradande.me';
  static const String senderName = 'PayRent';
  
  // URLs de l'application
  static const String appScheme = 'payrent';
  static const String webBaseUrl = 'https://payrent.app'; // Pour les liens web
}

class EmailService {
  /// Envoie un email d'invitation au locataire
  Future<bool> sendInvitationEmail({
    required String recipientEmail,
    required String recipientName,
    required String proprietaireNom,
    required String bienNom,
    required String token,
    required double loyerMensuel,
    double? charges,
    String? messagePersonnalise,
  }) async {
    final acceptUrl = '${EmailConfig.webBaseUrl}/accept-invitation?token=$token';
    final rejectUrl = '${EmailConfig.webBaseUrl}/reject-invitation?token=$token';
    
    // Lien deep link pour l'app mobile
    final appAcceptUrl = '${EmailConfig.appScheme}://accept-invitation?token=$token&action=accept';
    final appRejectUrl = '${EmailConfig.appScheme}://accept-invitation?token=$token&action=reject';

    final htmlContent = _buildInvitationEmailHtml(
      recipientName: recipientName,
      proprietaireNom: proprietaireNom,
      bienNom: bienNom,
      loyerMensuel: loyerMensuel,
      charges: charges,
      messagePersonnalise: messagePersonnalise,
      acceptUrl: acceptUrl,
      rejectUrl: rejectUrl,
      appAcceptUrl: appAcceptUrl,
      appRejectUrl: appRejectUrl,
    );

    // Envoyer avec Resend
    return await _sendWithResend(
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

    return await _sendWithResend(
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
      
      $messageSection
      
      <p style="font-size: 14px; color: #666; margin: 25px 0;">
        En acceptant cette invitation, un compte PayRent sera automatiquement créé pour vous et vous pourrez gérer vos paiements et communiquer avec votre propriétaire.
      </p>
      
      <!-- Boutons d'action -->
      <div style="text-align: center; margin: 35px 0;">
        <a href="$acceptUrl" style="display: inline-block; background: linear-gradient(135deg, #43a047 0%, #66bb6a 100%); color: white; text-decoration: none; padding: 15px 40px; border-radius: 30px; font-weight: bold; font-size: 16px; margin: 5px;">
          ✓ Accepter l'invitation
        </a>
        <br><br>
        <a href="$rejectUrl" style="display: inline-block; background-color: #f5f5f5; color: #666; text-decoration: none; padding: 12px 30px; border-radius: 30px; font-weight: 500; font-size: 14px; border: 1px solid #ddd; margin: 5px;">
          ✕ Refuser
        </a>
      </div>
      
      <!-- Lien alternatif -->
      <div style="background-color: #fafafa; border-radius: 8px; padding: 15px; margin-top: 25px;">
        <p style="margin: 0 0 10px 0; font-size: 12px; color: #666;">
          Si les boutons ne fonctionnent pas, copiez ce lien dans votre navigateur :
        </p>
        <p style="margin: 0; font-size: 11px; color: #999; word-break: break-all;">
          $acceptUrl
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

  /// Envoie l'email via Resend API
  Future<bool> _sendWithResend({
    required String to,
    required String subject,
    required String htmlContent,
  }) async {
    if (EmailConfig.resendApiKey.isEmpty) {
      debugPrint('⚠️ Clé API Resend non configurée.');
      return false;
    }

    try {
      debugPrint('📧 Envoi email à $to via Resend...');
      
      final response = await http.post(
        Uri.parse(EmailConfig.resendApiUrl),
        headers: {
          'Authorization': 'Bearer ${EmailConfig.resendApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'from': '${EmailConfig.senderName} <${EmailConfig.senderEmail}>',
          'to': [to],
          'subject': subject,
          'html': htmlContent,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Exception Resend: $e');
      return false;
    }
  }
}
