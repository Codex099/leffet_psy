import '../utils/json_utils.dart';

class PatientStatutHistoriqueModel {
 final dynamic id;
  final dynamic patientId;
  final String statut; // 'actif' | 'inactif'
 final String dateChangement;
  final String? changePar;
  final String? noteDegradation;

  PatientStatutHistoriqueModel({
    required this.id,
    required this.patientId,
    required this.statut,
    required this.dateChangement,
    this.changePar,
    this.noteDegradation,
  });

  factory PatientStatutHistoriqueModel.fromJson(Map<String, dynamic> json) {
    return PatientStatutHistoriqueModel(
      id: parseId(json['id']),
     patientId: parseId(json['patient_id']),
     statut: json['statut'] as String? ?? 'actif',
     dateChangement: json['date_changement'] as String? ?? '',
     changePar: json['change_par'] as String?,
     noteDegradation: json['note_degradation'] as String?,
   );
  }

  Map<String, dynamic> toJson() {
    return {
      'note_degradation': noteDegradation,
   };
  }

  bool get isActif => statut == 'actif';
}



