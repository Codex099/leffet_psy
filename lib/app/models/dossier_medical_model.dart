import '../utils/json_utils.dart';

class DossierMedicalModel {
  final int id;
  final int patientId;
  final String? antecedentsMedicaux;
  final String? medicamentsPris;
  final String? dateCas;
  final String? naissance;
  final String? dateNaissance;
  final int? nombreFreresSoeurs;
  final int? rangFratrie;
  final String? developpementPsychomoteur;
  final String? comportementAuditif;
  final String? developpementLangagier;
  final String? adaptationSociale;
  final String? autonomie;
  final String? aspectSanitaire;
  final String? stadeScolarisation;
  final String? misAJourPar;
  final String? dateMaj;

  const DossierMedicalModel({
    required this.id,
    required this.patientId,
    this.antecedentsMedicaux,
    this.medicamentsPris,
    this.dateCas,
    this.naissance,
    this.dateNaissance,
    this.nombreFreresSoeurs,
    this.rangFratrie,
    this.developpementPsychomoteur,
    this.comportementAuditif,
    this.developpementLangagier,
    this.adaptationSociale,
    this.autonomie,
    this.aspectSanitaire,
    this.stadeScolarisation,
    this.misAJourPar,
    this.dateMaj,
  });

  factory DossierMedicalModel.fromJson(Map<String, dynamic> json) {
    return DossierMedicalModel(
      id: parseInt(json['id']),
      patientId: parseInt(json['patient_id']),
      antecedentsMedicaux: json['antecedents_medicaux'] as String?,
      medicamentsPris: json['medicaments_pris'] as String?,
      dateCas: json['date_cas'] as String?,
      naissance: json['naissance'] as String?,
      dateNaissance: json['date_naissance'] as String?,
      nombreFreresSoeurs: parseNullableInt(json['nombre_freres_soeurs']),
      rangFratrie: parseNullableInt(json['rang_fratrie']),
      developpementPsychomoteur: json['developpement_psychomoteur'] as String?,
      comportementAuditif: json['comportement_auditif'] as String?,
      developpementLangagier: json['developpement_langagier'] as String?,
      adaptationSociale: json['adaptation_sociale'] as String?,
      autonomie: json['autonomie'] as String?,
      aspectSanitaire: json['aspect_sanitaire'] as String?,
      stadeScolarisation: json['stade_scolarisation'] as String?,
      misAJourPar: json['mis_a_jour_par'] as String?,
      dateMaj: json['date_maj'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'antecedents_medicaux': antecedentsMedicaux,
        'medicaments_pris': medicamentsPris,
        'date_cas': dateCas,
        'naissance': naissance,
        'date_naissance': dateNaissance,
        'nombre_freres_soeurs': nombreFreresSoeurs,
        'rang_fratrie': rangFratrie,
        'developpement_psychomoteur': developpementPsychomoteur,
        'comportement_auditif': comportementAuditif,
        'developpement_langagier': developpementLangagier,
        'adaptation_sociale': adaptationSociale,
        'autonomie': autonomie,
        'aspect_sanitaire': aspectSanitaire,
        'stade_scolarisation': stadeScolarisation,
        'mis_a_jour_par': misAJourPar,
        'date_maj': dateMaj,
      };
}
