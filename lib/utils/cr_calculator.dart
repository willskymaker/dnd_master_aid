/// Stima automatica del Grado di Sfida (GS) per mostri homebrew,
/// seguendo le regole del Dungeon Master's Guide (DMG 5e).

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

// Danno/round → Offensive CR table (DMG 5e)
const List<_CrEntry> _dmgTable = [
  _CrEntry(0, [0, 5]),
  _CrEntry(0.125, [6, 8]),
  _CrEntry(0.25, [9, 14]),
  _CrEntry(0.5, [15, 20]),
  _CrEntry(1, [21, 25]),
  _CrEntry(2, [26, 32]),
  _CrEntry(3, [33, 38]),
  _CrEntry(4, [39, 44]),
  _CrEntry(5, [45, 50]),
  _CrEntry(6, [51, 56]),
  _CrEntry(7, [57, 62]),
  _CrEntry(8, [63, 68]),
  _CrEntry(9, [69, 74]),
  _CrEntry(10, [75, 80]),
  _CrEntry(11, [81, 86]),
  _CrEntry(12, [87, 92]),
  _CrEntry(13, [93, 98]),
  _CrEntry(14, [99, 104]),
  _CrEntry(15, [105, 110]),
  _CrEntry(16, [111, 116]),
  _CrEntry(17, [117, 122]),
  _CrEntry(18, [123, 128]),
  _CrEntry(19, [129, 134]),
  _CrEntry(20, [135, 140]),
  _CrEntry(21, [141, 146]),
  _CrEntry(22, [147, 152]),
  _CrEntry(23, [153, 158]),
  _CrEntry(24, [159, 164]),
  _CrEntry(25, [165, 170]),
  _CrEntry(26, [171, 176]),
  _CrEntry(27, [177, 182]),
  _CrEntry(28, [183, 188]),
  _CrEntry(29, [189, 194]),
  _CrEntry(30, [195, 200]),
];

// Bonus attacco atteso per CR offensivo (indice allineato a _dmgTable/_hpTable)
const List<int> _expectedAttackBonus = [
  3, // CR 0
  3, // CR 1/8
  3, // CR 1/4
  3, // CR 1/2
  3, // CR 1
  3, // CR 2
  4, // CR 3
  5, // CR 4
  6, // CR 5
  6, // CR 6
  6, // CR 7
  7, // CR 8
  7, // CR 9
  7, // CR 10
  8, // CR 11
  8, // CR 12
  8, // CR 13
  8, // CR 14
  8, // CR 15
  9, // CR 16
  10, // CR 17
  10, // CR 18
  10, // CR 19
  10, // CR 20
  10, // CR 21
  10, // CR 22
  10, // CR 23
  10, // CR 24
  10, // CR 25
  10, // CR 26
  10, // CR 27
  10, // CR 28
  10, // CR 29
  10, // CR 30
];

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
  // Trova il GS base nella tabella dei danni.
  int indiceBase = _dmgTable.length - 1;
  for (int i = 0; i < _dmgTable.length; i++) {
    final entry = _dmgTable[i];
    if (dannoMedioPerRound >= entry.hpRange[0] &&
        dannoMedioPerRound <= entry.hpRange[1]) {
      indiceBase = i;
      break;
    }
  }

  // Aggiusta di ±1 passo per ogni 2 punti di differenza dal bonus atteso.
  final int bonusAtteso = _expectedAttackBonus[indiceBase];
  final int differenza = bonusAttacco - bonusAtteso;
  final int aggiustamento = differenza ~/ 2;

  final int indiceFinale = (indiceBase + aggiustamento).clamp(0, 30);
  return _dmgTable[indiceFinale].cr;
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
