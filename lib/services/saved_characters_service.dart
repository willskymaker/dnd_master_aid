import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../factory_pg_base.dart';
import '../core/logger.dart';

class SavedCharactersService {
  static const String _indexKey = 'saved_characters_index';
  static const String _charPrefix = 'character_';

  static Future<List<PGBase>> loadAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final index = prefs.getStringList(_indexKey) ?? [];
      final List<PGBase> characters = [];

      for (final id in index) {
        final json = prefs.getString('$_charPrefix$id');
        if (json != null) {
          try {
            final map = jsonDecode(json) as Map<String, dynamic>;
            characters.add(PGBase.fromJson(map));
          } catch (e) {
            AppLogger.warning('Personaggio $id corrotto, saltato: $e');
          }
        }
      }

      characters.sort((a, b) => b.dataSalvataggio.compareTo(a.dataSalvataggio));
      return characters;
    } catch (e, st) {
      AppLogger.error('Errore nel caricamento personaggi', e, st);
      return [];
    }
  }

  static Future<void> save(PGBase pg) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final index = prefs.getStringList(_indexKey) ?? [];

      if (!index.contains(pg.id)) {
        index.add(pg.id);
        await prefs.setStringList(_indexKey, index);
      }

      await prefs.setString('$_charPrefix${pg.id}', jsonEncode(pg.toJson()));
      AppLogger.info('Personaggio salvato: ${pg.nome} (${pg.id})');
    } catch (e, st) {
      AppLogger.error('Errore nel salvataggio personaggio', e, st);
      rethrow;
    }
  }

  static Future<void> delete(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final index = prefs.getStringList(_indexKey) ?? [];
      index.remove(id);
      await prefs.setStringList(_indexKey, index);
      await prefs.remove('$_charPrefix$id');
      AppLogger.info('Personaggio eliminato: $id');
    } catch (e, st) {
      AppLogger.error('Errore nell\'eliminazione personaggio', e, st);
      rethrow;
    }
  }
}
