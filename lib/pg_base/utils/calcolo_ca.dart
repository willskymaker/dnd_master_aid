import '../factory_pg_base.dart';

int calcolaClasseArmatura(PGBase pg) {
  int base = 10;
  final desMod = pg.modificatori['DES'] ?? 0;

  final armatura = pg.equipaggiamento.firstWhere(
    (e) => e.toLowerCase().contains("armatura"),
    orElse: () => '',
  );
  final usaScudo = pg.equipaggiamento.any((e) => e.toLowerCase() == "scudo");

  if (armatura.contains("cuoio")) {
    base = 11 + desMod;
  } else if (armatura.contains("giaco") || armatura.contains("scaglie")) {
    base = 14 + (desMod > 2 ? 2 : desMod);
  } else if (armatura.contains("piastre")) {
    base = 18;
  }

  if (usaScudo) base += 2;

  return base;
}
