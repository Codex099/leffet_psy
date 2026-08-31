import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'app/translations/app_translations.dart';

class PsyCareApp extends StatelessWidget {
 final Locale initialLocale;
  const PsyCareApp({super.key, this.initialLocale = const Locale('fr', 'FR')});

 @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PsyCare',
     debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.login,
      initialBinding: InitialBinding(),
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: child!,
        );
      },
      
      // ─── Localisation multilingue ─────────────────────────────────────────────
      translations: AppTranslations(),
      locale: initialLocale,
      fallbackLocale: const Locale('fr', 'FR'),
     supportedLocales: const [
        Locale('fr', 'FR'),
       Locale('ar', 'DZ'),
       Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
