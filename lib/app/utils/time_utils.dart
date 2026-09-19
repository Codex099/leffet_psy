import 'package:flutter/material.dart';

/// Utilitaire de gestion et validation des horaires de séances
class TimeUtils {
  /// Parse une chaîne "HH:mm" ou "HH:mm:ss" en nombre de minutes depuis minuit
  static int? timeToMinutes(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return null;
    final parts = timeStr.trim().split(':');
    if (parts.isEmpty) return null;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return h * 60 + m;
  }

  /// Formate un total de minutes depuis minuit en chaîne "HH:mm"
  static String minutesToTime(int totalMinutes) {
    final clamped = totalMinutes.clamp(0, 23 * 60 + 59);
    final h = clamped ~/ 60;
    final m = clamped % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  /// Vérifie si [heureFin] est strictement postérieure à [heureDebut]
  static bool isHeureApres(String heureDebut, String heureFin) {
    final debutMin = timeToMinutes(heureDebut);
    final finMin = timeToMinutes(heureFin);
    if (debutMin == null || finMin == null) return false;
    return finMin > debutMin;
  }

  /// Ajoute des minutes à une heure donnée ("HH:mm")
  static String ajouterMinutes(String heureDebut, {int minutesAAjouter = 45}) {
    final debutMin = timeToMinutes(heureDebut) ?? (10 * 60);
    return minutesToTime(debutMin + minutesAAjouter);
  }

  /// Ajuste automatiquement l'heure de fin si elle est inférieure ou égale à l'heure de début
  static String ajusterHeureFin(
    String heureDebut,
    String? heureFin, {
    int defaultDurationMinutes = 45,
  }) {
    if (heureFin == null ||
        heureFin.trim().isEmpty ||
        !isHeureApres(heureDebut, heureFin)) {
      return ajouterMinutes(
        heureDebut,
        minutesAAjouter: defaultDurationMinutes,
      );
    }
    return heureFin;
  }

  /// Valide que les horaires sont renseignés et que heureFin > heureDebut
  /// Retourne null si valide, ou le message d'erreur si invalide.
  static String? validerHoraires(String? heureDebut, String? heureFin) {
    if (heureDebut == null || heureDebut.trim().isEmpty) {
      return 'Veuillez renseigner l\'heure de début.';
    }
    if (heureFin == null || heureFin.trim().isEmpty) {
      return 'Veuillez renseigner l\'heure de fin.';
    }
    if (!isHeureApres(heureDebut, heureFin)) {
      return 'L\'heure de fin doit être strictement postérieure à l\'heure de début.';
    }
    return null;
  }

  /// Convertit un TimeOfDay en chaîne "HH:mm"
  static String formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Convertit une chaîne "HH:mm" en TimeOfDay
  static TimeOfDay parseTimeOfDay(
    String timeStr, {
    TimeOfDay defaultTime = const TimeOfDay(hour: 10, minute: 0),
  }) {
    final parts = timeStr.split(':');
    final h =
        parts.isNotEmpty ? (int.tryParse(parts[0]) ?? defaultTime.hour) : defaultTime.hour;
    final m =
        parts.length > 1 ? (int.tryParse(parts[1]) ?? defaultTime.minute) : defaultTime.minute;
    return TimeOfDay(hour: h, minute: m);
  }
}
