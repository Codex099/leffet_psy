import 'package:get/get.dart';
import '../utils/json_utils.dart';

class EmployeeModel {
 final dynamic id;
  final String nom;
  final String prenom;
  final String? telephone;
  final String username;
  final String role; // 'admin' | 'psychologue' | 'educatrice'
 final List<dynamic>? patientsAssignesIds;
  /// Permission de créer et assigner des tâches (accordée par l'admin)
  final bool peutCreerTaches;

  EmployeeModel({
    required this.id,
    required this.nom,
    required this.prenom,
    this.telephone,
    required this.username,
    required this.role,
    this.patientsAssignesIds,
    this.peutCreerTaches = false,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: parseId(json['id']),
     nom: json['nom'] as String? ?? '',
     prenom: json['prenom'] as String? ?? '',
     telephone: json['telephone'] as String?,
     username: json['username'] as String? ?? '',
     role: json['role'] as String? ?? 'psychologue',
      patientsAssignesIds: parseList(json['patients_assignes_ids'])
          ?.map((e) => parseId(e))
          .toList(),
      peutCreerTaches: json['peut_creer_taches'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      if (telephone != null) 'telephone': telephone,
      'username': username,
      'role': role,
      if (patientsAssignesIds != null) 'patients_assignes_ids': patientsAssignesIds,
      'peut_creer_taches': peutCreerTaches,
    };
  }


  String get fullName => '$prenom $nom';

 String get initials {
    final p = prenom.isNotEmpty ? prenom[0].toUpperCase() : '';
   final n = nom.isNotEmpty ? nom[0].toUpperCase() : '';
   final combined = '$p$n';
   if (combined.isNotEmpty) return combined;
    if (username.isNotEmpty) return username[0].toUpperCase();
    return 'U';
 }

  /// Première lettre du nom de famille (ou prénom/username) pour affichage avatar
  String get initialLetter {
    if (nom.isNotEmpty) return nom[0].toUpperCase();
    if (prenom.isNotEmpty) return prenom[0].toUpperCase();
    if (username.isNotEmpty) return username[0].toUpperCase();
    return 'U';
 }

  String get roleLabel {
    switch (role) {
      case 'admin':
       return 'Admin'.tr;
     case 'psychologue':
       return 'Psychologue'.tr;
     case 'educatrice':
       return 'Éducatrice'.tr;
     default:
        return role.tr;
    }
  }

  bool get isAdmin => role == 'admin';
 bool get isPsychologue => role == 'psychologue';
 bool get isEducatrice => role == 'educatrice';
  /// Vrai si l'employé peut créer et assigner des tâches à d'autres
  bool get canAssignTasks => isAdmin || peutCreerTaches;
}
