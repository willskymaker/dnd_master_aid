// lib/pg_base/utils/asi_helper.dart

const List<int> _livelliAsiStandard = [4, 8, 12, 16, 19];

/// Livelli di ASI aggiuntivi rispetto alla tabella standard, previsti da
/// manuale solo per alcune classi (Guerriero: 6 e 14; Ladro: 10).
const Map<String, List<int>> _livelliAsiExtra = {
  'Guerriero': [6, 14],
  'Ladro': [10],
};

/// Numero di Aumenti del Punteggio di Caratteristica (ASI) raggiunti al
/// livello indicato, secondo la tabella ufficiale (4, 8, 12, 16, 19), con
/// gli ASI aggiuntivi previsti da manuale per Guerriero e Ladro.
int calcolaASI({required int livello, String? classe}) {
  var numeroAsi = _livelliAsiStandard.where((l) => livello >= l).length;
  final extra = _livelliAsiExtra[classe] ?? const [];
  numeroAsi += extra.where((l) => livello >= l).length;
  return numeroAsi;
}
