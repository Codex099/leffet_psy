import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_release_model.dart';

class AppUpdateService {
  static const String githubOwner = 'Codex099';
  static const String githubRepo = 'leffet_psy';

  /// Version de l'application (lue dynamiquement depuis pubspec.yaml via PackageInfo)
  static String currentAppVersion = '1.0.0';
  static String currentBuildNumber = '1';

  /// Initialise les informations de version depuis la plateforme / pubspec.yaml
  static Future<void> initVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      currentAppVersion = info.version;
      currentBuildNumber = info.buildNumber;
    } catch (e) {
      debugPrint('[AppUpdateService] Erreur PackageInfo : $e');
    }
  }

  static String get githubReleasesApiUrl =>
      'https://api.github.com/repos/$githubOwner/$githubRepo/releases/latest';

  static String get githubReleasesAllApiUrl =>
      'https://api.github.com/repos/$githubOwner/$githubRepo/releases';

  static String get githubReleasesWebUrl =>
      'https://github.com/$githubOwner/$githubRepo/releases';

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/vnd.github.v3+json',
        'User-Agent': 'PsyCare-App-Update-Client',
      },
    ),
  );

  /// Vérifie si une nouvelle version est disponible sur GitHub Releases
  Future<AppReleaseModel?> checkLatestRelease() async {
    try {
      final response = await _dio.get(githubReleasesApiUrl);
      if (response.statusCode == 200 && response.data is Map) {
        final release = AppReleaseModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
        return release;
      }
    } catch (e) {
      debugPrint('[AppUpdateService] Erreur lors de la vérification : $e');
      // Essayer avec la liste des releases au cas où 'latest' n'est pas encore tagué
      try {
        final listResponse = await _dio.get(githubReleasesAllApiUrl);
        if (listResponse.statusCode == 200 && listResponse.data is List && (listResponse.data as List).isNotEmpty) {
          final first = (listResponse.data as List).first;
          return AppReleaseModel.fromJson(Map<String, dynamic>.from(first as Map));
        }
      } catch (e2) {
        debugPrint('[AppUpdateService] Erreur fallback liste releases : $e2');
      }
    }
    return null;
  }

  /// Télécharge un asset (APK ou ZIP) avec callback de progression
  Future<File?> downloadAsset(
    ReleaseAssetModel asset, {
    required void Function(double progress, int receivedBytes, int totalBytes) onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      // Nettoyer le nom de fichier
      final safeName = asset.name.isNotEmpty
          ? asset.name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
          : 'update_psycare.apk';
      final savePath = '${tempDir.path}/$safeName';

      final file = File(savePath);
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {}
      }

      final downloadDio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(minutes: 10),
          followRedirects: true,
          maxRedirects: 5,
        ),
      );

      await downloadDio.download(
        asset.downloadUrl,
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = (received / total).clamp(0.0, 1.0);
            onProgress(progress, received, total);
          } else {
            onProgress(0.5, received, total);
          }
        },
      );

      return File(savePath);
    } catch (e) {
      debugPrint('[AppUpdateService] Erreur téléchargement asset : $e');
      rethrow;
    }
  }

  /// Déclenche l'installation du fichier téléchargé
  Future<bool> installUpdate(File file) async {
    try {
      if (!await file.exists()) {
        debugPrint('[AppUpdateService] Le fichier n\'existe pas : ${file.path}');
        return false;
      }

      final ext = file.path.toLowerCase().split('.').last;
      String? mimeType;
      if (ext == 'apk') {
        mimeType = 'application/vnd.android.package-archive';
      } else if (ext == 'zip') {
        mimeType = 'application/zip';
      }

      final result = await OpenFilex.open(
        file.path,
        type: mimeType,
      );

      debugPrint('[AppUpdateService] Résultat ouverture installateur : ${result.type} - ${result.message}');
      return result.type == ResultType.done;
    } catch (e) {
      debugPrint('[AppUpdateService] Erreur lors de l\'installation : $e');
      return false;
    }
  }

  /// Ouvre la page GitHub Release dans le navigateur externe
  Future<void> openReleaseInBrowser(String url) async {
    final targetUrl = url.isNotEmpty ? url : githubReleasesWebUrl;
    final uri = Uri.tryParse(targetUrl);
    if (uri != null) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('[AppUpdateService] Impossible d\'ouvrir l\'URL : $e');
      }
    }
  }
}

