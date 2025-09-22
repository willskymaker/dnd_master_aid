import '../data/db_specie.dart';
import '../data/db_classi.dart';
import '../data/db_abilita.dart';
import '../data/db_equip.dart';
import '../core/logger.dart';

abstract class ICharacterRepository {
  List<Specie> getAllSpecies();
  Specie? getSpecieById(String id);
  List<Classe> getAllClasses();
  Classe? getClasseById(String id);
  List<Abilita> getAllAbilities();
  List<OggettoEquip> getAllEquipment();
}

class CharacterRepository implements ICharacterRepository {
  // Cache per migliorare le performance
  static List<Specie>? _cachedSpecies;
  static List<Classe>? _cachedClasses;
  static List<Abilita>? _cachedAbilities;
  static List<OggettoEquip>? _cachedEquipment;

  @override
  List<Specie> getAllSpecies() {
    _cachedSpecies ??= List.from(specieList);
    AppLogger.debug("Caricate ${_cachedSpecies!.length} specie");
    return _cachedSpecies!;
  }

  @override
  Specie? getSpecieById(String id) {
    try {
      return getAllSpecies().firstWhere((s) => s.nome == id);
    } catch (e) {
      AppLogger.warning("Specie '$id' non trovata");
      return null;
    }
  }

  @override
  List<Classe> getAllClasses() {
    _cachedClasses ??= List.from(classiList);
    AppLogger.debug("Caricate ${_cachedClasses!.length} classi");
    return _cachedClasses!;
  }

  @override
  Classe? getClasseById(String id) {
    try {
      return getAllClasses().firstWhere((c) => c.nome == id);
    } catch (e) {
      AppLogger.warning("Classe '$id' non trovata");
      return null;
    }
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
  List<Specie> searchSpecies(String query) {
    final lowercaseQuery = query.toLowerCase();
    return getAllSpecies()
        .where((s) => s.nome.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  /// Cerca classi per criterio
  List<Classe> searchClasses(String query) {
    final lowercaseQuery = query.toLowerCase();
    return getAllClasses()
        .where((c) => c.nome.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  /// Ottiene classi compatibili con determinate caratteristiche
  List<Classe> getClassesForCharacteristics(List<String> preferredCharacteristics) {
    // Implementazione semplificata - da espandere con logica più complessa
    return getAllClasses().where((classe) {
      // Qui andrebbero implementati i controlli specifici
      return true;
    }).toList();
  }

  /// Ottiene equipaggiamento per classe
  List<OggettoEquip> getEquipmentForClass(String className) {
    final classe = getClasseById(className);
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
    _cachedSpecies = null;
    _cachedClasses = null;
    _cachedAbilities = null;
    _cachedEquipment = null;
    AppLogger.info("Cache repository pulita");
  }

  /// Statistiche del repository
  Map<String, int> getStats() {
    return {
      'specie': getAllSpecies().length,
      'classi': getAllClasses().length,
      'abilita': getAllAbilities().length,
      'equipaggiamento': getAllEquipment().length,
    };
  }
}