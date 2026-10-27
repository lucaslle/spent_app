import 'dart:ui';

enum SpendCategory {
  alim('Courses', 0xFF7BD389, ['monoprix', 'carrefour', 'lidl', 'franprix', 'auchan', 'leclerc', 'intermarche', 'picard', 'biocoop', 'super u', 'naturalia']),
  resto('Restaurants', 0xFFF2A65A, ['uber eats', 'deliveroo', 'boulangerie', 'paul', 'starbucks', 'mcdo', 'burger', 'bistrot', 'restaurant', 'sushi', 'pizza', 'cafe', 'brasserie', 'kfc', 'big mamma']),
  transport('Transport', 0xFF6FB7FF, ['navigo', 'ratp', 'sncf', 'uber', 'bolt', 'total', 'esso', 'shell', 'blablacar', 'parking', 'vinci']),
  logement('Logement', 0xFFB49CFF, ['loyer', 'foncia', 'edf', 'engie', 'syndic', 'nexity']),
  abo('Abonnements', 0xFFFF7FB0, ['netflix', 'spotify', 'free mobile', 'sfr', 'bouygues', 'disney', 'deezer', 'basic fit', 'icloud', 'canal+']),
  shop('Shopping', 0xFF8FA8FF, ['amazon', 'zara', 'fnac', 'decathlon', 'h&m', 'uniqlo', 'ikea', 'darty', 'sephora', 'vinted', 'zalando']),
  loisirs('Loisirs', 0xFF5ED6C9, ['ugc', 'pathe', 'cinema', 'steam', 'playstation', 'concert', 'ticketmaster', 'musee', 'fnac spectacles', 'bar ']),
  sante('Santé', 0xFFFF8A80, ['pharmacie', 'doctolib', 'medecin', 'dentiste', 'mutuelle', 'opticien']),
  revenus('Revenus', 0xFF9BE15D, ['salaire', 'caf ', 'remboursement']),
  virements('Virements', 0xFF9AA3AE, ['lydia', 'vir ', 'virement', 'paylib', 'wero']),
  autre('À classer', 0xFF8C8C99, []);

  const SpendCategory(this.label, this.argb, this.keywords);

  final String label;
  final int argb;
  final List<String> keywords;

  Color get color => Color(argb);

  bool get isFixed => this == logement || this == abo;

  static const spending = [alim, resto, transport, logement, abo, shop, loisirs, sante, autre];

  static SpendCategory byName(String name) => values.firstWhere((c) => c.name == name, orElse: () => autre);
}
