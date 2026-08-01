import '../utils/json_utils.dart';

class TacheModel {
  final int id;
  final String titre;
  final String? description;
  final int? assigneA;
  final int? creePar;
  final int? patientId;
  final int? etapePlanId;
  final String statut; // 'a_faire' | 'en_cours' | 'terminee'
  final String priorite; // 'haute' | 'normale' | 'basse'
  final String? dateEcheance;
  final Map<String, dynamic>? patient;
  final Map<String, dynamic>? assigneEmployee;

  TacheModel({
    required this.id,
    required this.titre,
    this.description,
    this.assigneA,
    this.creePar,
    this.patientId,
    this.etapePlanId,
    required this.statut,
    required this.priorite,
    this.dateEcheance,
    this.patient,
    this.assigneEmployee,
  });

  factory TacheModel.fromJson(Map<String, dynamic> json) {
    return TacheModel(
      id: parseInt(json['id']),
      titre: json['titre'] as String? ?? '',
      description: json['description'] as String?,
      assigneA: parseNullableInt(json['assigne_a']),
      creePar: parseNullableInt(json['cree_par']),
      patientId: parseNullableInt(json['patient_id']),
      etapePlanId: parseNullableInt(json['etape_plan_id']),
      statut: json['statut'] as String? ?? 'a_faire',
      priorite: json['priorite'] as String? ?? 'normale',
      dateEcheance: json['date_echeance'] as String?,
      patient: json['patient'] as Map<String, dynamic>?,
      assigneEmployee: json['assigne_employee'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titre': titre,
      if (description != null) 'description': description,
      if (assigneA != null) 'assigne_a': assigneA,
      if (patientId != null) 'patient_id': patientId,
      if (etapePlanId != null) 'etape_plan_id': etapePlanId,
      'statut': statut,
      'priorite': priorite,
      if (dateEcheance != null) 'date_echeance': dateEcheance,
    };
  }

  String get statutLabel {
    switch (statut) {
      case 'a_faire':
        return 'À faire';
      case 'en_cours':
        return 'En cours';
      case 'fait':
        return 'Fait';
      default:
        return statut;
    }
  }

  String get prioriteLabel {
    switch (priorite) {
      case 'haute':
        return 'Haute';
      case 'normale':
        return 'Normale';
      case 'basse':
        return 'Basse';
      default:
        return priorite;
    }
  }
}


