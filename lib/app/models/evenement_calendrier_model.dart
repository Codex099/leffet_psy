// Modèle pour un événement du calendrier administratif.
import '../utils/json_utils.dart';

class EvenementCalendrierModel {
  final dynamic id;
  final String titre;
  final String? description;
  final String date;
  final int? notifierAvantJours;
  final String? creerPar;

  const EvenementCalendrierModel({
    required this.id,
    required this.titre,
    this.description,
    required this.date,
    this.notifierAvantJours,
    this.creerPar,
  });

  factory EvenementCalendrierModel.fromJson(Map<String, dynamic> json) {
    return EvenementCalendrierModel(
      id: parseId(json['id']),
      titre: json['titre'] as String? ?? '',
      description: json['description'] as String?,
      date: json['date'] as String? ?? '',
      notifierAvantJours: parseNullableInt(json['notifier_avant_jours']),
      creerPar: json['creer_par'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titre': titre,
        'description': description,
        'date': date,
        'notifier_avant_jours': notifierAvantJours,
        'creer_par': creerPar,
      };
}
