import 'package:get/get.dart';
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
              e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}))
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

  bool get isActif => statut == 'actif';
 bool get isSuspendu => statut == 'suspendu';
 bool get isArchive => statut == 'archive';

 int get totalEtapes => etapes?.length ?? 0;

  int get etapesTerminees =>
      etapes?.where((e) => e.statut == 'fait' || e.statut == 'termine').length ?? 0;

 double get progression =>
      totalEtapes == 0 ? 0.0 : etapesTerminees / totalEtapes;
}

class EtapePlanTherapeutiqueModel {
  final dynamic id;
  final dynamic planId;
  final String titre;
  final String? description;
  final int ordre;
  final String statut; // 'a_faire' | 'en_cours' | 'fait'
 final String? dateFin;

  EtapePlanTherapeutiqueModel({
    required this.id,
    required this.planId,
    required this.titre,
    this.description,
    this.ordre = 0,
    this.statut = 'a_faire',
   this.dateFin,
  });

  factory EtapePlanTherapeutiqueModel.fromJson(Map<String, dynamic> json) {
    return EtapePlanTherapeutiqueModel(
      id: parseId(json['id']),
     planId: parseId(json['plan_id']),
     titre: json['titre'] as String? ?? '',
     description: json['description'] as String?,
     ordre: parseInt(json['ordre']),
     statut: json['statut'] as String? ?? 'a_faire',
     dateFin: json['date_fin'] as String?,
   );
  }

  Map<String, dynamic> toJson() {
    return {
      'titre': titre,
     if (description != null) 'description': description,
     'ordre': ordre,
     'statut': statut,
     if (dateFin != null) 'date_fin': dateFin,
   };
  }

  bool get isFait => statut == 'fait' || statut == 'termine';
 bool get isTermine => isFait;
  bool get isEnCours => statut == 'en_cours';
 bool get isAFaire => statut == 'a_faire';

 String get statutLabel {
    switch (statut) {
      case 'a_faire':
       return 'À faire'.tr;
     case 'en_cours':
       return 'En cours'.tr;
     case 'fait':
     case 'termine':
       return 'Terminé'.tr;
     default:
        return statut;
    }
  }
}

class ObjectifEtapeModel {
  final dynamic id;
  final dynamic etapeId;
  final String description;
  final bool atteint;

  ObjectifEtapeModel({
    required this.id,
    required this.etapeId,
    required this.description,
    this.atteint = false,
  });

  factory ObjectifEtapeModel.fromJson(Map<String, dynamic> json) {
    return ObjectifEtapeModel(
      id: parseId(json['id']),
     etapeId: parseId(json['etape_id']),
     description: json['description'] as String? ?? '',
     atteint: json['atteint'] as bool? ?? false,
   );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
     'atteint': atteint,
   };
  }
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
         ?.map((e) => e.toString())
          .toList(),
      dateCreation: json['date_creation'] as String?,
     auteur: json['auteur'] is Map ? Map<String, dynamic>.from(json['auteur'] as Map) : null,
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
