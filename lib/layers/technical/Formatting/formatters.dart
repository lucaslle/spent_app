const _nbsp = ' ';

const blurMarker = '\u2063';

const mois = ['janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'];
const moisCourts = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];
const jours = ['dimanche', 'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi'];
const joursCourts = ['dim.', 'lun.', 'mar.', 'mer.', 'jeu.', 'ven.', 'sam.'];

String pad2(int n) => n.toString().padLeft(2, '0');
String isoDate(int y, int m, int d) => '$y-${pad2(m)}-${pad2(d)}';
String capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String todayIso() {
  final n = DateTime.now();
  return isoDate(n.year, n.month, n.day);
}

int daysInMonth(int y, int m) => DateTime.utc(y, m + 1, 0).day;

class IsoDate {
  const IsoDate(this.y, this.m, this.d, this.weekday);

  factory IsoDate.parse(String s) {
    final p = s.split('-').map(int.parse).toList();
    return IsoDate(p[0], p[1], p[2], DateTime.utc(p[0], p[1], p[2]).weekday % 7);
  }

  final int y;
  final int m;
  final int d;
  final int weekday;
}

String _group(String digits) {
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(_nbsp);
    out.write(digits[i]);
  }
  return out.toString();
}

String formatEuro(double n, {int decimals = 2, bool sign = false}) {
  final fixed = n.abs().toStringAsFixed(decimals);
  final parts = fixed.split('.');
  final body = decimals > 0 ? '${_group(parts[0])},${parts[1]}' : _group(parts[0]);
  final prefix = n < 0 && n.abs() >= 0.005 ? '−' : (sign && n > 0 ? '+' : '');
  return '$prefix$body$_nbsp€';
}

String formatPercentSigned(double v) {
  final rounded = (v * 100).round().abs();
  return '${v > 0 ? '+' : (v < 0 ? '−' : '')}$rounded$_nbsp%';
}

String formatPercent(double ratio) => '${(ratio * 100).round()}$_nbsp%';

String shortDate(String iso) {
  final p = IsoDate.parse(iso);
  return '${p.d} ${moisCourts[p.m - 1]}';
}

String longDate(String iso) {
  final p = IsoDate.parse(iso);
  return '${capitalize(jours[p.weekday])} ${p.d} ${mois[p.m - 1]} ${p.y}';
}

String dayLabel(String iso) {
  final p = IsoDate.parse(iso);
  return '${capitalize(joursCourts[p.weekday])} ${p.d} ${moisCourts[p.m - 1]}';
}

double? parseAmount(String? input) {
  if (input == null) return null;
  var s = input.replaceAll(RegExp('[\\s  €"]'), '').replaceAll('−', '-');
  if (s.isEmpty) return null;
  if (s.contains(',') && s.contains('.')) {
    s = s.lastIndexOf(',') > s.lastIndexOf('.') ? s.replaceAll('.', '').replaceFirst(',', '.') : s.replaceAll(',', '');
  } else {
    s = s.replaceFirst(',', '.');
  }
  return RegExp(r'^[-+]?\d*\.?\d+$').hasMatch(s) ? double.parse(s) : null;
}

String? parseDateText(String? input) {
  if (input == null || input.trim().isEmpty) return null;
  final s = input.trim();
  final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(s);
  if (iso != null) return '${iso[1]}-${iso[2]}-${iso[3]}';
  final fr = RegExp(r'^(\d{1,2})[/.-](\d{1,2})[/.-](\d{2,4})(\s.*)?$').firstMatch(s);
  if (fr == null) return null;
  var y = int.parse(fr[3]!);
  if (y < 100) y += 2000;
  return isoDate(y, int.parse(fr[2]!), int.parse(fr[1]!));
}
