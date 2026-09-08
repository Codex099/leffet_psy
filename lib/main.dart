import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'app/services/language_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Optimisation de la mémoire cache d'images (Pro Dev Best Practice)
  // Évite les fuites de mémoire et les micro-saccades lors du défilement des listes avec photos
  PaintingBinding.instance.imageCache.maximumSizeBytes = 64 * 1024 * 1024; // 64 MB
  PaintingBinding.instance.imageCache.maximumSize = 150; // max 150 images décodées en RAM

  await initializeDateFormatting('fr_FR', null);
  await initializeDateFormatting('ar_DZ', null);
  await initializeDateFormatting('ar', null);

  // Charger la langue stockée en mémoire persistante
  final initialLocale = await LanguageService.getSavedLocale();

  runApp(PsyCareApp(initialLocale: initialLocale));
}

