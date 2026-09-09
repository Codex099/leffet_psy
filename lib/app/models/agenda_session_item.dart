import 'package:get/get.dart';
import 'seance_model.dart';
import 'seance_groupe_model.dart';

/// Modèle unifié représentant une séance (individuelle ou de groupe) pour l'Agenda et le Dashboard.
class AgendaSessionItem {
  final dynamic id;
  final bool isGroupe;
  final String title;
  final String subtitle;
  final String date;
  final String heureDebut;
  final String heureFin;
  final String duree;
  final String statut;
  final String statutLabel;
  final String initials;
  final String? photoUrl;
  final dynamic patientId;
  final dynamic groupeId;
  final List<dynamic>? participants;
  final Map<String, dynamic>? rawPatient;
  final Map<String, dynamic>? rawGroupe;
  final String assignedEmployee;

  AgendaSessionItem({
    required this.id,
    required this.isGroupe,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.heureDebut,
    required this.heureFin,
    required this.duree,
    required this.statut,
    required this.statutLabel,
    required this.initials,
    required this.assignedEmployee,
    this.photoUrl,
    this.patientId,
    this.groupeId,
    this.participants,
    this.rawPatient,
    this.rawGroupe,
  });

  factory AgendaSessionItem.fromIndividuelle(SeanceModel seance) {
    final fullName = seance.patientFullName.isNotEmpty ? seance.patientFullName : 'Patient #${seance.patientId ?? ""}';
    final dur = seance.duree;
    
    String assigned = '';
    if (seance.employe != null) {
      final prenom = seance.employe!['prenom'] ?? '';
      final nom = seance.employe!['nom'] ?? '';
      assigned = '$prenom $nom'.trim();
    }

    return AgendaSessionItem(
      id: seance.id,
      isGroupe: false,
      title: fullName,
      subtitle: '${seance.heureDebut} — ${seance.heureFin}${dur.isNotEmpty ? ' ($dur)' : ''}',
      date: seance.date,
      heureDebut: seance.heureDebut,
      heureFin: seance.heureFin,
      duree: dur.isNotEmpty ? dur : '45 min',
      statut: seance.statut,
      statutLabel: seance.statutLabel,
      initials: fullName.isNotEmpty ? fullName[0].toUpperCase() : 'P',
      assignedEmployee: assigned,
      photoUrl: seance.photoUrl,
      patientId: seance.patientId,
      rawPatient: seance.patient,
    );
  }

  factory AgendaSessionItem.fromGroupe(SeanceGroupeModel seance) {
    final name = seance.groupeName.isNotEmpty ? seance.groupeName : 'Groupe'.tr;
    final dur = '45 min'; // Ou dynamiquement
    
    String assigned = '';
    if (seance.employe != null) {
      final prenom = seance.employe!['prenom'] ?? '';
      final nom = seance.employe!['nom'] ?? '';
      assigned = '$prenom $nom'.trim();
    }

    return AgendaSessionItem(
      id: seance.id,
      isGroupe: true,
      title: '${'Groupe'.tr} : $name',
      subtitle: '${seance.heureDebut} — ${seance.heureFin} ($dur)',
      date: seance.date,
      heureDebut: seance.heureDebut,
      heureFin: seance.heureFin,
      duree: dur,
      statut: seance.statut,
      statutLabel: 'Groupe'.tr,
      initials: 'G',
      assignedEmployee: assigned,
      groupeId: seance.groupeId,
      participants: seance.participants,
      rawGroupe: seance.groupe,
    );
  }

  // ─── Sérialisation pour PersistentCacheService ──────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'isGroupe': isGroupe,
        'title': title,
        'subtitle': subtitle,
        'date': date,
        'heureDebut': heureDebut,
        'heureFin': heureFin,
        'duree': duree,
        'statut': statut,
        'statutLabel': statutLabel,
        'initials': initials,
        'assignedEmployee': assignedEmployee,
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (patientId != null) 'patientId': patientId,
        if (groupeId != null) 'groupeId': groupeId,
      };

  factory AgendaSessionItem.fromJsonCache(Map<String, dynamic> json) {
    return AgendaSessionItem(
      id: json['id'],
      isGroupe: json['isGroupe'] as bool? ?? false,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      date: json['date'] as String? ?? '',
      heureDebut: json['heureDebut'] as String? ?? '',
      heureFin: json['heureFin'] as String? ?? '',
      duree: json['duree'] as String? ?? '',
      statut: json['statut'] as String? ?? '',
      statutLabel: json['statutLabel'] as String? ?? '',
      initials: json['initials'] as String? ?? '',
      assignedEmployee: json['assignedEmployee'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      patientId: json['patientId'],
      groupeId: json['groupeId'],
    );
  }
}
