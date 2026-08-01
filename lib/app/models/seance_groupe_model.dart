import '../utils/json_utils.dart';

class SeanceGroupeModel {
  final int id;
  final int groupeId;
  final int? employeId;
  final String date;
  final String heureDebut;
  final String heureFin;
  final String statut; // 'planifiee' | 'realisee' | 'annulee'
  final Map<String, dynamic>? groupe;
  final Map<String, dynamic>? employe;
  final List<SeanceGroupeParticipantModel>? participants;

  SeanceGroupeModel({
    required this.id,
    required this.groupeId,
    this.employeId,
    required this.date,
    required this.heureDebut,
    required this.heureFin,
    required this.statut,
    this.groupe,
    this.employe,
    this.participants,
  });

  factory SeanceGroupeModel.fromJson(Map<String, dynamic> json) {
    return SeanceGroupeModel(
      id: parseInt(json['id']),
      groupeId: parseInt(json['groupe_id']),
      employeId: parseNullableInt(json['employe_id']),
      date: json['date'] as String? ?? '',
      heureDebut: json['heure_debut'] as String? ?? '',
      heureFin: json['heure_fin'] as String? ?? '',
      statut: json['statut'] as String? ?? 'planifiee',
      groupe: json['groupe'] as Map<String, dynamic>?,
      employe: json['employe'] as Map<String, dynamic>?,
      participants: (json['participants'] as List<dynamic>?)
          ?.map((e) => SeanceGroupeParticipantModel.fromJson(
              e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupe_id': groupeId,
      if (employeId != null) 'employe_id': employeId,
      'date': date,
      'heure_debut': heureDebut,
      'heure_fin': heureFin,
      'statut': statut,
    };
  }

  String get groupeName => groupe?['nom'] as String? ?? '';
  bool get isPlanifiee => statut == 'planifiee';
  bool get isRealisee => statut == 'realisee';
}

class SeanceGroupeParticipantModel {
  final int seanceGroupeId;
  final int patientId;
  final String? statutPresence; // 'present' | 'absent'
  final String? descriptionEtat;
  final Map<String, dynamic>? reponsesQuestionnaire;
  final String? redigePar;
  final List<String>? medias;
  final Map<String, dynamic>? patient;

  SeanceGroupeParticipantModel({
    required this.seanceGroupeId,
    required this.patientId,
    this.statutPresence,
    this.descriptionEtat,
    this.reponsesQuestionnaire,
    this.redigePar,
    this.medias,
    this.patient,
  });

  factory SeanceGroupeParticipantModel.fromJson(Map<String, dynamic> json) {
    return SeanceGroupeParticipantModel(
      seanceGroupeId: parseInt(json['seance_groupe_id']),
      patientId: parseInt(json['patient_id']),
      statutPresence: json['statut_presence'] as String?,
      descriptionEtat: json['description_etat'] as String?,
      reponsesQuestionnaire:
          json['reponses_questionnaire'] as Map<String, dynamic>?,
      redigePar: json['redige_par'] as String?,
      medias: (json['medias'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      patient: json['patient'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (statutPresence != null) 'statut_presence': statutPresence,
      if (descriptionEtat != null) 'description_etat': descriptionEtat,
      if (medias != null) 'medias': medias,
    };
  }

  bool get isPresent => statutPresence == 'present';

  String get patientFullName {
    if (patient == null) return '';
    return '${patient!['prenom'] ?? ''} ${patient!['nom'] ?? ''}'.trim();
  }

  String get patientInitials {
    final name = patientFullName;
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String? get patientPhoto => patient?['photo'] as String?;
}
