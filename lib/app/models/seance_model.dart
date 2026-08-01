import '../utils/json_utils.dart';

class SeanceModel {
  final int id;
  final int patientId;
  final List<int> employeIds;
  final String date;
  final String heureDebut;
  final String heureFin;
  final String statut; // 'planifiee' | 'realisee' | 'annulee'
  final String? motifStatut;
  final String? statutPresence; // 'present' | 'absent'
  final String? descriptionEtat;
  final Map<String, dynamic>? reponsesQuestionnaire;
  final List<String>? medias;
  final Map<String, dynamic>? patient;
  final Map<String, dynamic>? employe;

  SeanceModel({
    required this.id,
    required this.patientId,
    required this.employeIds,
    required this.date,
    required this.heureDebut,
    required this.heureFin,
    required this.statut,
    this.motifStatut,
    this.statutPresence,
    this.descriptionEtat,
    this.reponsesQuestionnaire,
    this.medias,
    this.patient,
    this.employe,
  });

  factory SeanceModel.fromJson(Map<String, dynamic> json) {
    return SeanceModel(
      id: parseInt(json['id']),
      patientId: parseInt(json['patient_id']),
      employeIds: (json['employe_ids'] as List<dynamic>?)
              ?.map((e) => parseInt(e))
              .toList() ??
          [],
      date: json['date'] as String? ?? '',
      heureDebut: json['heure_debut'] as String? ?? '',
      heureFin: json['heure_fin'] as String? ?? '',
      statut: json['statut'] as String? ?? 'planifiee',
      motifStatut: json['motif_statut'] as String?,
      statutPresence: json['statut_presence'] as String?,
      descriptionEtat: json['description_etat'] as String?,
      reponsesQuestionnaire:
          json['reponses_questionnaire'] as Map<String, dynamic>?,
      medias: (json['medias'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      patient: json['patient'] as Map<String, dynamic>?,
      employe: json['employe'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'employe_ids': employeIds,
      'date': date,
      'heure_debut': heureDebut,
      'heure_fin': heureFin,
      'statut': statut,
      if (motifStatut != null) 'motif_statut': motifStatut,
      if (statutPresence != null) 'statut_presence': statutPresence,
      if (descriptionEtat != null) 'description_etat': descriptionEtat,
      if (medias != null) 'medias': medias,
    };
  }

  String get patientFullName {
    if (patient == null) return '';
    return '${patient!['prenom'] ?? ''} ${patient!['nom'] ?? ''}'.trim();
  }

  String get duree {
    try {
      final debut = _parseTime(heureDebut);
      final fin = _parseTime(heureFin);
      final diff = fin.hour * 60 + fin.minute - debut.hour * 60 - debut.minute;
      return '$diff min';
    } catch (_) {
      return '';
    }
  }

  DateTime _parseTime(String time) {
    final parts = time.split(':');
    return DateTime(2000, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
  }

  bool get isPresent => statutPresence == 'present';
  bool get isPlanifiee => statut == 'planifiee';
  bool get isRealisee => statut == 'realisee';
  bool get isAnnulee => statut == 'annulee';
}

class PatientPlanningRecurrentModel {
  final int id;
  final int patientId;
  final List<String> joursSemaine;
  final String heureDebut;
  final String heureFin;
  final String? dateDebut;
  final String? dateFin;
  final int? employeId;
  final String? modeGeneration; // 'auto' | 'manuel'
  final int? horizonJours;

  PatientPlanningRecurrentModel({
    required this.id,
    required this.patientId,
    required this.joursSemaine,
    required this.heureDebut,
    required this.heureFin,
    this.dateDebut,
    this.dateFin,
    this.employeId,
    this.modeGeneration,
    this.horizonJours,
  });

  factory PatientPlanningRecurrentModel.fromJson(Map<String, dynamic> json) {
    return PatientPlanningRecurrentModel(
      id: parseInt(json['id']),
      patientId: parseInt(json['patient_id']),
      joursSemaine: (json['jours_semaine'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      heureDebut: json['heure_debut'] as String? ?? '',
      heureFin: json['heure_fin'] as String? ?? '',
      dateDebut: json['date_debut'] as String?,
      dateFin: json['date_fin'] as String?,
      employeId: parseNullableInt(json['employe_id']),
      modeGeneration: json['mode_generation'] as String?,
      horizonJours: parseNullableInt(json['horizon_jours']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jours_semaine': joursSemaine,
      'heure_debut': heureDebut,
      'heure_fin': heureFin,
      if (dateDebut != null) 'date_debut': dateDebut,
      if (dateFin != null) 'date_fin': dateFin,
      if (employeId != null) 'employe_id': employeId,
      if (modeGeneration != null) 'mode_generation': modeGeneration,
      if (horizonJours != null) 'horizon_jours': horizonJours,
    };
  }
}
