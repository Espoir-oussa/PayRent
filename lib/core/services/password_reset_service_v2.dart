// Fichier : lib/core/services/password_reset_service.dart
// Service simplifié pour la réinitialisation de mot de passe via Appwrite

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'appwrite_service.dart';
import 'email_service.dart';
import 'dart:math';

/// Service de réinitialisation de mot de passe
/// Utilise un système d'OTP personnalisé avec email via Resend
class PasswordResetService {
  final AppwriteService _appwriteService;
  final EmailService _emailService;

  // Map en mémoire pour stocker les OTP (email -> {otp, expiresAt, used})
  // Note: En production, utiliser Redis ou une base de données
  static final Map<String, Map<String, dynamic>> _otpStorage = {};

  PasswordResetService(this._appwriteService) : _emailService = EmailService();

  /// Génère un OTP à 6 chiffres
  String _generateOtp() {
    final random = Random.secure();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  /// Envoie un OTP de réinitialisation de mot de passe
  Future<void> sendPasswordResetOtp({required String email}) async {
    try {
      // 1. Générer un nouvel OTP
      final otp = _generateOtp();
      final expiresAt = DateTime.now().add(const Duration(minutes: 10));

      // 2. Stocker l'OTP en mémoire
      _otpStorage[email.toLowerCase()] = {
        'otp': otp,
        'expiresAt': expiresAt.toIso8601String(),
        'used': false,
      };

      // 3. Envoyer l'email avec l'OTP via Resend
      await _sendOtpEmail(email: email, otp: otp);

      debugPrint('✅ OTP envoyé à $email');
    } catch (e) {
      debugPrint('❌ Erreur envoi OTP: $e');
      throw Exception('Erreur lors de l\'envoi du code de vérification');
    }
  }

  /// Vérifie si l'OTP est valide
  bool verifyOtp({required String email, required String otp}) {
    final emailKey = email.toLowerCase();
    final stored = _otpStorage[emailKey];

    if (stored == null) {
      debugPrint('❌ Aucun OTP pour $email');
      return false;
    }

    if (stored['otp'] != otp) {
      debugPrint('❌ OTP incorrect');
      return false;
    }

    if (stored['used'] == true) {
      debugPrint('❌ OTP déjà utilisé');
      return false;
    }

    final expiresAt = DateTime.parse(stored['expiresAt']);
    if (DateTime.now().isAfter(expiresAt)) {
      debugPrint('❌ OTP expiré');
      return false;
    }

    debugPrint('✅ OTP valide');
    return true;
  }

  /// Réinitialise le mot de passe en utilisant la récupération Appwrite
  /// Cette méthode envoie un email de récupération via Appwrite
  Future<void> initiateAppwriteRecovery({required String email}) async {
    try {
      // Utiliser la récupération native d'Appwrite
      // L'utilisateur recevra un email avec un lien pour réinitialiser
      await _appwriteService.account.createRecovery(
        email: email,
        url: 'payrent://reset-password', // Deep link pour l'app
      );
      debugPrint('✅ Email de récupération Appwrite envoyé');
    } on AppwriteException catch (e) {
      debugPrint('❌ Erreur Appwrite recovery: ${e.message}');
      // Ne pas révéler si l'email existe ou non
      // Retourner silencieusement pour éviter l'énumération d'emails
    }
  }

  /// Finalise la réinitialisation après vérification OTP
  /// Envoie un email Appwrite pour le changement effectif du mot de passe
  Future<void> resetPasswordWithOtp({
    required String email,
    required String otp,
  }) async {
    // Vérifier l'OTP
    if (!verifyOtp(email: email, otp: otp)) {
      throw Exception('Code de vérification invalide ou expiré');
    }

    // Marquer l'OTP comme utilisé
    _otpStorage[email.toLowerCase()]?['used'] = true;

    // Lancer la récupération Appwrite
    await initiateAppwriteRecovery(email: email);
  }

  /// Nettoie les OTP expirés (à appeler périodiquement)
  void cleanupExpiredOtps() {
    final now = DateTime.now();
    _otpStorage.removeWhere((email, data) {
      final expiresAt = DateTime.parse(data['expiresAt']);
      return now.isAfter(expiresAt);
    });
  }

  /// Envoie l'email contenant l'OTP
  Future<void> _sendOtpEmail({
    required String email,
    required String otp,
  }) async {
    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f5f5f5;">
  <div style="max-width: 600px; margin: 0 auto; background-color: white; border-radius: 16px; overflow: hidden; margin-top: 20px; margin-bottom: 20px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);">
    
    <div style="background: linear-gradient(135deg, #8B0000 0%, #A52A2A 100%); padding: 40px 20px; text-align: center;">
      <h1 style="color: white; margin: 0; font-size: 28px;">🔐 Code de vérification</h1>
    </div>
    
    <div style="padding: 40px 30px;">
      <p style="font-size: 16px; color: #333; margin-bottom: 20px;">
        Bonjour,
      </p>
      
      <p style="font-size: 16px; color: #333; margin-bottom: 20px;">
        Vous avez demandé à réinitialiser votre mot de passe sur PayRent. Voici votre code de vérification :
      </p>
      
      <div style="background: linear-gradient(135deg, #f5f5f5 0%, #eeeeee 100%); border-radius: 12px; padding: 30px; margin: 25px 0; text-align: center;">
        <p style="margin: 0 0 10px 0; font-size: 14px; color: #666;">
          Votre code de vérification :
        </p>
        <p style="margin: 0; font-size: 36px; letter-spacing: 8px; font-weight: bold; color: #8B0000; font-family: monospace;">
          $otp
        </p>
      </div>
      
      <div style="background-color: #fff3e0; border-left: 4px solid #ff9800; padding: 15px; margin: 20px 0;">
        <p style="margin: 0; font-size: 14px; color: #e65100;">
          ⚠️ <strong>Ce code expire dans 10 minutes.</strong>
        </p>
      </div>
      
      <p style="font-size: 14px; color: #666; margin-top: 25px;">
        Si vous n'avez pas demandé cette réinitialisation, ignorez cet email.
      </p>
    </div>
    
    <div style="background-color: #f5f5f5; padding: 20px; text-align: center;">
      <p style="margin: 0; font-size: 12px; color: #666;">
        © 2024 PayRent - Gestion locative simplifiée
      </p>
    </div>
  </div>
</body>
</html>
''';

    await _emailService.sendCustomEmail(
      to: email,
      subject: '🔐 Code de vérification PayRent',
      htmlContent: htmlContent,
    );
  }
}
