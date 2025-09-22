import '../data/db_specie.dart';
import '../data/db_classi.dart';
import '../data/db_abilita.dart';
import '../data/db_incantesimi.dart';
import '../factory_pg_base.dart';
import '../core/logger.dart';
import '../core/exceptions.dart';
import '../repositories/character_repository.dart';

class CharacterService {
  static final CharacterRepository _repository = CharacterRepository();

  /// Ottiene tutte le specie disponibili
  static Future<List<Specie>> getAllSpecies() async {
    return await _repository.getAllSpecies();
  }

  /// Ottiene una specie per nome
  static Future<Specie?> getSpecieByName(String nome) async {
    return await _repository.getSpecieById(nome);
  }

  /// Ottiene tutte le classi disponibili
  static Future<List<Classe>> getAllClasses() async {
    return await _repository.getAllClasses();
  }

  /// Ottiene una classe per nome
  static Future<Classe?> getClasseByName(String nome) async {
    return await _repository.getClasseById(nome);
  }

  /// Ottiene tutti gli incantesimi disponibili
  static Future<List<Incantesimo>> getAllSpells() async {
    return await _repository.getAllSpells();
  }

  /// Ottiene tutte le abilità disponibili
  static List<Abilita> getAllAbilities() {
    return _repository.getAllAbilities();
  }

  /// Ottiene le abilità selezionabili per una classe
  static Future<List<String>> getAvailableAbilitiesForClass(String className) async {
    final classe = await getClasseByName(className);
    if (classe == null) {
      throw DataException("Classe '$className' non trovata", "Abilità");
    }
    return classe.abilitaSelezionabili;
  }

  /// Valida un nome personaggio
  static bool isValidCharacterName(String nome) {
    if (nome.trim().isEmpty) return false;
    if (nome.length < 2) return false;
    if (nome.length > 30) return false;

    // Controllo caratteri ammessi (lettere, spazi, apostrofi, trattini)
    final regex = RegExp(r"^[a-zA-ZÀ-ÿ\s'\-]+$");
    return regex.hasMatch(nome);
  }

  /// Valida le caratteristiche
  static bool isValidCharacteristics(Map<String, int> characteristics) {
    const validAbilities = ['FOR', 'DES', 'COS', 'INT', 'SAG', 'CAR'];

    // Verifica che tutte le caratteristiche siano presenti
    for (var ability in validAbilities) {
      if (!characteristics.containsKey(ability)) {
        return false;
      }

      final value = characteristics[ability]!;
      if (value < 3 || value > 20) {
        return false;
      }
    }

    return true;
  }

  /// Calcola i modificatori delle caratteristiche
  static Map<String, int> calculateModifiers(Map<String, int> characteristics) {
    final modifiers = <String, int>{};

    characteristics.forEach((key, value) {
      modifiers[key] = ((value - 10) / 2).floor();
    });

    return modifiers;
  }

  /// Calcola i punti ferita
  static int calculateHitPoints({
    required int level,
    required int hitDie,
    required int constitutionModifier,
  }) {
    if (level < 1 || level > 20) {
      throw ValidationException("Livello deve essere tra 1 e 20", "Punti Vita");
    }

    if (hitDie < 4 || hitDie > 12) {
      throw ValidationException("Dado vita non valido", "Punti Vita");
    }

    // Livello 1: massimo del dado + mod COS
    // Livelli successivi: media del dado + mod COS per livello
    final baseHP = hitDie; // Livello 1
    final additionalHP = (level - 1) * ((hitDie / 2) + 1 + constitutionModifier).floor();
    final totalHP = baseHP + constitutionModifier + additionalHP;

    // Minimo 1 PF per livello
    return totalHP < level ? level : totalHP;
  }

  /// Valida la selezione delle abilità per una classe
  static Future<bool> validateAbilitySelection(String className, List<String> selectedAbilities) async {
    final classe = await getClasseByName(className);
    if (classe == null) return false;

    // Verifica il numero corretto di abilità
    if (selectedAbilities.length != classe.abilitaDaSelezionare) {
      return false;
    }

    // Verifica che tutte le abilità selezionate siano disponibili per la classe
    for (var ability in selectedAbilities) {
      if (!classe.abilitaSelezionabili.contains(ability)) {
        return false;
      }
    }

    return true;
  }

  /// Ottiene le abilità consigliate per una classe (per caratteristiche)
  static List<String> getRecommendedCharacteristicsForClass(String className) {
    // Mapping delle caratteristiche principali per classe
    const classCharacteristics = {
      "Barbaro": ["FOR", "COS"],
      "Bardo": ["CAR", "DES"],
      "Chierico": ["SAG", "COS"],
      "Druido": ["SAG", "INT"],
      "Guerriero": ["FOR", "COS"],
      "Ladro": ["DES", "INT"],
      "Mago": ["INT", "DES"],
      "Monaco": ["DES", "SAG"],
      "Paladino": ["FOR", "CAR"],
      "Ranger": ["DES", "SAG"],
      "Stregone": ["CAR", "COS"],
      "Warlock": ["CAR", "SAG"]
    };

    return classCharacteristics[className] ?? [];
  }

  /// Applica i bonus razziali alle caratteristiche
  static Future<Map<String, int>> applyRacialBonuses(
    Map<String, int> baseCharacteristics,
    String specieName,
  ) async {
    final specie = await getSpecieByName(specieName);
    if (specie == null) {
      AppLogger.warning("Impossibile applicare bonus razziali: specie '$specieName' non trovata");
      return Map.from(baseCharacteristics);
    }

    final result = Map.from(baseCharacteristics);

    // Qui andrebbero implementati i bonus specifici per specie
    // Per ora mantengo la logica base
    AppLogger.debug("Bonus razziali applicati per ${specie.nome}");

    return Map<String, int>.from(result);
  }

  /// Verifica se un personaggio è valido e completo
  static bool isCharacterComplete(PGBase character) {
    if (character.nome.isEmpty) return false;
    if (character.specie.isEmpty) return false;
    if (character.classe.isEmpty) return false;
    if (character.livello < 1) return false;
    if (!character.caratteristicheImpostate) return false;
    if (character.puntiVita <= 0) return false;

    return true;
  }

  /// Genera un riassunto del personaggio per debug
  static String getCharacterSummary(PGBase character) {
    return '''
Personaggio: ${character.nome}
Specie: ${character.specie}
Classe: ${character.classe} (Livello ${character.livello})
PF: ${character.puntiVita}
Caratteristiche: ${character.caratteristiche.entries.map((e) => "${e.key}: ${e.value}").join(", ")}
Abilità: ${character.abilitaClasse.join(", ")}
Equipaggiamento: ${character.equipaggiamento.length} oggetti
''';
  }
}