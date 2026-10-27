import 'package:flutter_test/flutter_test.dart';
import 'package:spent_app/layers/functional/Spending/domain/categorizer.dart';
import 'package:spent_app/layers/functional/Spending/domain/csv_parser.dart';
import 'package:spent_app/layers/functional/Spending/domain/entities/spend_category.dart';
import 'package:spent_app/layers/functional/Spending/domain/spending_stats.dart';
import 'package:spent_app/layers/technical/Formatting/formatters.dart';

import 'sample_data.dart';

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
    expect(computeSpendingStats(const [], _budgets, '2026-10-27'), isNull);
  });
}
