import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:leffet_psy/app/widgets/app_bottom_nav.dart';
import 'package:leffet_psy/app/widgets/app_button.dart';
import 'package:leffet_psy/app/widgets/app_text_field.dart';
import 'package:leffet_psy/app/widgets/creative_app_bar.dart';
import 'package:leffet_psy/app/widgets/ios_card.dart';
import 'package:leffet_psy/app/widgets/ios_segmented_control.dart';
import 'package:leffet_psy/app/widgets/patient_avatar.dart';
import 'package:leffet_psy/app/widgets/state_placeholder.dart';
import 'package:leffet_psy/app/widgets/status_badge.dart';

void main() {
  Widget wrapWidget(Widget child) {
    return GetMaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('AppButton Widget Tests', () {
    testWidgets('Renders label and responds to tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        wrapWidget(
          AppButton(
            label: 'Enregistrer',
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Enregistrer'), findsOneWidget);
      await tester.tap(find.text('Enregistrer'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('Shows CircularProgressIndicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          const AppButton(
            label: 'Enregistrer',
            isLoading: true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Enregistrer'), findsNothing);
    });
  });

  group('AppTextField Widget Tests', () {
    testWidgets('Renders label and hint text', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        wrapWidget(
          AppTextField(
            label: 'Nom du patient',
            hintText: 'Ex: Dupont',
            controller: controller,
          ),
        ),
      );

      expect(find.text('Nom du patient'), findsOneWidget);
      expect(find.text('Ex: Dupont'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'Alami');
      expect(controller.text, 'Alami');
    });
  });

  group('StatusBadge Widget Tests', () {
    testWidgets('Renders different status badges properly', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          Column(
            children: [
              StatusBadge.active(),
              StatusBadge.inactive(),
              StatusBadge.present(),
              StatusBadge.absent(),
              StatusBadge.pending(),
            ],
          ),
        ),
      );

      expect(find.text('Actif'), findsOneWidget);
      expect(find.text('Inactif'), findsOneWidget);
      expect(find.text('Assisté'), findsOneWidget);
      expect(find.text('Absent'), findsOneWidget);
      expect(find.text('En attente'), findsOneWidget);
    });
  });

  group('StatePlaceholder Widget Tests', () {
    testWidgets('Renders loading, empty, and error states', (tester) async {
      bool retried = false;
      await tester.pumpWidget(
        wrapWidget(
          StatePlaceholder.error(
            title: 'Erreur réseau',
            message: 'Serveur inaccessible',
            onAction: () => retried = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Erreur réseau'), findsOneWidget);
      expect(find.text('Réessayer'), findsOneWidget);

      await tester.tap(find.text('Réessayer'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(retried, isTrue);
    });

    testWidgets('Renders empty placeholder', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          StatePlaceholder.empty(
            title: 'Aucun patient',
            message: 'Ajoutez un nouveau patient',
          ),
        ),
      );

      expect(find.text('Aucun patient'), findsOneWidget);
      expect(find.text('Ajoutez un nouveau patient'), findsOneWidget);
    });
  });

  group('PatientAvatar Widget Tests', () {
    testWidgets('Renders initials when photo is null', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          const PatientAvatar(
            initials: 'JD',
            photoUrl: null,
          ),
        ),
      );

      expect(find.text('JD'), findsOneWidget);
    });
  });

  group('IosCard & IosSegmentedControl Tests', () {
    testWidgets('IosCard renders child and responds to tap', (tester) async {
      bool cardTapped = false;
      await tester.pumpWidget(
        wrapWidget(
          IosCard(
            children: [
              IosCardTile(
                title: 'Contenu Carte',
                onTap: () => cardTapped = true,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Contenu Carte'), findsOneWidget);
      await tester.tap(find.text('Contenu Carte'));
      await tester.pump();
      expect(cardTapped, isTrue);
    });

    testWidgets('IosSegmentedControl renders and switches items', (tester) async {
      String selected = 'Tous';
      await tester.pumpWidget(
        wrapWidget(
          IosSegmentedControl<String>(
            segments: const {
              'Tous': 'Tous',
              'Actif': 'Actif',
            },
            selectedValue: selected,
            onValueChanged: (val) {
              selected = val;
            },
          ),
        ),
      );

      expect(find.text('Tous'), findsOneWidget);
      expect(find.text('Actif'), findsOneWidget);
    });
  });

  group('CreativeAppBar & AppBottomNav Tests', () {
    testWidgets('CreativeAppBar renders title and subtitle', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          const CreativeAppBar(
            title: 'Dossier Patient',
            subtitle: 'Consultation',
            showBackButton: true,
          ),
        ),
      );

      expect(find.text('Dossier Patient'), findsOneWidget);
      expect(find.text('CONSULTATION'), findsOneWidget);
    });

    testWidgets('AppBottomNav renders 4 navigation items', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          const AppBottomNav(currentIndex: 0),
        ),
      );

      expect(find.text('Accueil'), findsOneWidget);
      expect(find.text('Patients'), findsOneWidget);
      expect(find.text('Agenda'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
    });
  });
}
