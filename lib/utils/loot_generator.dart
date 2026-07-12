import 'dart:math';

/// Livello di importanza dell'incontro/tesoro, in base al Grado di Sfida.
enum TierBottino { basso, medio, alto, epico }

const _nomiTier = {
  TierBottino.basso: 'Basso (GS 0-4)',
  TierBottino.medio: 'Medio (GS 5-10)',
  TierBottino.alto: 'Alto (GS 11-16)',
  TierBottino.epico: 'Epico (GS 17+)',
};

String nomeTier(TierBottino tier) => _nomiTier[tier]!;

/// Determina il tier di bottino da un Grado di Sfida numerico.
TierBottino tierDaCr(double cr) {
  if (cr <= 4) return TierBottino.basso;
  if (cr <= 10) return TierBottino.medio;
  if (cr <= 16) return TierBottino.alto;
  return TierBottino.epico;
}

/// Bottino generato: monete e oggetti magici.
class Bottino {
  final int rame;
  final int argento;
  final int oro;
  final int platino;
  final List<Map<String, dynamic>> oggettiMagici;

  const Bottino({
    this.rame = 0,
    this.argento = 0,
    this.oro = 0,
    this.platino = 0,
    this.oggettiMagici = const [],
  });
}

/// Genera un bottino casuale (monete + 0-2 oggetti magici) adeguato al tier.
Bottino generaBottino({
  required TierBottino tier,
  required List<Map<String, dynamic>> oggettiDisponibili,
  Random? random,
}) {
  final rnd = random ?? Random();
  var rame = 0;
  var argento = 0;
  var oro = 0;
  var platino = 0;
  late final List<String> raritaAmmesse;
  late final List<double> sogliaOggetti; // [soglia 0 oggetti, soglia 1 oggetto]

  switch (tier) {
    case TierBottino.basso:
      rame = (rnd.nextInt(6) + 1) * 10;
      argento = (rnd.nextInt(6) + 1) * 10;
      oro = (rnd.nextInt(6) + 1) * 10;
      raritaAmmesse = ['common', 'uncommon'];
      sogliaOggetti = [0.6, 0.9];
      break;
    case TierBottino.medio:
      argento = (rnd.nextInt(6) + 1) * 100;
      oro = (rnd.nextInt(8) + 1) * 100;
      raritaAmmesse = ['uncommon', 'rare'];
      sogliaOggetti = [0.4, 0.8];
      break;
    case TierBottino.alto:
      oro = (rnd.nextInt(10) + 1) * 1000;
      platino = (rnd.nextInt(6) + 1) * 10;
      raritaAmmesse = ['rare', 'very rare'];
      sogliaOggetti = [0.2, 0.6];
      break;
    case TierBottino.epico:
      oro = (rnd.nextInt(10) + 1) * 10000;
      platino = (rnd.nextInt(8) + 1) * 1000;
      raritaAmmesse = ['very rare', 'legendary'];
      sogliaOggetti = [0.1, 0.4];
      break;
  }

  final tiro = rnd.nextDouble();
  final numOggetti =
      tiro < sogliaOggetti[0] ? 0 : (tiro < sogliaOggetti[1] ? 1 : 2);

  var pool =
      oggettiDisponibili.where((o) {
        final r = (o['rarity'] as String? ?? '').toLowerCase();
        return raritaAmmesse.any((target) => r.contains(target));
      }).toList();
  if (pool.isEmpty) pool = oggettiDisponibili;

  final oggettiScelti = <Map<String, dynamic>>[];
  final disponibili = List<Map<String, dynamic>>.from(pool);
  for (var i = 0; i < numOggetti && disponibili.isNotEmpty; i++) {
    final idx = rnd.nextInt(disponibili.length);
    oggettiScelti.add(disponibili.removeAt(idx));
  }

  return Bottino(
    rame: rame,
    argento: argento,
    oro: oro,
    platino: platino,
    oggettiMagici: oggettiScelti,
  );
}
