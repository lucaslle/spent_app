import 'dart:ui';

enum AccountGroup { cash, save, invest }

enum AccountType {
  courant('Compte courant', 0xFF9AA3AE, AccountGroup.cash),
  livreta('Livret A', 0xFF6FB7FF, AccountGroup.save),
  ldds('LDDS', 0xFF5ED6C9, AccountGroup.save),
  lep('LEP', 0xFF7BD389, AccountGroup.save),
  pel('PEL', 0xFFEBCB5C, AccountGroup.save),
  pea('PEA', 0xFFB49CFF, AccountGroup.invest),
  av('Assurance-vie', 0xFFF2A65A, AccountGroup.invest),
  cto('Compte-titres', 0xFFFF7FB0, AccountGroup.invest),
  crypto('Crypto', 0xFFF5B544, AccountGroup.invest),
  autre('Autre', 0xFF8C8C99, AccountGroup.save);

  const AccountType(this.label, this.argb, this.group);

  final String label;
  final int argb;
  final AccountGroup group;

  Color get color => Color(argb);

  static AccountType byName(String name) => values.firstWhere((t) => t.name == name, orElse: () => autre);
}
