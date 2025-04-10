// lib/pg_base/utils/asi_helper.dart

/// Restituisce la mappa degli aumenti delle caratteristiche (ASI)
/// in base al livello del personaggio. Attualmente assume +2 a COS ogni 4 livelli.
Map<String, int> calcolaASI({required int livello}) {
  final Map<String, int> bonus = {
    'FOR': 0,
    'DES': 0,
    'COS': 0,
    'INT': 0,
    'SAG': 0,
    'CAR': 0,
  };

  // Livelli con ASI secondo il manuale (4, 8, 12, 16, 19)
  final livelliASI = [4, 8, 12, 16, 19];

  for (int lvl in livelliASI) {
    if (livello >= lvl) {
      bonus['COS'] = (bonus['COS'] ?? 0) + 2; // Per ora sempre su COS
    }
  }

  return bonus;
}