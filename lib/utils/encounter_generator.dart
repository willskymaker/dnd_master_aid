import 'dart:math';

/// Difficolta' standard di un incontro D&D 5e.
enum DifficoltaIncontro { facile, media, difficile, mortale }

/// Soglie di XP per personaggio, per livello 1-20: [facile, media, difficile, mortale].
/// Tabella standard del DMG.
const List<List<int>> _sogliaXpPerLivello = [
  [25, 50, 75, 100],
  [50, 100, 150, 200],
  [75, 150, 225, 400],
  [125, 250, 375, 500],
  [250, 500, 750, 1100],
  [300, 600, 900, 1400],
  [350, 750, 1100, 1700],
  [450, 900, 1400, 2100],
  [550, 1100, 1600, 2400],
  [600, 1200, 1900, 2800],
  [800, 1600, 2400, 3600],
  [1000, 2000, 3000, 4500],
  [1100, 2200, 3400, 5100],
  [1250, 2500, 3800, 5700],
  [1400, 2800, 4300, 6400],
  [1600, 3200, 4800, 7200],
  [2000, 3900, 5900, 8800],
  [2100, 4200, 6300, 9500],
  [2400, 4900, 7300, 10900],
  [2800, 5700, 8500, 12700],
];

/// Moltiplicatore di XP in base al numero di mostri nell'incontro (regola DMG).
double moltiplicatoreXp(int numeroMostri) {
  if (numeroMostri <= 1) return 1.0;
  if (numeroMostri == 2) return 1.5;
  if (numeroMostri <= 6) return 2.0;
  if (numeroMostri <= 10) return 2.5;
  if (numeroMostri <= 14) return 3.0;
  return 4.0;
}

/// Soglia di XP totale del party per una data difficolta'.
int sogliaXpParty({
  required int numeroGiocatori,
  required int livelloMedio,
  required DifficoltaIncontro difficolta,
}) {
  final livello = livelloMedio.clamp(1, 20);
  final riga = _sogliaXpPerLivello[livello - 1];
  return riga[difficolta.index] * numeroGiocatori;
}

/// Converte una challenge_rating come stringa ("1/4", "1/2", "3") in double.
double parseCr(String? raw) {
  if (raw == null || raw.isEmpty) return 0;
  if (raw.contains('/')) {
    final parti = raw.split('/');
    final num = double.tryParse(parti[0]) ?? 0;
    final den = double.tryParse(parti.length > 1 ? parti[1] : '1') ?? 1;
    return den == 0 ? 0 : num / den;
  }
  return double.tryParse(raw) ?? 0;
}

/// Un gruppo di mostri identici nell'incontro generato.
class GruppoMostri {
  final Map<String, dynamic> mostro;
  final int quantita;

  const GruppoMostri({required this.mostro, required this.quantita});

  int get xpTotale =>
      ((mostro['experience_points'] as num?)?.toInt() ?? 0) * quantita;
}

/// Risultato della generazione di un incontro.
class IncontroGenerato {
  final List<GruppoMostri> gruppi;
  final int xpAdeguato;
  final int sogliaRichiesta;

  const IncontroGenerato({
    required this.gruppi,
    required this.xpAdeguato,
    required this.sogliaRichiesta,
  });

  bool get vuoto => gruppi.isEmpty;
}

/// Genera un incontro casuale bilanciato, scegliendo un singolo tipo di
/// mostro ripetuto N volte tra quelli con GS adeguato al livello del party,
/// mirando alla soglia di XP della difficolta' scelta.
IncontroGenerato generaIncontro({
  required List<Map<String, dynamic>> mostriDisponibili,
  required int numeroGiocatori,
  required int livelloMedio,
  required DifficoltaIncontro difficolta,
  Random? random,
}) {
  final rnd = random ?? Random();
  final soglia = sogliaXpParty(
    numeroGiocatori: numeroGiocatori,
    livelloMedio: livelloMedio,
    difficolta: difficolta,
  );

  if (mostriDisponibili.isEmpty || soglia <= 0) {
    return IncontroGenerato(
      gruppi: const [],
      xpAdeguato: 0,
      sogliaRichiesta: soglia,
    );
  }

  // Filtra mostri con GS ragionevole rispetto al livello del party.
  final crMinima = max(0, (livelloMedio / 2) - 2);
  final crMassima = livelloMedio + 3;
  var pool =
      mostriDisponibili.where((m) {
        final cr = parseCr(m['challenge_rating'] as String?);
        return cr >= crMinima && cr <= crMassima && cr > 0;
      }).toList();

  if (pool.isEmpty) pool = mostriDisponibili;

  final mostro = pool[rnd.nextInt(pool.length)];
  final xpUnitario = (mostro['experience_points'] as num?)?.toInt() ?? 0;
  if (xpUnitario <= 0) {
    return IncontroGenerato(
      gruppi: const [],
      xpAdeguato: 0,
      sogliaRichiesta: soglia,
    );
  }

  // Prova quantita' crescenti e tiene quella che si avvicina di piu' alla
  // soglia senza superarla eccessivamente (max 8 mostri dello stesso tipo).
  var migliorN = 1;
  var migliorDistanza = double.infinity;
  var migliorXp = 0;
  for (var n = 1; n <= 8; n++) {
    final xpAdeguato = (xpUnitario * n * moltiplicatoreXp(n)).round();
    final distanza = (xpAdeguato - soglia).abs().toDouble();
    final entroSoglia = xpAdeguato <= soglia * 1.15;
    if (entroSoglia && distanza < migliorDistanza) {
      migliorDistanza = distanza;
      migliorN = n;
      migliorXp = xpAdeguato;
    }
  }
  if (migliorXp == 0) {
    // Nessuna quantita' rientra nella soglia (mostro troppo forte): usane 1.
    migliorN = 1;
    migliorXp = (xpUnitario * moltiplicatoreXp(1)).round();
  }

  return IncontroGenerato(
    gruppi: [GruppoMostri(mostro: mostro, quantita: migliorN)],
    xpAdeguato: migliorXp,
    sogliaRichiesta: soglia,
  );
}
