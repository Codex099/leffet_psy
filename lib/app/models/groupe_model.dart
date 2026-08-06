import '../utils/json_utils.dart';

class GroupeModel {
  final int id;
  final String nom;
  final String typePlanning; // 'fixe' | 'ponctuel'
  final String? description;
  final List<Map<String, dynamic>>? patients;
  final List<Map<String, dynamic>>? planningRecurrent;
  final List<int>? employeeIds;

  GroupeModel({
    required this.id,
    required this.nom,
    required this.typePlanning,
    this.description,
    this.patients,
    this.planningRecurrent,
    this.employeeIds,
  });

  factory GroupeModel.fromJson(Map<String, dynamic> json) {
    return GroupeModel(
      id: parseInt(json['id']),
      nom: json['nom'] as String? ?? '',
      typePlanning: json['type_planning'] as String? ?? 'ponctuel',
      description: json['description'] as String?,
      patients: (json['patients'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      planningRecurrent: (json['planning_recurrent'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      employeeIds: (json['employees'] as List<dynamic>?)
          ?.map((e) => parseInt(e is Map ? e['id'] : e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'type_planning': typePlanning,
      if (description != null) 'description': description,
    };
  }

  bool get isFixe => typePlanning == 'fixe';

  String get initials {
    final words = nom.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return nom.isNotEmpty ? nom[0].toUpperCase() : 'G';
  }
}

class GroupePlanningRecurrentModel {
  final int id;
  final int groupeId;
  final String jourSemaine;
  final String heureDebut;
  final String heureFin;

  GroupePlanningRecurrentModel({
    required this.id,
    required this.groupeId,
    required this.jourSemaine,
    required this.heureDebut,
    required this.heureFin,
  });

  factory GroupePlanningRecurrentModel.fromJson(Map<String, dynamic> json) {
    return GroupePlanningRecurrentModel(
      id: parseInt(json['id']),
      groupeId: parseInt(json['groupe_id']),
      jourSemaine: json['jour_semaine'] as String? ?? '',
      heureDebut: json['heure_debut'] as String? ?? '',
      heureFin: json['heure_fin'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jour_semaine': jourSemaine,
      'heure_debut': heureDebut,
      'heure_fin': heureFin,
    };
  }
}
