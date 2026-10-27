import '../../../technical/Formatting/formatters.dart';
import 'categorizer.dart';
import 'entities/category_rule.dart';
import 'entities/spend_category.dart';
import 'entities/transaction_entry.dart';

sealed class CsvResult {
  const CsvResult();
}

class CsvFailure extends CsvResult {
  const CsvFailure(this.message);
  final String message;
}

class CsvParsed extends CsvResult {
  const CsvParsed({required this.entries, required this.separator, required this.hasHeader, required this.skipped, required this.dateColumn, required this.labelColumn, required this.amountColumn});

  final List<TransactionEntry> entries;
  final String separator;
  final bool hasHeader;
  final int skipped;
  final String dateColumn;
  final String labelColumn;
  final String amountColumn;
}

final _headerRe = RegExp(r'date|libell|montant|amount|label|description|d[ée]bit|cr[ée]dit', caseSensitive: false);
final _operationDateRe = RegExp(r'date.*op[ée]ration', caseSensitive: false);
final _plainDateRe = RegExp(r'^(?!.*valeur).*date', caseSensitive: false);
final _operationLabelRe = RegExp(r'libell.*op[ée]ration', caseSensitive: false);
final _amountRe = RegExp(r'^(?!.*date).*(montant|amount|somme|valeur)', caseSensitive: false);
final _referenceRe = RegExp(r'^r[ée]f[ée]rence$', caseSensitive: false);
final _bankCategoryRe = RegExp(r'^cat[ée]gorie$', caseSensitive: false);
final _bankExcludedRe = RegExp('exclue', caseSensitive: false);
final _labelRe = RegExp(r'libell|label|description|intitul|nature|d[ée]tail|merchant|b[ée]n[ée]ficiaire', caseSensitive: false);

bool _hasCategoryRule(String raw, List<CategoryRule> rules) => rules.any((r) => !r.isIgnore && r.matches(raw));

const _bankCategories = {
  'aliment': SpendCategory.alim,
  'transport': SpendCategory.transport,
  'loisir': SpendCategory.loisirs,
  'logement': SpendCategory.logement,
  'shopping': SpendCategory.shop,
  'epargne': SpendCategory.invest,
  'placement': SpendCategory.invest,
  'sante': SpendCategory.sante,
  'santé': SpendCategory.sante,
};

SpendCategory? _fromBankCategory(String bankCategory) {
  final c = bankCategory.toLowerCase();
  for (final e in _bankCategories.entries) {
    if (c.contains(e.key)) return e.value;
  }
  return null;
}

List<String> _splitLine(String line, String sep) {
  final out = <String>[];
  final cur = StringBuffer();
  var quoted = false;
  for (var i = 0; i < line.length; i++) {
    final ch = line[i];
    if (ch == '"') {
      if (quoted && i + 1 < line.length && line[i + 1] == '"') {
        cur.write('"');
        i++;
      } else {
        quoted = !quoted;
      }
    } else if (ch == sep && !quoted) {
      out.add(cur.toString());
      cur.clear();
    } else {
      cur.write(ch);
    }
  }
  out.add(cur.toString());
  return out.map((x) => x.trim()).toList();
}

CsvResult parseCsv(String input, {List<CategoryRule> rules = const []}) {
  final text = input.replaceFirst('﻿', '');
  final lines = text.split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty).toList();
  if (lines.isEmpty) return const CsvFailure('Fichier vide.');

  final probe = lines.take(8).join('\n');
  int count(String ch) => ch.allMatches(probe).length;
  final sep = [';', '\t', ','].fold(';', (b, ch) => count(ch) > count(b) ? ch : b);
  final rows = lines.map((l) => _splitLine(l, sep)).toList();

  bool isHead(List<String> r) => r.any(_headerRe.hasMatch) && !r.any((x) => parseDateText(x) != null);
  final hi = rows.indexWhere((r) => r.length >= 2 && isHead(r));
  final header = hi >= 0 ? rows[hi] : null;
  final body = rows.skip(hi + 1).where((r) => r.length >= 2).toList();

  int find(RegExp re) => header == null ? -1 : header.indexWhere(re.hasMatch);
  int findFirst(List<RegExp> res) {
    for (final re in res) {
      final i = find(re);
      if (i >= 0) return i;
    }
    return -1;
  }

  final anyDateIndex = find(RegExp('date', caseSensitive: false));
  var di = findFirst([_operationDateRe, _plainDateRe]);
  var li = findFirst([_operationLabelRe, _labelRe]);
  var ai = find(_amountRe);
  final bankCategoryIndex = find(_bankCategoryRe);
  final referenceIndex = find(_referenceRe);
  final dbi = find(RegExp(r'd[ée]bit', caseSensitive: false));
  final cri = find(RegExp(r'cr[ée]dit', caseSensitive: false));

  if (di < 0 || li < 0 || (ai < 0 && dbi < 0)) {
    final r0 = body.isEmpty ? <String>[] : body.first;
    if (di < 0) di = r0.indexWhere((x) => parseDateText(x) != null);
    if (ai < 0 && dbi < 0) {
      ai = [for (var i = 0; i < r0.length; i++) i].firstWhere((i) => i != di && parseAmount(r0[i]) != null, orElse: () => -1);
    }
    if (li < 0) {
      var best = -1;
      var bestLen = -1;
      for (var i = 0; i < r0.length; i++) {
        if (i != di && i != ai && r0[i].length > bestLen) {
          bestLen = r0[i].length;
          best = i;
        }
      }
      li = best;
    }
  }
  if (di < 0 || li < 0 || (ai < 0 && dbi < 0)) {
    return const CsvFailure('Colonnes introuvables. Format attendu : date ; libellé ; montant.');
  }

  String cell(List<String> r, int i) => i >= 0 && i < r.length ? r[i] : '';
  final entries = <TransactionEntry>[];
  var skipped = 0;
  for (var i = 0; i < body.length; i++) {
    final r = body[i];
    final date = parseDateText(cell(r, di)) ?? parseDateText(cell(r, anyDateIndex));
    double? amt;
    if (ai >= 0) {
      amt = parseAmount(cell(r, ai));
    } else {
      final d = parseAmount(cell(r, dbi));
      final c = parseAmount(cell(r, cri));
      amt = (c?.abs() ?? 0) - (d?.abs() ?? 0);
    }
    final raw = cell(r, li).replaceAll(RegExp(r'\s+'), ' ').trim();
    if (date == null || amt == null || raw.isEmpty || amt == 0) {
      skipped++;
      continue;
    }
    final rounded = (amt * 100).round() / 100;
    final bankCategory = cell(r, bankCategoryIndex);
    var category = categorize(raw, rounded, rules: rules);
    if (category == SpendCategory.autre && rounded < 0 && !_hasCategoryRule(raw, rules)) category = _fromBankCategory(bankCategory) ?? category;
    entries.add(TransactionEntry(
      id: 'i${i}_${DateTime.now().microsecondsSinceEpoch}',
      date: date,
      raw: raw,
      amount: rounded,
      category: category,
      excluded: _bankExcludedRe.hasMatch(bankCategory) || isIgnoredByRules(raw, rules),
      reference: cell(r, referenceIndex).isEmpty ? null : cell(r, referenceIndex),
    ));
  }
  if (entries.isEmpty) return const CsvFailure('Aucune opération lisible dans ce fichier.');

  entries.sort(compareByDateDesc);
  String name(int i) => header != null && i >= 0 ? header[i] : 'Colonne ${i + 1}';
  return CsvParsed(
    entries: entries,
    separator: sep,
    hasHeader: header != null,
    skipped: skipped,
    dateColumn: name(di),
    labelColumn: name(li),
    amountColumn: ai >= 0 ? name(ai) : '${name(dbi)} / ${name(cri)}',
  );
}
