import '../../../technical/Formatting/formatters.dart';
import 'categorizer.dart';
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
final _labelRe = RegExp(r'libell|label|description|intitul|nature|d[ée]tail|merchant|b[ée]n[ée]ficiaire', caseSensitive: false);

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

CsvResult parseCsv(String input) {
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
  var di = find(RegExp('date', caseSensitive: false));
  var li = find(_labelRe);
  var ai = find(RegExp('montant|amount|somme|valeur', caseSensitive: false));
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
    final date = parseDateText(cell(r, di));
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
    entries.add(TransactionEntry(id: 'i${i}_${DateTime.now().microsecondsSinceEpoch}', date: date, raw: raw, amount: rounded, category: categorize(raw, rounded)));
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
