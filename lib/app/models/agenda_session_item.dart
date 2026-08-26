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
      photoUrl: seance.patient?['photo'] as String?,
      patientId: seance.patientId,
      rawPatient: seance.patient,
    );
  }

  factory AgendaSessionItem.fromGroupe(SeanceGroupeModel seance) {
    final name = seance.groupeName.isNotEmpty ? seance.groupeName : 'Groupe';
    final partsCount = seance.participants?.length ?? 0;
    return AgendaSessionItem(
      id: seance.id,
      isGroupe: true,
      title: 'Groupe : $name',
      subtitle: '${seance.heureDebut} — ${seance.heureFin}${partsCount > 0 ? ' • $partsCount participant(s)' : ' • Atelier Collectif'}',
      date: seance.date,
      heureDebut: seance.heureDebut,
      heureFin: seance.heureFin,
      duree: '45 min',
      statut: seance.statut,
      statutLabel: 'Groupe',
      initials: name.isNotEmpty ? name[0].toUpperCase() : 'G',
      groupeId: seance.groupeId,
      participants: seance.participants,
      rawGroupe: seance.groupe,
    );
  }
}
