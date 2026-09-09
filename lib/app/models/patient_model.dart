import 'package:get/get.dart';
import '../config/api_config.dart';
import '../utils/json_utils.dart';

class PatientModel {
 final dynamic id;
  final String nom;
  final String prenom;
  final String? dateNaissance;
  final String? photo;
  final int? nombreFreresSoeurs;
  final int? ordreNaissance;
  final bool estActif;
  final String? dateDesactivation;
  final String? dateReactivation;
  final String? sexe;
  final List<Map<String, dynamic>>? parents;
  final List<Map<String, dynamic>>? employesAssignes;

  PatientModel({
    required this.id,
    required this.nom,
    required this.prenom,
    this.dateNaissance,
    this.photo,
    this.nombreFreresSoeurs,
    this.ordreNaissance,
    this.estActif = true,
    this.dateDesactivation,
    this.dateReactivation,
    this.sexe,
    this.parents,
    this.employesAssignes,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: parseId(json['id']),
     nom: json['nom'] as String? ?? '',
     prenom: json['prenom'] as String? ?? '',
      dateNaissance: json['date_naissance'] as String?,
      photo: (json['photo'] ??
              json['photo_url'] ??
              json['photoUrl'] ??
              json['avatar'] ??
              json['avatar_url'] ??
              json['image'] ??
              json['imageUrl']) as String?,
      nombreFreresSoeurs: parseNullableInt(json['nombre_freres_soeurs']),
     ordreNaissance: parseNullableInt(json['ordre_naissance']),
     estActif: json['est_actif'] as bool? ?? true,
     dateDesactivation: json['date_desactivation'] as String?,
     dateReactivation: json['date_reactivation'] as String?,
     sexe: json['sexe'] as String?,
      parents: parseList(json['parents'])
          ?.map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{})
          .toList(),
      employesAssignes: parseList(json['employes_assignes'])
          ?.map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{})
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      if (dateNaissance != null) 'date_naissance': dateNaissance,
      if (photo != null) 'photo': photo,
      if (photo != null) 'photo_url': photo,
      if (nombreFreresSoeurs != null)
        'nombre_freres_soeurs': nombreFreresSoeurs,
      if (ordreNaissance != null) 'ordre_naissance': ordreNaissance,
      'est_actif': estActif,
      if (dateDesactivation != null) 'date_desactivation': dateDesactivation,
      if (dateReactivation != null) 'date_reactivation': dateReactivation,
      if (sexe != null) 'sexe': sexe,
    };
  }


  String get fullName => '$prenom $nom';

 bool get isGarcon {
    if (sexe == null || sexe!.trim().isEmpty) return false;
    final s = sexe!.trim().toLowerCase();
    return s == 'masculin' ||
       s == 'garçon' ||
       s == 'garcon' ||
       s == 'm' ||
       s == 'male' ||
       s.startsWith('masc') ||
       s.startsWith('garç') ||
       s.startsWith('garc');
 }

  bool get isFille {
    if (sexe == null || sexe!.trim().isEmpty) return false;
    final s = sexe!.trim().toLowerCase();
    return s == 'feminin' ||
       s == 'féminin' ||
       s == 'fille' ||
       s == 'f' ||
       s == 'female' ||
       s.startsWith('fém') ||
       s.startsWith('fem') ||
       s.startsWith('fill');
 }

  String get sexeLabel {
    if (isGarcon) return 'Garçon'.tr;
   if (isFille) return 'Fille'.tr;
   return (sexe ?? '').tr;
 }

  String get backendSexe {
    if (isFille) return 'feminin';
   if (isGarcon) return 'masculin';
   return sexe ?? 'masculin';
 }

  String get initials {
    final p = prenom.isNotEmpty ? prenom[0].toUpperCase() : '';
   final n = nom.isNotEmpty ? nom[0].toUpperCase() : '';
   return '$p$n';
 }

  int? get age {
    if (dateNaissance == null) return null;
    try {
      final dob = DateTime.parse(dateNaissance!);
      final now = DateTime.now();
      int calculatedAge = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        calculatedAge--;
      }
      return calculatedAge;
    } catch (_) {
      return null;
    }
  }

  bool get actif => estActif;
  String? get photoUrl {
    if (photo == null || photo!.trim().isEmpty) return null;
    return ApiConfig.resolveMediaUrl(photo);
  }

  String get statutLabel => estActif ? 'Actif'.tr : 'Inactif';

 String? get ageFormatted {
    final a = age;
    if (a == null) return null;
    final lang = Get.locale?.languageCode ?? 'fr';
   if (lang == 'ar') {
     if (a >= 3 && a <= 10) {
        return '$a سنوات';
     } else {
        return '$a سنة';
     }
    }
    return '$a ans';
  }

  PatientModel copyWith({
    dynamic id,
    String? nom,
    String? prenom,
    String? dateNaissance,
    String? photo,
    int? nombreFreresSoeurs,
    int? ordreNaissance,
    bool? estActif,
    String? dateDesactivation,
    String? dateReactivation,
    String? sexe,
    List<Map<String, dynamic>>? parents,
    List<Map<String, dynamic>>? employesAssignes,
  }) {
    return PatientModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      photo: photo ?? this.photo,
      nombreFreresSoeurs: nombreFreresSoeurs ?? this.nombreFreresSoeurs,
      ordreNaissance: ordreNaissance ?? this.ordreNaissance,
      estActif: estActif ?? this.estActif,
      dateDesactivation: dateDesactivation ?? this.dateDesactivation,
      dateReactivation: dateReactivation ?? this.dateReactivation,
      sexe: sexe ?? this.sexe,
      parents: parents ?? this.parents,
      employesAssignes: employesAssignes ?? this.employesAssignes,
    );
  }
}
