import '../data/db_specie.dart';
import '../data/db_classi.dart';
import '../data/db_abilita.dart';
import '../data/db_equip.dart';
import '../data/db_incantesimi.dart';
import '../core/logger.dart';
import 'json_data_repository.dart';

abstract class ICharacterRepository {
  Future<List<Specie>> getAllSpecies();
  Future<Specie?> getSpecieById(String id);
  Future<List<Classe>> getAllClasses();
  Future<Classe?> getClasseById(String id);
  List<Abilita> getAllAbilities();
  List<OggettoEquip> getAllEquipment();
  Future<List<Incantesimo>> getAllSpells();
}

class CharacterRepository implements ICharacterRepository {
  // Cache per migliorare le performance (solo per dati statici)
  static List<Abilita>? _cachedAbilities;
  static List<OggettoEquip>? _cachedEquipment;

  @override
  Future<List<Specie>> getAllSpecies() async {
    return await JsonDataRepository.loadSpecies();
  }

  @override
  Future<Specie?> getSpecieById(String id) async {
    try {
      final species = await getAllSpecies();
      return species.firstWhere((s) => s.nome == id);
    } catch (e) {
      AppLogger.warning("Specie '$id' non trovata");
      return null;
    }
  }

  @override
  Future<List<Classe>> getAllClasses() async {
    return await JsonDataRepository.loadClasses();
  }

  @override
  Future<Classe?> getClasseById(String id) async {
    try {
      final classes = await getAllClasses();
      return classes.firstWhere((c) => c.nome == id);
    } catch (e) {
      AppLogger.warning("Classe '$id' non trovata");
      return null;
    }
  }

  @override
  Future<List<Incantesimo>> getAllSpells() async {
    return await JsonDataRepository.loadSpells();
  }

  @override
  List<Abilita> getAllAbilities() {
    _cachedAbilities ??= List.from(abilitaList);
    AppLogger.debug("Caricate ${_cachedAbilities!.length} abilità");
    return _cachedAbilities!;
  }

  @override
  List<OggettoEquip> getAllEquipment() {
    _cachedEquipment ??= List.from(oggettiEquipList);
    AppLogger.debug("Caricati ${_cachedEquipment!.length} oggetti equipaggiamento");
    return _cachedEquipment!;
  }

  /// Metodi di ricerca avanzata

  /// Cerca specie per criterio
  Future<List<Specie>> searchSpecies(String query) async {
    final lowercaseQuery = query.toLowerCase();
    final species = await getAllSpecies();
    return species
        .where((s) => s.nome.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  /// Cerca classi per criterio
  Future<List<Classe>> searchClasses(String query) async {
    final lowercaseQuery = query.toLowerCase();
    final classes = await getAllClasses();
    return classes
        .where((c) => c.nome.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  /// Ottiene classi compatibili con determinate caratteristiche
  Future<List<Classe>> getClassesForCharacteristics(List<String> preferredCharacteristics) async {
    // Implementazione semplificata - da espandere con logica più complessa
    final classes = await getAllClasses();
    return classes.where((classe) {
      // Qui andrebbero implementati i controlli specifici
      return true;
    }).toList();
  }

  /// Ottiene equipaggiamento per classe
  Future<List<OggettoEquip>> getEquipmentForClass(String className) async {
    final classe = await getClasseById(className);
    if (classe == null) return [];

    return getAllEquipment().where((equip) {
      return equip.classiConsigliate.contains(className) ||
             equip.classiConsigliate.isEmpty;
    }).toList();
  }

  /// Ottiene equipaggiamento per tipo
  List<OggettoEquip> getEquipmentByType(String type) {
    return getAllEquipment()
        .where((equip) => equip.tipo.toLowerCase() == type.toLowerCase())
        .toList();
  }

  /// Ottiene armi
  List<OggettoEquip> getWeapons() {
    return getEquipmentByType("arma");
  }

  /// Ottiene armature
  List<OggettoEquip> getArmor() {
    return getEquipmentByType("armatura");
  }

  /// Ottiene oggetti generici
  List<OggettoEquip> getItems() {
    return getEquipmentByType("oggetto");
  }

  /// Pulisce la cache (utile per reload dei dati)
  static void clearCache() {
    _cachedAbilities = null;
    _cachedEquipment = null;
    JsonDataRepository.clearCache();
    AppLogger.info("Cache repository pulita");
  }

  /// Statistiche del repository
  Future<Map<String, int>> getStats() async {
    final species = await getAllSpecies();
    final classes = await getAllClasses();
    return {
      'specie': species.length,
      'classi': classes.length,
      'abilita': getAllAbilities().length,
      'equipaggiamento': getAllEquipment().length,
    };
  }
}