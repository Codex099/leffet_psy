import '../utils/json_utils.dart';

class PlanTherapeutiqueModel {
  final dynamic id;
  final dynamic patientId;
  final String titre;
  final String statut; // 'actif' | 'archive' | 'termine'
  final String? dateDebut;
  final String? dateFin;
  final int? creePar;
  final List<EtapePlanTherapeutiqueModel>? etapes;

  PlanTherapeutiqueModel({
    required this.id,
    required this.patientId,
    required this.titre,
    required this.statut,
    this.dateDebut,
    this.dateFin,
    this.creePar,
    this.etapes,
  });

  factory PlanTherapeutiqueModel.fromJson(Map<String, dynamic> json) {
    return PlanTherapeutiqueModel(
      id: parseId(json['id']),
      patientId: parseId(json['patient_id']),
      titre: json['titre'] as String? ?? '',
      statut: json['statut'] as String? ?? 'actif',
      dateDebut: json['date_debut'] as String?,
      dateFin: json['date_fin'] as String?,
      creePar: parseNullableInt(json['cree_par']),
      etapes: (json['etapes'] as List<dynamic>?)
          ?.map((e) => EtapePlanTherapeutiqueModel.fromJson(
              e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titre': titre,
      'statut': statut,
      if (dateDebut != null) 'date_debut': dateDebut,
      if (dateFin != null) 'date_fin': dateFin,
    };
  }

  int get totalEtapes => etapes?.length ?? 0;

  int get etapesTerminees =>
      etapes?.where((e) => e.statut == 'termine').length ?? 0;

  double get progression =>
      totalEtapes == 0 ? 0.0 : etapesTerminees / totalEtapes;
}

class EtapePlanTherapeutiqueModel {
  final dynamic id;
  final dynamic planId;
  final String titre;
  final String? description;
  final String statut; // 'a_faire' | 'en_cours' | 'termine'
  final int ordre;
  final int? creePar;

  EtapePlanTherapeutiqueModel({
    required this.id,
    required this.planId,
    required this.titre,
    this.description,
    required this.statut,
    required this.ordre,
    this.creePar,
  });

  factory EtapePlanTherapeutiqueModel.fromJson(Map<String, dynamic> json) {
    return EtapePlanTherapeutiqueModel(
      id: parseId(json['id']),
      planId: parseId(json['plan_id']),
      titre: json['titre'] as String? ?? '',
      description: json['description'] as String?,
      statut: json['statut'] as String? ?? 'a_faire',
      ordre: parseInt(json['ordre']),
      creePar: parseNullableInt(json['cree_par']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titre': titre,
      if (description != null) 'description': description,
      'statut': statut,
      'ordre': ordre,
    };
  }

  String get statutLabel {
    switch (statut) {
      case 'a_faire':
        return 'À faire';
      case 'en_cours':
        return 'En cours';
      case 'termine':
        return 'Terminé';
      default:
        return statut;
    }
  }

  bool get isTermine => statut == 'termine';
  bool get isEnCours => statut == 'en_cours';
  bool get isAFaire => statut == 'a_faire';
}

class NotePatientModel {
  final dynamic id;
  final dynamic patientId;
  final dynamic employeId;
  final dynamic seanceId;
  final dynamic seanceGroupeId;
  final String contenu;
  final List<String>? medias;
  final String? dateCreation;
  final Map<String, dynamic>? auteur;

  NotePatientModel({
    required this.id,
    required this.patientId,
    this.employeId,
    this.seanceId,
    this.seanceGroupeId,
    required this.contenu,
    this.medias,
    this.dateCreation,
    this.auteur,
  });

  factory NotePatientModel.fromJson(Map<String, dynamic> json) {
    return NotePatientModel(
      id: parseId(json['id']),
      patientId: parseId(json['patient_id']),
      employeId: parseId(json['employe_id']),
      seanceId: parseId(json['seance_id']),
      seanceGroupeId: parseId(json['seance_groupe_id']),
      contenu: json['contenu'] as String? ?? '',
      medias: (json['medias'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      dateCreation: json['date_creation'] as String?,
      auteur: json['auteur'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contenu': contenu,
      if (seanceId != null) 'seance_id': seanceId,
      if (seanceGroupeId != null) 'seance_groupe_id': seanceGroupeId,
      if (medias != null) 'medias': medias,
    };
  }

  String get auteurNom {
    if (auteur == null) return '';
    return '${auteur!['prenom'] ?? ''} ${auteur!['nom'] ?? ''}'.trim();
  }
}
