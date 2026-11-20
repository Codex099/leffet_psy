import 'dart:io';

class ReleaseAssetModel {
  final int id;
  final String name;
  final String downloadUrl;
  final int size; // en octets
  final String contentType;

  ReleaseAssetModel({
    required this.id,
    required this.name,
    required this.downloadUrl,
    required this.size,
    required this.contentType,
  });

  factory ReleaseAssetModel.fromJson(Map<String, dynamic> json) {
    return ReleaseAssetModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      downloadUrl: json['browser_download_url'] as String? ?? '',
      size: json['size'] as int? ?? 0,
      contentType: json['content_type'] as String? ?? '',
    );
  }

  bool get isApk => name.toLowerCase().endsWith('.apk');
  bool get isZip => name.toLowerCase().endsWith('.zip');

  String get formattedSize {
    if (size <= 0) return '';
    if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} Ko';
    }
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} Mo';
  }
}

class AppReleaseModel {
  final String tagName;
  final String title;
  final String body;
  final DateTime? publishedAt;
  final String htmlUrl;
  final List<ReleaseAssetModel> assets;
  final String? zipballUrl;

  AppReleaseModel({
    required this.tagName,
    required this.title,
    required this.body,
    this.publishedAt,
    required this.htmlUrl,
    required this.assets,
    this.zipballUrl,
  });

  factory AppReleaseModel.fromJson(Map<String, dynamic> json) {
    final rawAssets = json['assets'] as List<dynamic>? ?? [];
    final parsedAssets = rawAssets
        .map((e) => ReleaseAssetModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    DateTime? pubDate;
    if (json['published_at'] != null) {
      try {
        pubDate = DateTime.parse(json['published_at'].toString());
      } catch (_) {}
    }

    return AppReleaseModel(
      tagName: json['tag_name'] as String? ?? '',
      title: json['name'] as String? ?? json['tag_name'] as String? ?? 'Mise à jour',
      body: json['body'] as String? ?? '',
      publishedAt: pubDate,
      htmlUrl: json['html_url'] as String? ?? '',
      assets: parsedAssets,
      zipballUrl: json['zipball_url'] as String?,
    );
  }

  /// Retourne le premier asset APK trouvé, ou null
  ReleaseAssetModel? get apkAsset {
    try {
      return assets.firstWhere((a) => a.isApk);
    } catch (_) {
      return null;
    }
  }

  /// Retourne le premier asset ZIP trouvé (ou le zipball github), ou null
  ReleaseAssetModel? get zipAsset {
    try {
      return assets.firstWhere((a) => a.isZip);
    } catch (_) {
      if (zipballUrl != null && zipballUrl!.isNotEmpty) {
        return ReleaseAssetModel(
          id: -1,
          name: '$cleanVersion.zip',
          downloadUrl: zipballUrl!,
          size: 0,
          contentType: 'application/zip',
        );
      }
      return null;
    }
  }

  /// Retourne l'asset recommandé selon la plateforme
  ReleaseAssetModel? get bestAsset {
    if (Platform.isAndroid) {
      return apkAsset ?? zipAsset ?? (assets.isNotEmpty ? assets.first : null);
    }
    return zipAsset ?? apkAsset ?? (assets.isNotEmpty ? assets.first : null);
  }

  /// Version nettoyée (enlève le 'v' initial, ex: "v1.2.3" -> "1.2.3")
  String get cleanVersion {
    var v = tagName.trim();
    if (v.toLowerCase().startsWith('v')) {
      v = v.substring(1).trim();
    }
    return v;
  }

  /// Compare si cette release est plus récente que [currentVersionStr]
  bool isNewerThan(String currentVersionStr) {
    return compareVersions(cleanVersion, currentVersionStr) > 0;
  }

  /// Retourne 1 si v1 > v2, -1 si v1 < v2, 0 si égal
  static int compareVersions(String v1, String v2) {
    var clean1 = v1.toLowerCase().replaceFirst('v', '').trim();
    var clean2 = v2.toLowerCase().replaceFirst('v', '').trim();

    // Enlever les suffixes de build éventuels (ex: 1.0.0+1 -> 1.0.0)
    clean1 = clean1.split('+').first.split('-').first;
    clean2 = clean2.split('+').first.split('-').first;

    final parts1 = clean1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final parts2 = clean2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final maxLen = parts1.length > parts2.length ? parts1.length : parts2.length;
    for (int i = 0; i < maxLen; i++) {
      final num1 = i < parts1.length ? parts1[i] : 0;
      final num2 = i < parts2.length ? parts2[i] : 0;
      if (num1 > num2) return 1;
      if (num1 < num2) return -1;
    }
    return 0;
  }
}

