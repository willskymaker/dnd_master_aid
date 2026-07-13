/// Euristiche leggere (non IA vera) per suggerire al master come un mostro
/// potrebbe comportarsi nel turno corrente, derivate solo da dati già
/// presenti in monsters.json (caratteristiche, PF, testo delle azioni).
library;

List<String> suggerimentiTattici({
  required Map<String, dynamic>? datiMostro,
  required int pfCorrenti,
  required int pfMax,
}) {
  if (datiMostro == null) return const [];

  final suggerimenti = <String>[];

  final abilityScores = datiMostro['ability_scores'] as Map?;
  final saggezza = (abilityScores?['wisdom'] as num?)?.toInt();
  final intelligenza = (abilityScores?['intelligence'] as num?)?.toInt();

  if (saggezza != null &&
      saggezza >= 12 &&
      pfMax > 0 &&
      pfCorrenti / pfMax < 0.3) {
    suggerimenti.add('Potrebbe tentare di fuggire o rifugiarsi');
  }

  final azioni = [
    ...((datiMostro['actions'] as List?) ?? const []),
    ...((datiMostro['special_abilities'] as List?) ?? const []),
  ];
  final combattenteADistanza = azioni.any((a) {
    if (a is! Map) return false;
    if (a['range'] != null) return true;
    final descrizione = (a['description'] as String? ?? '').toLowerCase();
    return descrizione.contains('arma a distanza') ||
        descrizione.contains('gittata');
  });
  if (combattenteADistanza) {
    suggerimenti.add('Cerca di mantenere le distanze dai PG');
  }

  if (intelligenza != null) {
    suggerimenti.add(
      intelligenza >= 8
          ? 'Punterebbe al PG più ferito/debole a portata'
          : 'Attacca semplicemente il bersaglio più vicino',
    );
  }

  return suggerimenti.take(2).toList();
}
