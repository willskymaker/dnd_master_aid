/// CR Calculator for D&D 5e homebrew monsters.
/// Uses DMG rules for defensive and offensive CR estimation.
library cr_calculator;

class _CrEntry {
  final double cr;
  final List<int> hpRange; // [min, max]

  const _CrEntry(this.cr, this.hpRange);
}

// HP → Defensive CR table (DMG 5e)
const List<_CrEntry> _hpTable = [
  _CrEntry(0, [1, 6]),
  _CrEntry(0.125, [7, 35]),
  _CrEntry(0.25, [36, 49]),
  _CrEntry(0.5, [50, 70]),
  _CrEntry(1, [71, 85]),
  _CrEntry(2, [86, 100]),
  _CrEntry(3, [101, 115]),
  _CrEntry(4, [116, 130]),
  _CrEntry(5, [131, 145]),
  _CrEntry(6, [146, 160]),
  _CrEntry(7, [161, 175]),
  _CrEntry(8, [176, 190]),
  _CrEntry(9, [191, 205]),
  _CrEntry(10, [206, 220]),
  _CrEntry(11, [221, 235]),
  _CrEntry(12, [236, 250]),
  _CrEntry(13, [251, 265]),
  _CrEntry(14, [266, 280]),
  _CrEntry(15, [281, 295]),
  _CrEntry(16, [296, 310]),
  _CrEntry(17, [311, 325]),
  _CrEntry(18, [326, 340]),
  _CrEntry(19, [341, 355]),
  _CrEntry(20, [356, 400]),
  _CrEntry(21, [401, 445]),
  _CrEntry(22, [446, 490]),
  _CrEntry(23, [491, 535]),
  _CrEntry(24, [536, 580]),
  _CrEntry(25, [581, 625]),
  _CrEntry(26, [626, 670]),
  _CrEntry(27, [671, 715]),
  _CrEntry(28, [716, 760]),
  _CrEntry(29, [761, 805]),
  _CrEntry(30, [806, 850]),
];

class CrCalculator {
  // Correct DMG table for offensive CR
  static final Map<double, String> _dmgTable = {
    1.0: 'CR 0',      // 0-1 damage
    2.0: 'CR 1/8',    // 2-3 damage
    3.0: 'CR 1/4',    // 4-5 damage
    4.0: 'CR 1/2',    // 6-8 damage
    5.0: 'CR 1',      // 9-14 damage
    6.0: 'CR 2',      // 15-20 damage
    7.0: 'CR 3',      // 21-26 damage
    8.0: 'CR 4',      // 27-32 damage
    9.0: 'CR 5',      // 33-38 damage
    10.0: 'CR 6',     // 39-44 damage
    11.0: 'CR 7',     // 45-50 damage
    12.0: 'CR 8',     // 51-56 damage
    13.0: 'CR 9',     // 57-62 damage
    14.0: 'CR 10',    // 63-68 damage
    15.0: 'CR 11',    // 69-74 damage
    16.0: 'CR 12',    // 75-80 damage
    17.0: 'CR 13',    // 81-86 damage
    18.0: 'CR 14',    // 87-92 damage
    19.0: 'CR 15',    // 93-98 damage
    20.0: 'CR 16',    // 99-104 damage
    21.0: 'CR 17',    // 105-110 damage
    22.0: 'CR 18',    // 111-116 damage
    23.0: 'CR 19',    // 117-122 damage
    24.0: 'CR 20',    // 123-128 damage
    25.0: 'CR 21',    // 129-134 damage
    26.0: 'CR 22',    // 135-140 damage
    27.0: 'CR 23',    // 141-146 damage
    28.0: 'CR 24',    // 147-152 damage
    29.0: 'CR 25',    // 153-158 damage
    30.0: 'CR 26',    // 159-164 damage
    31.0: 'CR 27',    // 165-170 damage
    32.0: 'CR 28',    // 171-176 damage
    33.0: 'CR 29',    // 177-182 damage
    34.0: 'CR 30',    // 183-188 damage
  };

  static double calculateOffensiveCR(int damage, int attackBonus) {
    final int baseRow = _getBaseRow(damage);
    final int expectedBonus = _getExpectedAttackBonus(baseRow);
    final int diff = attackBonus - expectedBonus;
    final int adj = diff ~/ 2;
    final double finalKey = (baseRow + adj).clamp(1, 34).toDouble();
    final String crStr = _dmgTable[finalKey]!;
    return _parseCr(crStr);
  }

  static int _getBaseRow(int damage) {
    if (damage <= 1) return 1;
    if (damage <= 3) return 2;
    if (damage <= 5) return 3;
    if (damage <= 8) return 4;
    if (damage <= 14) return 5;
    if (damage <= 20) return 6;
    if (damage <= 26) return 7;
    if (damage <= 32) return 8;
    if (damage <= 38) return 9;
    if (damage <= 44) return 10;
    if (damage <= 50) return 11;
    if (damage <= 56) return 12;
    if (damage <= 62) return 13;
    if (damage <= 68) return 14;
    if (damage <= 74) return 15;
    if (damage <= 80) return 16;
    if (damage <= 86) return 17;
    if (damage <= 92) return 18;
    if (damage <= 98) return 19;
    if (damage <= 104) return 20;
    if (damage <= 110) return 21;
    if (damage <= 116) return 22;
    if (damage <= 122) return 23;
    if (damage <= 128) return 24;
    if (damage <= 134) return 25;
    if (damage <= 140) return 26;
    if (damage <= 146) return 27;
    if (damage <= 152) return 28;
    if (damage <= 158) return 29;
    if (damage <= 164) return 30;
    if (damage <= 170) return 31;
    if (damage <= 176) return 32;
    if (damage <= 182) return 33;
    return 34;
  }

  static int _getExpectedAttackBonus(int row) {
    if (row <= 6) return 3;
    if (row == 7) return 4;
    if (row == 8) return 5;
    if (row <= 11) return 6;
    if (row <= 14) return 7;
    if (row <= 19) return 8;
    if (row == 20) return 9;
    return 10;
  }

  static double _parseCr(String crStr) {
    final clean = crStr.replaceFirst('CR ', '').trim();
    if (clean == '0') return 0.0;
    if (clean == '1/8') return 0.125;
    if (clean == '1/4') return 0.25;
    if (clean == '1/2') return 0.5;
    return double.parse(clean);
  }
}

// ---------------------------------------------------------------------------
// Classi pubbliche
// ---------------------------------------------------------------------------

/// Resistenze/immunità ai danni per il calcolo difensivo del GS.
class ResistenzeImmunita {
  final bool haResistenze; // 2+ tipi di resistenza
  final bool haImmunita; // 2+ tipi di immunità

  const ResistenzeImmunita({
    this.haResistenze = false,
    this.haImmunita = false,
  });
}

/// Risultato del calcolo del GS.
class RisultatoGS {
  final double gsFinale;
  final double gsDifensivo;
  final double gsOffensivo;

  /// "0", "1/8", "1/4", "1/2", o "N" per interi.
  final String gsFormattato;

  const RisultatoGS({
    required this.gsFinale,
    required this.gsDifensivo,
    required this.gsOffensivo,
    required this.gsFormattato,
  });
}

// ---------------------------------------------------------------------------
// API pubblica
// ---------------------------------------------------------------------------

/// Calcola il GS difensivo a partire dagli HP e dalle resistenze.
double calcolaGsDifensivo(int hp, ResistenzeImmunita resistenze) {
  // Moltiplica gli HP effettivi in base a resistenze/immunità.
  double hpEffettivi = hp.toDouble();
  if (resistenze.haImmunita) {
    hpEffettivi *= 2.0;
  } else if (resistenze.haResistenze) {
    hpEffettivi *= 1.5;
  }

  final int hpCalcolati = hpEffettivi.round();

  // Trova la riga corrispondente nella tabella HP.
  for (final entry in _hpTable) {
    if (hpCalcolati >= entry.hpRange[0] && hpCalcolati <= entry.hpRange[1]) {
      return entry.cr;
    }
  }
  // Se supera la tabella, restituisce CR 30.
  return 30.0;
}

/// Calcola il GS offensivo a partire dal danno medio per round e dal bonus di attacco.
double calcolaGsOffensivo(int dannoMedioPerRound, int bonusAttacco) {
  return CrCalculator.calculateOffensiveCR(dannoMedioPerRound, bonusAttacco);
}

/// Calcola il GS finale mediando difensivo e offensivo.
RisultatoGS calcolaGs({
  required int hp,
  required int dannoMedioPerRound,
  required int bonusAttacco,
  ResistenzeImmunita resistenze = const ResistenzeImmunita(),
}) {
  final double gsDif = calcolaGsDifensivo(hp, resistenze);
  final double gsOff = calcolaGsOffensivo(dannoMedioPerRound, bonusAttacco);

  final double media = (gsDif + gsOff) / 2.0;

  // Trova il GS nella tabella più vicino alla media.
  double gsFinale = _hpTable.first.cr;
  double distanzaMinima = (media - _hpTable.first.cr).abs();
  for (final entry in _hpTable) {
    final double distanza = (media - entry.cr).abs();
    if (distanza < distanzaMinima) {
      distanzaMinima = distanza;
      gsFinale = entry.cr;
    }
  }

  return RisultatoGS(
    gsFinale: gsFinale,
    gsDifensivo: gsDif,
    gsOffensivo: gsOff,
    gsFormattato: formattaGs(gsFinale),
  );
}

/// Converte un GS double in stringa formattata.
/// 0.125 → "1/8", 0.25 → "1/4", 0.5 → "1/2", interi → "N".
String formattaGs(double gs) {
  if (gs == 0.125) return '1/8';
  if (gs == 0.25) return '1/4';
  if (gs == 0.5) return '1/2';
  if (gs == gs.truncateToDouble()) return gs.toInt().toString();
  return gs.toStringAsFixed(1);
}
