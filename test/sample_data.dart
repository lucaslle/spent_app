import 'package:spent_app/layers/functional/Spending/domain/categorizer.dart';
import 'package:spent_app/layers/functional/Spending/domain/entities/transaction_entry.dart';
import 'package:spent_app/layers/technical/Formatting/formatters.dart';

class _Lcg {
  _Lcg(this._seed);
  int _seed;

  double next() {
    _seed = (_seed * 16807) % 2147483647;
    return _seed / 2147483647;
  }

  T pick<T>(List<T> a) => a[(next() * a.length).floor()];
}

List<TransactionEntry> sampleTransactions() {
  final r = _Lcg(11);
  final out = <TransactionEntry>[];
  var id = 0;
  void add(String date, String label, double amount) {
    final a = (amount * 100).round() / 100;
    out.add(TransactionEntry(id: 's${id++}', date: date, raw: label, amount: a, category: categorize(label, a)));
  }

  const fixed = <(int, String, double)>[
    (2, 'PRLV SEPA NAVIGO ANNUEL', -86.4), (3, 'PRLV SEPA FONCIA LOYER', -720), (5, 'PRLV SEPA FREE MOBILE', -19.99),
    (8, 'CB NETFLIX.COM', -13.49), (10, 'PRLV SEPA EDF CLIENTS', -64.2), (12, 'CB SPOTIFY P', -10.99),
    (15, 'PRLV SEPA BASIC FIT', -29.99), (25, 'VIR SEPA SALAIRE ACME SAS', 2150),
  ];

  for (final (y, m) in const [(2026, 8), (2026, 9), (2026, 10)]) {
    final last = m == 10 ? 27 : daysInMonth(y, m);
    for (final (d, l, a) in fixed) {
      if (d <= last) add(isoDate(y, m, d), l, a);
    }
    for (var d = 1; d <= last; d++) {
      final date = isoDate(y, m, d);
      final dd = ' ${pad2(d)}/${pad2(m)}';
      final dow = IsoDate.parse(date).weekday;
      final we = dow == 0 || dow == 6;
      if (r.next() < 0.55) add(date, 'CB ${r.pick(['BOULANGERIE PAUL', 'BOULANGERIE LA FOURNEE', 'STARBUCKS', 'COLUMBUS CAFE'])}$dd', -(2.5 + r.next() * 6));
      if (r.next() < (we ? 0.5 : 0.28)) add(date, 'CB ${r.pick(['MONOPRIX', 'CARREFOUR CITY', 'LIDL', 'FRANPRIX', 'PICARD'])}$dd', -(9 + r.next() * 58));
      if (r.next() < (dow >= 4 || dow == 0 ? 0.4 : 0.16)) add(date, 'CB ${r.pick(['UBER EATS', 'DELIVEROO', 'LE PETIT BISTROT', 'SUSHI SHOP', 'BIG MAMMA'])}$dd', -(14 + r.next() * 32));
      if (r.next() < 0.12) add(date, 'CB ${r.pick(['UBER TRIP', 'BOLT', 'TOTALENERGIES', 'SNCF INTERNET'])}$dd', -(8 + r.next() * 40));
      if (r.next() < 0.1) add(date, 'CB ${r.pick(['AMAZON EU', 'ZARA', 'FNAC', 'DECATHLON', 'UNIQLO', 'VINTED'])}$dd', -(12 + r.next() * 70));
      if (r.next() < 0.06) add(date, 'CB ${r.pick(['UGC CINE CITE', 'STEAM GAMES', 'FNAC SPECTACLES', 'BAR LE PERCHOIR'])}$dd', -(9 + r.next() * 30));
      if (r.next() < 0.04) add(date, 'CB ${r.pick(['PHARMACIE CENTRALE', 'DOCTOLIB MEDECIN'])}$dd', -(6 + r.next() * 25));
      if (r.next() < 0.05) add(date, 'VIR LYDIA ${r.pick(['THOMAS', 'CAMILLE', 'LEA'])}', (r.next() < 0.5 ? -1 : 1) * (10 + r.next() * 30));
    }
  }
  add('2026-08-18', 'CB HELLOASSO 18/08', -25);
  add('2026-09-12', 'CB SQ *ATELIER VAUGIRARD 12/09', -42);
  add('2026-10-04', 'PAIEMENT CB SUMUP *KIOSQUE 04/10', -8.5);
  add('2026-10-21', 'CB SQ *ATELIER VAUGIRARD 21/10', -38);
  add('2026-10-27', 'CB BOULANGERIE PAUL 27/10', -3.2);
  add('2026-10-27', 'CB MONOPRIX 27/10', -23.45);
  add('2026-10-27', 'CB UBER TRIP 27/10', -12.8);
  out.sort(compareByDateDesc);
  return out;
}

String sampleCsv() {
  final lines = sampleTransactions().map((t) {
    final p = IsoDate.parse(t.date);
    return '${pad2(p.d)}/${pad2(p.m)}/${p.y};${t.raw};${t.amount.toString().replaceFirst('.', ',')}';
  });
  return 'Date;Libellé;Montant\n${lines.join('\n')}';
}
