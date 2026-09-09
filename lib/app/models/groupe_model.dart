import '../utils/json_utils.dart';

class GroupeModel {
 final dynamic id;
  final String nom;
  final String typePlanning; // 'fixe' | 'ponctuel'
 final String? description;
  final List<Map<String, dynamic>>? patients;
  final List<Map<String, dynamic>>? planningRecurrent;
  final List<dynamic>? employeeIds;

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
    final Set<dynamic> ids = {};

    void extractIds(dynamic raw) {
      if (raw == null) return;
      final parsedList = parseList(raw);
      if (parsedList != null) {
        for (final item in parsedList) {
          if (item is Map) {
            final parsed = parseId(item['id'] ?? item['employe_id'] ?? item['employee_id']);
            if (parsed != null) ids.add(parsed);
          } else {
            final parsed = parseId(item);
            if (parsed != null) ids.add(parsed);
          }
        }
      } else if (raw is Map) {
        final parsed = parseId(raw['id'] ?? raw['employe_id'] ?? raw['employee_id']);
        if (parsed != null) ids.add(parsed);
      } else {
        final parsed = parseId(raw);
        if (parsed != null) ids.add(parsed);
      }
    }

    extractIds(json['employees']);
    extractIds(json['employes']);
    extractIds(json['employee_ids']);
    extractIds(json['employe_ids']);
    extractIds(json['intervenants']);
    extractIds(json['intervenant_ids']);
    extractIds(json['employe_id']);
    extractIds(json['employee_id']);

    final planning = parseList(json['planning_recurrent']);
    if (planning != null) {
      for (final slot in planning) {
        if (slot is Map) {
          extractIds(slot['employe_id']);
          extractIds(slot['employee_id']);
          extractIds(slot['employe_ids']);
          extractIds(slot['employee_ids']);
          extractIds(slot['employees']);
          extractIds(slot['employes']);
        }
      }
    }

    final seances = parseList(json['seances'] ?? json['seances_groupe']);
    if (seances != null) {
      for (final s in seances) {
        if (s is Map) {
          extractIds(s['employe_id']);
          extractIds(s['employee_id']);
          extractIds(s['employe_ids']);
          extractIds(s['employee_ids']);
        }
      }
    }

    return GroupeModel(
      id: parseId(json['id']),
      nom: json['nom'] as String? ?? '',
      typePlanning: json['type_planning'] as String? ?? 'ponctuel',
      description: json['description'] as String?,
      patients: parseList(json['patients'])
          ?.map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{})
          .toList(),
      planningRecurrent: parseList(json['planning_recurrent'])
          ?.map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{})
          .toList(),
      employeeIds: ids.isNotEmpty ? ids.toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'type_planning': typePlanning,
      if (description != null) 'description': description,
      if (employeeIds != null && employeeIds!.isNotEmpty) 'employee_ids': employeeIds,
    };
  }

  /// Vérifie si un employé est assigné à ce groupe
  bool isEmployeeAssigned(dynamic employeeId) {
    if (employeeId == null) return false;
    final target = employeeId.toString().trim();
    if (employeeIds != null) {
      for (final id in employeeIds!) {
        if (id != null && id.toString().trim() == target) return true;
      }
    }
    return false;
  }

  bool get isFixe => typePlanning == 'fixe';
 bool get estFixe => isFixe;
  String get typeLabel => isFixe ? 'Fixe' : 'Ponctuel';
 int get membresCount {
    if (patients == null || patients!.isEmpty) return 0;
    final seen = <String>{};
    for (final p in patients!) {
      final pid = parseId(p['id'] ?? p['patient_id'])?.toString();
     if (pid != null) seen.add(pid);
    }
    return seen.isNotEmpty ? seen.length : patients!.length;
  }

  String get initials {
    final words = nom.split(' ');
   if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
   }
    return nom.isNotEmpty ? nom[0].toUpperCase() : 'G';
 }
}

class GroupePlanningRecurrentModel {
  final dynamic id;
  final dynamic groupeId;
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
      id: parseId(json['id']),
     groupeId: parseId(json['groupe_id']),
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
