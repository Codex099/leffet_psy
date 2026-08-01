import '../utils/json_utils.dart';

class PatientStatutHistoriqueModel {
  final int id;
  final int patientId;
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
      id: parseInt(json['id']),
      patientId: parseInt(json['patient_id']),
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



