import 'package:flutter_test/flutter_test.dart';
import 'package:spent_app/layers/functional/Spending/domain/categorizer.dart';
import 'package:spent_app/layers/functional/Spending/domain/csv_parser.dart';
import 'package:spent_app/layers/functional/Spending/domain/entities/category_rule.dart';
import 'package:spent_app/layers/functional/Spending/domain/entities/spend_category.dart';
import 'package:spent_app/layers/functional/Spending/domain/spending_stats.dart';
import 'package:spent_app/layers/technical/Formatting/formatters.dart';

import 'package:spent_app/demo/demo_data.dart';

const _budgets = <SpendCategory, double>{SpendCategory.alim: 320, SpendCategory.resto: 180, SpendCategory.logement: 800};

void main() {
  test('categorize: le mot-clé le plus long gagne', () {
    expect(categorize('CB UBER EATS 12/10', -20), SpendCategory.resto);
    expect(categorize('CB UBER TRIP', -20), SpendCategory.transport);
    expect(categorize('VIR SEPA SALAIRE ACME', 2000), SpendCategory.revenus);
    expect(categorize('Inconnu', -5), SpendCategory.autre);
  });

  test('merchantName retire les préfixes bancaires', () {
    expect(merchantName('PRLV SEPA FONCIA LOYER'), 'Foncia Loyer');
  });

  test('formatage français', () {
    expect(parseAmount('−1 234,56 €'), -1234.56);
    expect(parseAmount('1,234.56'), 1234.56);
    expect(parseDateText('27/10/26'), '2026-10-27');
    expect(formatEuro(-1234.5), '−1\u00a0234,50\u00a0€');
    expect(formatEuro(2150, sign: true, decimals: 0), '+2\u00a0150\u00a0€');
  });

  test('parseCsv relit le relevé d’exemple', () {
    final r = parseCsv(sampleCsv());
    expect(r, isA<CsvParsed>());
    final p = r as CsvParsed;
    expect(p.separator, ';');
    expect(p.entries.length, sampleTransactions().length);
  });

  test('parseCsv gère débit/crédit et rejette les colonnes inconnues', () {
    final ok = parseCsv('Date;Libellé;Débit;Crédit\n01/10/2026;CB LIDL;12,50;\n02/10/2026;VIR SALAIRE;;2000') as CsvParsed;
    expect(ok.entries.length, 2);
    expect(ok.entries.any((t) => t.amount == -12.5), isTrue);
    expect(parseCsv('a;b\nc;d'), isA<CsvFailure>());
  });

  test('stats du mois sur l’exemple', () {
    final s = computeSpendingStats(sampleTransactions(), _budgets, '2026-10-27')!;
    expect(s.isToday, isTrue);
    expect(s.day, 27);
    expect(s.daysInMonth, 31);
    expect(s.spent, greaterThan(0));
    expect(s.merchants.length, 5);
    expect(s.months.map((m) => m.key), ['2026-08', '2026-09', '2026-10']);
    expect(computeSpendingStats(const [], _budgets, '2026-10-27'), isNull);
  });

  test('parseCsv lit l’export bancaire à colonnes multiples', () {
    const csv = 'Date de comptabilisation;Libelle simplifie;Libelle operation;Reference;Informations complementaires;Type operation;Categorie;Sous categorie;Debit;Credit;Date operation;Date de valeur;Pointage operation\n'
        '28/10/2026;MONOPRIX;CARTE X1234 28/10 MONOPRIX PARIS;REF1;;Paiement par carte;Alimentation;Supermarche;-23,45;;27/10/2026;28/10/2026;\n'
        '29/10/2026;FONCIA;PRLV SEPA FONCIA LOYER;REF2;;Prelevement;Logement;Loyer;720,00;;29/10/2026;29/10/2026;\n'
        '30/10/2026;ACME;VIR SEPA SALAIRE ACME;REF3;;Virement;Revenus;Salaire;;2150,00;30/10/2026;30/10/2026;';
    final p = parseCsv(csv) as CsvParsed;
    expect(p.entries.length, 3);
    expect(p.labelColumn, 'Libelle operation');
    expect(p.dateColumn, 'Date operation');
    expect(p.amountColumn, 'Debit / Credit');
    final byRaw = {for (final t in p.entries) t.raw: t};
    expect(byRaw['CARTE X1234 28/10 MONOPRIX PARIS']!.amount, -23.45);
    expect(byRaw['CARTE X1234 28/10 MONOPRIX PARIS']!.date, '2026-10-27');
    expect(byRaw['CARTE X1234 28/10 MONOPRIX PARIS']!.category, SpendCategory.alim);
    expect(byRaw['PRLV SEPA FONCIA LOYER']!.amount, -720);
    expect(byRaw['VIR SEPA SALAIRE ACME']!.amount, 2150);
    expect(byRaw['VIR SEPA SALAIRE ACME']!.category, SpendCategory.revenus);
  });

  test('revenus, virements internes et catégorie bancaire', () {
    const head = 'Date de comptabilisation;Libelle simplifie;Libelle operation;Reference;Informations complementaires;Type operation;Categorie;Sous categorie;Debit;Credit;Date operation;Date de valeur;Pointage operation';
    final csv = '$head\n'
        '05/10/2026;X;VIR SEPA ACME CORP;R;;Virement recu;A categoriser - rentree d\'argent;;;+1816,76;05/10/2026;05/10/2026;0\n'
        '06/10/2026;X;VIR INST M. DUPONT;R;;Virement recu;A categoriser - rentree d\'argent;;;+20,00;06/10/2026;06/10/2026;0\n'
        '07/10/2026;X;VIREMENT VERS CPT;R;;Virement;Transaction exclue;;-500,00;;07/10/2026;07/10/2026;0\n'
        '08/10/2026;X;CB BIDULE SHOP;R;;Carte bancaire;Transports;;-12,00;;08/10/2026;08/10/2026;0\n'
        '09/10/2026;X;CB CARREFOUR.FR;R;;Carte bancaire;Alimentation;;;+2,45;09/10/2026;09/10/2026;0';
    final p = parseCsv(csv) as CsvParsed;
    final byRaw = {for (final t in p.entries) t.raw: t};
    expect(byRaw['VIR SEPA ACME CORP']!.category, SpendCategory.revenus);
    expect(byRaw['VIR SEPA ACME CORP']!.amount, 1816.76);
    expect(byRaw['VIR INST M. DUPONT']!.category, SpendCategory.virements);
    expect(byRaw['VIREMENT VERS CPT']!.excluded, isTrue);
    expect(byRaw['CB BIDULE SHOP']!.category, SpendCategory.transport);
    expect(byRaw['CB CARREFOUR.FR']!.isSpend, isTrue);
    final s = computeSpendingStats(p.entries, const {}, '2026-10-12')!;
    expect(s.income, 1816.76);
    expect(s.spent, closeTo(12 - 2.45, 0.001));
  });

  test('le mois affiché suit la date du jour, sauf export ancien', () {
    final tx = (parseCsv('Date;Libellé;Montant\n23/10/2026;CB LIDL;-10,00') as CsvParsed).entries;
    final now = computeSpendingStats(tx, const {}, '2026-10-27')!;
    expect((now.ref, now.day, now.isToday), ('2026-10-27', 27, true));
    final old = computeSpendingStats(tx, const {}, '2026-12-05')!;
    expect((old.ref, old.day, old.isToday), ('2026-10-23', 23, false));
  });

  test('épargne et investissement ne sont ni dépenses ni revenus', () {
    expect(categorize('VIREMENT VERS LIVRET A', -500), SpendCategory.invest);
    expect(categorize('VIR. VERS PEL', -50), SpendCategory.invest);
    expect(categorize('VIREMENT VERS CPT', 45), SpendCategory.invest);
    expect(categorize('OUVERTURE QUADRETO', -8000), SpendCategory.invest);
    expect(categorize('VIREMENT SEPA LOYER MARC', -300), SpendCategory.virements);
    const head = 'Date operation;Libelle operation;Categorie;Debit;Credit';
    final p = parseCsv('$head\n05/10/2026;BOURSO LUCAS;Epargne;-300,00;\n06/10/2026;CB BOURSORAMA FACT;Banque et assurances;-300,00;') as CsvParsed;
    final byRaw = {for (final t in p.entries) t.raw: t};
    expect(byRaw['BOURSO LUCAS']!.category, SpendCategory.invest);
    expect(byRaw['BOURSO LUCAS']!.isSpend, isFalse);
    expect(byRaw['CB BOURSORAMA FACT']!.category, SpendCategory.invest);
    final s = computeSpendingStats([byRaw['BOURSO LUCAS']!], const {}, '2026-10-12')!;
    expect(s.spent, 0);
    expect(s.income, 0);
  });

  test('offre confort (frais et remise) est exclue des stats', () {
    const head = 'Date operation;Libelle operation;Debit;Credit';
    final p = parseCsv('$head\n05/10/2026;OFFRE CONFORT;-1,55;\n06/10/2026;REMISE OFFRE CONFORT;;+1,55\n07/10/2026;CB LIDL;-10,00;', rules: defaultRules) as CsvParsed;
    final byRaw = {for (final t in p.entries) t.raw: t};
    expect(byRaw['OFFRE CONFORT']!.excluded, isTrue);
    expect(byRaw['REMISE OFFRE CONFORT']!.excluded, isTrue);
    expect(byRaw['CB LIDL']!.excluded, isFalse);
    final s = computeSpendingStats(p.entries, const {}, '2026-10-12')!;
    expect(s.spent, 10);
    expect(s.income, 0);
  });

  test('règles personnelles : prioritaires sur les mots-clés, ou ignorer', () {
    const rules = [
      CategoryRule(keyword: 'envoi wero', category: SpendCategory.loisirs),
      CategoryRule(keyword: 'envoi wero vincent', category: SpendCategory.alim),
      CategoryRule(keyword: 'cafeomatic'),
    ];
    expect(categorize('ENVOI WERO CLARA', -30, rules: rules), SpendCategory.loisirs);
    expect(categorize('ENVOI WERO VINCENT', -30, rules: rules), SpendCategory.alim);
    expect(categorize('ENVOI WERO CLARA', -30), SpendCategory.virements);
    expect(isIgnoredByRules('CB CAFEOMATIC FACT', rules), isTrue);
    expect(isIgnoredByRules('CB LIDL', rules), isFalse);
    const head = 'Date operation;Libelle operation;Categorie;Debit;Credit';
    final p = parseCsv('$head\n05/10/2026;CB BIDULE;Transports;-12,00;', rules: const [CategoryRule(keyword: 'bidule', category: SpendCategory.sante)]) as CsvParsed;
    expect(p.entries.single.category, SpendCategory.sante);
  });

  test('mois consultables et statistiques d’un mois passé', () {
    final tx = sampleTransactions();
    expect(availableMonths(tx, '2026-10-27'), ['2026-08', '2026-09', '2026-10']);
    final sept = computeSpendingStats(tx, _budgets, '2026-10-27', month: '2026-09')!;
    expect((sept.month, sept.day, sept.daysInMonth, sept.isToday), (9, 30, 30, false));
    final oct = computeSpendingStats(tx, _budgets, '2026-10-27', month: '2026-10')!;
    expect((oct.month, oct.day, oct.isToday), (10, 27, true));
    expect(sept.spent, isNot(oct.spent));
  });
}
