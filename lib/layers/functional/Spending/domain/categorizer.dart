import 'entities/spend_category.dart';

SpendCategory categorize(String label, double amount) {
  final l = ' ${label.toLowerCase()} ';
  SpendCategory? best;
  var bestLen = 0;
  for (final c in SpendCategory.values) {
    for (final k in c.keywords) {
      if (l.contains(k) && k.length > bestLen) {
        best = c;
        bestLen = k.length;
      }
    }
  }
  best ??= amount > 0 ? SpendCategory.revenus : SpendCategory.autre;
  if (best == SpendCategory.revenus && amount < 0) best = SpendCategory.autre;
  return best;
}

const _stop = {'SAS', 'SA', 'SARL', 'FR', 'PARIS', 'EU', 'P', 'CLIENTS', 'INTERNET', 'ANNUEL', 'TRIP', 'CITE', 'GAMES', 'SEPA'};
const _acronyms = {'UGC', 'EDF', 'SNCF', 'RATP', 'SFR', 'KFC', 'H&M'};
const _lower = {'DE', 'DU', 'LA', 'LE', 'DES'};

final _prefix = RegExp(r'^(PAIEMENT PAR CARTE|PAIEMENT CB|CARTE\s?X?\d*|CB\*?\d*|PRLV SEPA|PRELEVEMENT|PRLV|VIREMENT SEPA|VIR SEPA|VIREMENT|VIR INST|VIR|RETRAIT DAB)\s+');

String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String merchantName(String raw) {
  var s = raw.toUpperCase().replaceFirst(_prefix, '');
  s = s.replaceFirst(RegExp(r'^(SQ|SUMUP|ZTL|PAYPAL)\s?\*\s?'), '').replaceAll(RegExp(r'\.COM\b'), '').replaceAll('*', ' ');
  final words = s.split(RegExp(r'\s+')).where((w) => w.isNotEmpty && !RegExp(r'\d').hasMatch(w) && !_stop.contains(w)).take(3).toList();
  if (words.isEmpty) return _cap(raw.toLowerCase());
  return [
    for (var i = 0; i < words.length; i++)
      if (_acronyms.contains(words[i]))
        words[i]
      else if (i > 0 && _lower.contains(words[i]))
        words[i].toLowerCase()
      else
        words[i][0] + words[i].substring(1).toLowerCase(),
  ].join(' ');
}

String initialsOf(String name) => name
    .split(' ')
    .where((w) => RegExp(r'^[A-ZÀ-Ü0-9&]', caseSensitive: false).hasMatch(w))
    .take(2)
    .map((w) => w[0].toUpperCase())
    .join();
