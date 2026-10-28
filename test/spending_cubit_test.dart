import 'package:flutter_test/flutter_test.dart';
import 'package:spent_app/layers/functional/Spending/domain/csv_parser.dart';
import 'package:spent_app/layers/functional/Spending/domain/entities/category_rule.dart';
import 'package:spent_app/layers/functional/Spending/domain/entities/spend_category.dart';
import 'package:spent_app/layers/functional/Spending/domain/gateways/spending_gateway.dart';
import 'package:spent_app/layers/functional/Spending/presentation/cubit/spending_cubit.dart';

class _MemoryGateway implements SpendingGateway {
  SpendingSnapshot? saved;

  @override
  Future<SpendingSnapshot?> load() async => saved;

  @override
  Future<void> save(SpendingSnapshot snapshot) async => saved = snapshot;
}

const _head = 'Date operation;Libelle operation;Reference;Debit;Credit';



void main() {
  test('Ajouter ignore les opérations déjà importées grâce à la référence', () async {
    final cubit = SpendingCubit(_MemoryGateway());
    await cubit.load();
    final first = (parseCsv('$_head\n05/10/2026;CB LIDL;REF1;-10,00;\n05/10/2026;CB LIDL;REF2;-10,00;') as CsvParsed).entries;
    await cubit.importEntries(first, 'a.csv', ImportMode.replace);
    expect(cubit.state.entries.length, 2);

    final second = (parseCsv('$_head\n05/10/2026;CB LIDL;REF1;-10,00;\n05/10/2026;CB LIDL;REF2;-10,00;\n06/10/2026;CB LIDL;REF3;-10,00;') as CsvParsed).entries;
    final added = await cubit.importEntries(second, 'b.csv', ImportMode.append);
    expect(added, 1);
    expect(cubit.state.entries.length, 3);
  });

  test('deux achats identiques le même jour avec des références différentes sont conservés', () async {
    final cubit = SpendingCubit(_MemoryGateway());
    await cubit.load();
    final entries = (parseCsv('$_head\n05/10/2026;CB CAFE;R1;-2,00;\n05/10/2026;CB CAFE;R2;-2,00;') as CsvParsed).entries;
    await cubit.importEntries(entries, 'a.csv', ImportMode.append);
    expect(cubit.state.entries.length, 2);
  });

  test('sans référence, repli sur date + libellé + montant', () async {
    final cubit = SpendingCubit(_MemoryGateway());
    await cubit.load();
    final csv = 'Date;Libellé;Montant\n05/10/2026;CB LIDL;-10,00';
    await cubit.importEntries((parseCsv(csv) as CsvParsed).entries, 'a.csv', ImportMode.replace);
    final added = await cubit.importEntries((parseCsv(csv) as CsvParsed).entries, 'a.csv', ImportMode.append);
    expect(added, 0);
    expect(cubit.state.entries.length, 1);
  });

  test('une règle ajoutée reclasse les opérations existantes sauf celles classées à la main', () async {
    final gateway = _MemoryGateway();
    final cubit = SpendingCubit(gateway);
    await cubit.load();
    final entries = (parseCsv('$_head\n05/10/2026;ENVOI WERO CLARA;R1;-30,00;\n06/10/2026;ENVOI WERO LEA;R2;-20,00;\n07/10/2026;CB LIDL;R3;-5,00;') as CsvParsed).entries;
    await cubit.importEntries(entries, 'a.csv', ImportMode.replace);
    final lea = cubit.state.entries.firstWhere((t) => t.raw.contains('LEA'));
    await cubit.classify(lea.id, SpendCategory.shop, applyToSimilar: false);

    final changed = await cubit.addRule('Envoi Wero', SpendCategory.loisirs);
    expect(changed, 1);
    expect(cubit.state.entries.firstWhere((t) => t.raw.contains('CLARA')).category, SpendCategory.loisirs);
    expect(cubit.state.entries.firstWhere((t) => t.raw.contains('LEA')).category, SpendCategory.shop);
    expect(gateway.saved!.rules!.any((r) => r.keyword == 'envoi wero'), isTrue);

    await cubit.addRule('lidl', null);
    expect(cubit.state.entries.firstWhere((t) => t.raw.contains('LIDL')).excluded, isTrue);
    await cubit.removeRule('lidl');
    expect(cubit.state.rules.any((r) => r.keyword == 'lidl'), isFalse);
    expect(cubit.state.rules.contains(const CategoryRule(keyword: 'offre confort')), isTrue);
  });

  test('le mois sélectionné pilote les statistiques', () async {
    final cubit = SpendingCubit(_MemoryGateway());
    await cubit.load();
    final entries = (parseCsv('$_head\n05/09/2026;CB LIDL;R1;-10,00;\n05/10/2026;CB LIDL;R2;-40,00;') as CsvParsed).entries;
    await cubit.importEntries(entries, 'a.csv', ImportMode.replace);
    cubit.selectMonth('2026-09');
    expect(cubit.state.stats!.month, 9);
    expect(cubit.state.stats!.spent, 10);
  });
}
