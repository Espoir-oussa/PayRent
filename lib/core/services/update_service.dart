// Fichier : lib/core/services/update_service.dart
// Service de mise à jour automatique de l'application

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

/// Informations sur la version disponible
class VersionInfo {
  final String version;
  final String apkUrl;
  final String size;
  final String releaseDate;
  final List<String> changelog;
  final String minAndroidVersion;

  VersionInfo({
    required this.version,
    required this.apkUrl,
    required this.size,
    required this.releaseDate,
    required this.changelog,
    required this.minAndroidVersion,
  });

  factory VersionInfo.fromJson(Map<String, dynamic> json) {
    return VersionInfo(
      version: json['version'] ?? '1.0.0',
      apkUrl: json['apkUrl'] ?? '',
      size: json['size'] ?? '',
      releaseDate: json['releaseDate'] ?? '',
      changelog: List<String>.from(json['changelog'] ?? []),
      minAndroidVersion: json['minAndroidVersion'] ?? '5.0',
    );
  }
}

/// Résultat de la vérification de mise à jour
class UpdateCheckResult {
  final bool updateAvailable;
  final VersionInfo? latestVersion;
  final String currentVersion;
  final String? error;

  UpdateCheckResult({
    required this.updateAvailable,
    this.latestVersion,
    required this.currentVersion,
    this.error,
  });
}

class UpdateService {
  static const String _versionUrl =
      'https://espoir-oussa.github.io/payrent-releases/version.json';

  final Dio _dio = Dio();

  /// Vérifier si une mise à jour est disponible
  Future<UpdateCheckResult> checkForUpdate() async {
    try {
      // Récupérer la version actuelle de l'app
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      debugPrint('📱 Version actuelle: $currentVersion');

      // Récupérer la version disponible sur le serveur
      final response = await http.get(Uri.parse(_versionUrl));

      if (response.statusCode != 200) {
        return UpdateCheckResult(
          updateAvailable: false,
          currentVersion: currentVersion,
          error: 'Impossible de vérifier les mises à jour',
        );
      }

      final json = jsonDecode(response.body);
      final latestVersion = VersionInfo.fromJson(json);

      debugPrint('🌐 Version disponible: ${latestVersion.version}');

      // Comparer les versions
      final isUpdateAvailable =
          _compareVersions(currentVersion, latestVersion.version) < 0;

      return UpdateCheckResult(
        updateAvailable: isUpdateAvailable,
        latestVersion: latestVersion,
        currentVersion: currentVersion,
      );
    } catch (e) {
      debugPrint('❌ Erreur vérification mise à jour: $e');
      return UpdateCheckResult(
        updateAvailable: false,
        currentVersion: 'Inconnu',
        error: e.toString(),
      );
    }
  }

  /// Comparer deux versions (retourne -1 si v1 < v2, 0 si égal, 1 si v1 > v2)
  int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final parts2 = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    // Normaliser la longueur des deux listes
    while (parts1.length < parts2.length) {
      parts1.add(0);
    }
    while (parts2.length < parts1.length) {
      parts2.add(0);
    }

    for (int i = 0; i < parts1.length; i++) {
      if (parts1[i] < parts2[i]) return -1;
      if (parts1[i] > parts2[i]) return 1;
    }
    return 0;
  }

  /// Télécharger et installer la mise à jour
  Future<bool> downloadAndInstallUpdate(
    VersionInfo versionInfo, {
    Function(double)? onProgress,
  }) async {
    if (!Platform.isAndroid) {
      debugPrint(
          '⚠️ Les mises à jour automatiques ne sont supportées que sur Android');
      return false;
    }

    try {
      // Demander les permissions nécessaires
      await Permission.storage.request();
      final installStatus = await Permission.requestInstallPackages.request();

      if (!installStatus.isGranted) {
        debugPrint('❌ Permission d\'installation refusée');
        return false;
      }

      // Obtenir le répertoire de téléchargement
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        debugPrint('❌ Impossible d\'accéder au stockage');
        return false;
      }

      final filePath = '${directory.path}/payrent_${versionInfo.version}.apk';
      final file = File(filePath);

      // Supprimer l'ancien fichier s'il existe
      if (await file.exists()) {
        await file.delete();
      }

      debugPrint('📥 Téléchargement de l\'APK vers: $filePath');

      // Télécharger l'APK
      await _dio.download(
        versionInfo.apkUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            onProgress?.call(progress);
            debugPrint(
                '📥 Progression: ${(progress * 100).toStringAsFixed(1)}%');
          }
        },
      );

      debugPrint('✅ Téléchargement terminé');

      // Installer l'APK
      final result = await OpenFilex.open(filePath);
      debugPrint('📲 Résultat installation: ${result.message}');

      return result.type == ResultType.done;
    } catch (e) {
      debugPrint('❌ Erreur téléchargement/installation: $e');
      return false;
    }
  }

  /// Afficher le dialogue de mise à jour
  static Future<bool?> showUpdateDialog(
    BuildContext context,
    VersionInfo versionInfo,
    String currentVersion,
  ) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpdateDialog(
        versionInfo: versionInfo,
        currentVersion: currentVersion,
      ),
    );
  }
}

/// Widget de dialogue de mise à jour
class UpdateDialog extends StatefulWidget {
  final VersionInfo versionInfo;
  final String currentVersion;

  const UpdateDialog({
    super.key,
    required this.versionInfo,
    required this.currentVersion,
  });

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isDownloading = false;
  double _progress = 0;
  String _statusMessage = '';
  final UpdateService _updateService = UpdateService();

  Future<void> _startUpdate() async {
    setState(() {
      _isDownloading = true;
      _statusMessage = 'Préparation du téléchargement...';
    });

    final success = await _updateService.downloadAndInstallUpdate(
      widget.versionInfo,
      onProgress: (progress) {
        setState(() {
          _progress = progress;
          _statusMessage =
              'Téléchargement: ${(progress * 100).toStringAsFixed(0)}%';
        });
      },
    );

    if (!success && mounted) {
      setState(() {
        _isDownloading = false;
        _statusMessage = 'Erreur lors de la mise à jour';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de télécharger la mise à jour'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.system_update, color: Colors.green.shade700),
          ),
          const SizedBox(width: 12),
          // Permettre au texte de se réduire/filmer si espace limité
          const Expanded(
            child: Text(
              'Mise à jour disponible',
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Versions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        'Actuelle',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'v${widget.currentVersion}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_forward, color: Colors.grey.shade400),
                  Column(
                    children: [
                      Text(
                        'Nouvelle',
                        style: TextStyle(
                          color: Colors.green.shade600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'v${widget.versionInfo.version}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Taille et date
            Row(
              children: [
                Icon(Icons.sd_storage, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  widget.versionInfo.size,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(width: 16),
                Icon(Icons.calendar_today,
                    size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  widget.versionInfo.releaseDate,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Changelog
            if (widget.versionInfo.changelog.isNotEmpty) ...[
              const Text(
                'Nouveautés:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...widget.versionInfo.changelog.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(child: Text(item)),
                    ],
                  ),
                ),
              ),
            ],

            // Progression du téléchargement
            if (_isDownloading) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.grey.shade200,
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.green.shade600),
              ),
              const SizedBox(height: 8),
              Text(
                _statusMessage,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: _isDownloading
          ? null
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Plus tard'),
              ),
              ElevatedButton.icon(
                onPressed: _startUpdate,
                icon: const Icon(Icons.download),
                label: const Text('Mettre à jour'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
    );
  }
}

