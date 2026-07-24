import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/npc_generator.dart';
import '../core/logger.dart';

/// Servizio per la gestione dei PNG salvati dal Master, cosi' che un PNG
/// generato in una sessione possa ricomparire in sessioni future della
/// stessa campagna (es. come committente ricorrente di una side quest).
class SavedNpcService {
  static const String _prefsKey = 'saved_npcs';

  /// Carica tutti i PNG salvati.
  static Future<List<Png>> caricaTutti() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null || raw.isEmpty) return [];

      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      final List<Png> png = [];

      for (final item in decoded) {
        try {
          png.add(Png.fromJson(item as Map<String, dynamic>));
        } catch (e) {
          AppLogger.warning('PNG salvato corrotto, saltato: $e');
        }
      }

      return png;
    } catch (e, st) {
      AppLogger.error('Errore nel caricamento PNG salvati', e, st);
      return [];
    }
  }

  /// Salva (aggiunge o aggiorna) un PNG.
  static Future<void> salva(Png png) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tutti = await caricaTutti();

      final index = tutti.indexWhere((p) => p.id == png.id);
      if (index >= 0) {
        tutti[index] = png;
      } else {
        tutti.add(png);
      }

      final encoded = jsonEncode(tutti.map((p) => p.toJson()).toList());
      await prefs.setString(_prefsKey, encoded);
      AppLogger.info('PNG salvato: ${png.nome} (${png.id})');
    } catch (e, st) {
      AppLogger.error('Errore nel salvataggio PNG', e, st);
      rethrow;
    }
  }

  /// Elimina un PNG salvato per ID.
  static Future<void> elimina(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tutti = await caricaTutti();
      tutti.removeWhere((p) => p.id == id);

      final encoded = jsonEncode(tutti.map((p) => p.toJson()).toList());
      await prefs.setString(_prefsKey, encoded);
      AppLogger.info('PNG eliminato: $id');
    } catch (e, st) {
      AppLogger.error("Errore nell'eliminazione PNG", e, st);
      rethrow;
    }
  }
}
