import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/homebrew_monster.dart';
import '../core/logger.dart';

/// Servizio per la gestione dei mostri homebrew salvati localmente.
class HomebrewMonsterService {
  static const String _prefsKey = 'homebrew_monsters';

  /// Carica tutti i mostri homebrew salvati.
  static Future<List<HomebrewMonster>> caricaTutti() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null || raw.isEmpty) return [];

      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      final List<HomebrewMonster> mostri = [];

      for (final item in decoded) {
        try {
          mostri.add(HomebrewMonster.fromJson(item as Map<String, dynamic>));
        } catch (e) {
          AppLogger.warning('Mostro homebrew corrotto, saltato: $e');
        }
      }

      return mostri;
    } catch (e, st) {
      AppLogger.error('Errore nel caricamento mostri homebrew', e, st);
      return [];
    }
  }

  /// Salva (aggiunge o aggiorna) un mostro homebrew.
  static Future<void> salva(HomebrewMonster mostro) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mostri = await caricaTutti();

      final index = mostri.indexWhere((m) => m.id == mostro.id);
      if (index >= 0) {
        mostri[index] = mostro;
      } else {
        mostri.add(mostro);
      }

      final encoded = jsonEncode(mostri.map((m) => m.toJson()).toList());
      await prefs.setString(_prefsKey, encoded);
      AppLogger.info('Mostro homebrew salvato: ${mostro.nome} (${mostro.id})');
    } catch (e, st) {
      AppLogger.error('Errore nel salvataggio mostro homebrew', e, st);
      rethrow;
    }
  }

  /// Elimina un mostro homebrew per ID.
  static Future<void> elimina(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mostri = await caricaTutti();
      mostri.removeWhere((m) => m.id == id);

      final encoded = jsonEncode(mostri.map((m) => m.toJson()).toList());
      await prefs.setString(_prefsKey, encoded);
      AppLogger.info('Mostro homebrew eliminato: $id');
    } catch (e, st) {
      AppLogger.error("Errore nell'eliminazione mostro homebrew", e, st);
      rethrow;
    }
  }

  /// Restituisce i mostri in formato `Map<String, dynamic>` per il tracker.
  static Future<List<Map<String, dynamic>>> caricaComeMaps() async {
    final mostri = await caricaTutti();
    return mostri.map((m) => m.toTrackerMap()).toList();
  }
}
