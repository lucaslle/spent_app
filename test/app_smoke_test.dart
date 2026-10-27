import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spent_app/layers/functional/Spending/data/shared_prefs_spending_gateway.dart';
import 'package:spent_app/layers/functional/Spending/domain/entities/spend_category.dart';
import 'package:spent_app/layers/functional/Spending/domain/gateways/spending_gateway.dart';
import 'package:spent_app/layers/technical/Formatting/amount_privacy_cubit.dart';
import 'package:spent_app/layers/technical/Formatting/formatters.dart';
import 'package:spent_app/main.dart';

import 'sample_data.dart';

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
    final entries = sampleTransactions();
    await SharedPrefsSpendingGateway(prefs).save(SpendingSnapshot(entries: entries, budgets: const {SpendCategory.alim: 320, SpendCategory.resto: 180}, lastImport: 'test.csv'));

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

  testWidgets('démarre vide, sans aucune donnée', (tester) async {
    await _loadFonts();
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(EcuApp(prefs: prefs));
    await tester.pumpAndSettle();
    expect(find.textContaining('Aucune opération'), findsOneWidget);
    expect(find.text('Patrimoine · 0 compte'), findsOneWidget);
    for (final tab in ['Opérations', 'Budget', 'Analyse', 'Réglages']) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
    }
    expect(find.textContaining('Exemple'), findsNothing);
  });

  testWidgets('les montants sont floutés puis révélés', (tester) async {
    await _loadFonts();
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await SharedPrefsSpendingGateway(prefs).save(SpendingSnapshot(entries: sampleTransactions(), budgets: const {SpendCategory.alim: 320}, lastImport: 'test.csv'));

    await tester.pumpWidget(EcuApp(prefs: prefs));
    await tester.pumpAndSettle();
    final blurred = find.byWidgetPredicate((w) => w is ImageFiltered);
    expect(blurred, findsNothing);
    await tester.element(find.text('Vos dépenses')).read<AmountPrivacyCubit>().toggle();
    await tester.pumpAndSettle();
    expect(blurred, findsWidgets);
    await tester.element(find.text('Vos dépenses')).read<AmountPrivacyCubit>().toggle();
    await tester.pumpAndSettle();
    expect(blurred, findsNothing);
  });

  testWidgets('le filtre Revenus affiche un total positif', (tester) async {
    await _loadFonts();
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await SharedPrefsSpendingGateway(prefs).save(SpendingSnapshot(entries: sampleTransactions(), budgets: const {}, lastImport: 'test.csv'));

    await tester.pumpWidget(EcuApp(prefs: prefs));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Opérations').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Revenus').first);
    await tester.pumpAndSettle();
    expect(find.textContaining(RegExp(r'opérations · \+\d')), findsOneWidget);
  });

  testWidgets('le total de Tout est le solde net des opérations affichées', (tester) async {
    await _loadFonts();
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final entries = sampleTransactions();
    await SharedPrefsSpendingGateway(prefs).save(SpendingSnapshot(entries: entries, budgets: const {}, lastImport: 'test.csv'));

    await tester.pumpWidget(EcuApp(prefs: prefs));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Opérations').last);
    await tester.pumpAndSettle();
    final net = entries.fold<double>(0, (a, t) => a + t.amount);
    expect(find.text('${entries.length} opérations · ${formatEuro(net, sign: true)}'), findsOneWidget);
  });
}
