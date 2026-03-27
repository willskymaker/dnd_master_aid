import 'package:flutter/foundation.dart';
import '../factory_pg_base.dart';
import '../services/saved_characters_service.dart';
import '../core/logger.dart';

class SavedCharactersProvider extends ChangeNotifier {
  List<PGBase> _characters = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PGBase> get characters => List.unmodifiable(_characters);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _characters = await SavedCharactersService.loadAll();
    } catch (e, st) {
      AppLogger.error('Errore nel caricamento personaggi', e, st);
      _errorMessage = 'Impossibile caricare i personaggi';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> save(PGBase pg) async {
    try {
      await SavedCharactersService.save(pg);
      final idx = _characters.indexWhere((c) => c.id == pg.id);
      if (idx >= 0) {
        _characters[idx] = pg;
      } else {
        _characters.insert(0, pg);
      }
      notifyListeners();
    } catch (e, st) {
      AppLogger.error('Errore nel salvataggio', e, st);
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await SavedCharactersService.delete(id);
      _characters.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e, st) {
      AppLogger.error('Errore nell\'eliminazione', e, st);
      rethrow;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
