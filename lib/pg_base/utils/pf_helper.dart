// pg_base/utils/pf_helper.dart

/// Calcola i punti ferita totali del personaggio
/// seguendo la regola "media fissa + mod COS" dal livello 2 in poi
int calcolaPuntiFerita({
  required int livello,
  required int dadoVita,
  required int modCostituzione,
}) {
  if (livello < 1 || dadoVita <= 0) return 0;

  // Livello 1: dado massimo + mod COS
  int pfTotali = dadoVita + modCostituzione;

  // Livelli successivi: media fissa del dado + mod COS
  int mediaFissa = (dadoVita / 2).ceil() + 1;
  pfTotali += (mediaFissa + modCostituzione) * (livello - 1);

  return pfTotali.clamp(1, 999);
}