/// Fascia di salute derivata da PF correnti/massimi, usata dalla Vista
/// Giocatori per non rivelare i PF esatti di un mostro (solo lo stato
/// relativo). Nessuna dipendenza da Flutter: la UI mappa [fascia] sul colore.
enum FasciaSalute { sano, ferito, gravementeFerito, morente }

class InfoFasciaSalute {
  final FasciaSalute fascia;
  final String etichetta;

  /// 0.0-1.0, usata solo per il riempimento della barra (non un numero
  /// esatto di PF: solo la proporzione).
  final double frazione;

  const InfoFasciaSalute({
    required this.fascia,
    required this.etichetta,
    required this.frazione,
  });
}

InfoFasciaSalute fasciaSalute({required int pfCorrenti, required int pfMax}) {
  final frazione = pfMax > 0 ? (pfCorrenti / pfMax).clamp(0.0, 1.0) : 0.0;

  if (pfCorrenti <= 0) {
    return InfoFasciaSalute(
      fascia: FasciaSalute.morente,
      etichetta: 'Morente/A terra',
      frazione: frazione,
    );
  }
  if (frazione > 0.66) {
    return InfoFasciaSalute(
      fascia: FasciaSalute.sano,
      etichetta: 'Sano',
      frazione: frazione,
    );
  }
  if (frazione > 0.33) {
    return InfoFasciaSalute(
      fascia: FasciaSalute.ferito,
      etichetta: 'Ferito',
      frazione: frazione,
    );
  }
  return InfoFasciaSalute(
    fascia: FasciaSalute.gravementeFerito,
    etichetta: 'Gravemente ferito',
    frazione: frazione,
  );
}
