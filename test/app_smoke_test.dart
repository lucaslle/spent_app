import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spent_app/main.dart';

Future<void> _loadFonts() async {
  for (final (family, files) in [
    ('Manrope', ['Manrope_400Regular', 'Manrope_500Medium', 'Manrope_600SemiBold', 'Manrope_700Bold', 'Manrope_800ExtraBold']),
    ('GeistMono', ['GeistMono_500Medium']),
  ]) {
    final loader = FontLoader(family);
    for (final f in files) {
      loader.addFont(rootBundle.load('assets/fonts/$f.ttf'));
    }
    await loader.load();
  }
}

void main() {
  testWidgets('parcourt les onglets et ouvre les feuilles sans erreur', (tester) async {
    await _loadFonts();
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(EcuApp(prefs: prefs));
    await tester.pumpAndSettle();
    expect(find.text('Vos dépenses'), findsOneWidget);

    await tester.tap(find.textContaining('Patrimoine'));
    await tester.pumpAndSettle();
    expect(find.text('Mes comptes'), findsOneWidget);
    await tester.tap(find.text('+ Ajouter un compte'));
    await tester.pumpAndSettle();
    expect(find.text('Nouveau compte'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    for (final tab in ['Opérations', 'Budget', 'Analyse', 'Réglages', 'Jour']) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Opérations').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ListView).first, warnIfMissed: false);
    final row = find.textContaining('Monoprix').first;
    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(find.text('Exclure des statistiques'), findsOneWidget);
  });
}
