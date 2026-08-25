import '../utils/json_utils.dart';

class ParentModel {
  final dynamic id;
  final String nom;
  final String prenom;
  final String? telephone;
  final String? etatCivil;
  final String? adresse;

  ParentModel({
    required this.id,
    required this.nom,
    required this.prenom,
    this.telephone,
    this.etatCivil,
    this.adresse,
  });

  factory ParentModel.fromJson(Map<String, dynamic> json) {
    return ParentModel(
      id: parseId(json['id']),
      nom: json['nom'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      telephone: json['telephone'] as String?,
      etatCivil: json['etat_civil'] as String?,
      adresse: json['adresse'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'prenom': prenom,
      if (telephone != null) 'telephone': telephone,
      if (etatCivil != null) 'etat_civil': etatCivil,
      if (adresse != null) 'adresse': adresse,
    };
  }

  String get fullName => '$prenom $nom';

  String get initials {
    final p = prenom.isNotEmpty ? prenom[0].toUpperCase() : '';
    final n = nom.isNotEmpty ? nom[0].toUpperCase() : '';
    return '$p$n';
  }

  ParentModel copyWith({
    dynamic id,
    String? nom,
    String? prenom,
    String? telephone,
    String? etatCivil,
    String? adresse,
  }) {
    return ParentModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      telephone: telephone ?? this.telephone,
      etatCivil: etatCivil ?? this.etatCivil,
      adresse: adresse ?? this.adresse,
    );
  }
}

class PatientParentModel {
  final dynamic patientId;
  final dynamic parentId;
  final String role; // 'pere' | 'mere' | 'tuteur'
  final ParentModel? parent;

  PatientParentModel({
    required this.patientId,
    required this.parentId,
    required this.role,
    this.parent,
  });

  factory PatientParentModel.fromJson(Map<String, dynamic> json) {
    return PatientParentModel(
      patientId: parseId(json['patient_id']),
      parentId: parseId(json['parent_id']),
      role: json['role'] as String? ?? 'tuteur',
      parent: json['parent'] is Map
          ? ParentModel.fromJson(Map<String, dynamic>.from(json['parent'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parent_id': parentId,
      'role': role,
    };
  }

  String get roleLabel {
    switch (role) {
      case 'pere':
        return 'Père';
      case 'mere':
        return 'Mère';
      case 'tuteur':
        return 'Tuteur';
      default:
        return role;
    }
  }
}
