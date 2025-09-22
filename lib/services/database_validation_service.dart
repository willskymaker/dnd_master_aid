import '../data/db_incantesimi.dart';
import '../data/db_classi.dart';
import '../data/db_specie.dart';
import '../data/enums/magic_schools.dart';
import '../core/logger.dart';

class DatabaseValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  DatabaseValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  factory DatabaseValidationResult.success() {
    return DatabaseValidationResult(
      isValid: true,
      errors: [],
      warnings: [],
    );
  }

  factory DatabaseValidationResult.failure(List<String> errors, [List<String> warnings = const []]) {
    return DatabaseValidationResult(
      isValid: false,
      errors: errors,
      warnings: warnings,
    );
  }
}

class DatabaseValidationService {
  /// Valida l'intero database per inconsistenze
  static DatabaseValidationResult validateAllDatabases() {
    final errors = <String>[];
    final warnings = <String>[];

    // Valida incantesimi
    final spellResult = validateSpells();
    errors.addAll(spellResult.errors);
    warnings.addAll(spellResult.warnings);

    // Valida classi
    final classResult = validateClasses();
    errors.addAll(classResult.errors);
    warnings.addAll(classResult.warnings);

    // Valida specie
    final speciesResult = validateSpecies();
    errors.addAll(speciesResult.errors);
    warnings.addAll(speciesResult.warnings);

    AppLogger.info("Validazione database completata: ${errors.length} errori, ${warnings.length} avvisi");

    return errors.isEmpty
        ? DatabaseValidationResult.success()
        : DatabaseValidationResult.failure(errors, warnings);
  }

  /// Valida il database degli incantesimi
  static DatabaseValidationResult validateSpells() {
    final errors = <String>[];
    final warnings = <String>[];

    AppLogger.debug("Validando ${incantesimiList.length} incantesimi");

    for (final spell in incantesimiList) {
      // Valida scuola di magia
      if (!MagicSchool.isValidSchool(spell.scuola)) {
        errors.add("Incantesimo '${spell.nome}': scuola '${spell.scuola}' non valida");
      }

      // Valida livello
      if (spell.livello < 0 || spell.livello > 9) {
        errors.add("Incantesimo '${spell.nome}': livello ${spell.livello} non valido (deve essere 0-9)");
      }

      // Valida trucchetto
      if (spell.eTrucchetto && spell.livello != 0) {
        errors.add("Incantesimo '${spell.nome}': trucchetto deve avere livello 0");
      }

      // Valida classi
      if (spell.classi.isEmpty) {
        warnings.add("Incantesimo '${spell.nome}': nessuna classe associata");
      }

      for (final className in spell.classi) {
        if (!_isValidClassName(className)) {
          warnings.add("Incantesimo '${spell.nome}': classe '$className' non riconosciuta");
        }
      }

      // Valida componenti
      if (spell.componenti.isEmpty) {
        warnings.add("Incantesimo '${spell.nome}': nessun componente specificato");
      }

      for (final component in spell.componenti) {
        if (!['V', 'S', 'M'].contains(component)) {
          warnings.add("Incantesimo '${spell.nome}': componente '$component' non standard");
        }
      }

      // Valida descrizione
      if (spell.descrizione.trim().isEmpty) {
        errors.add("Incantesimo '${spell.nome}': descrizione mancante");
      }

      // Valida campi base
      if (spell.nome.trim().isEmpty) {
        errors.add("Incantesimo trovato con nome vuoto");
      }

      if (spell.raggio.trim().isEmpty) {
        warnings.add("Incantesimo '${spell.nome}': raggio non specificato");
      }

      if (spell.durata.trim().isEmpty) {
        warnings.add("Incantesimo '${spell.nome}': durata non specificata");
      }
    }

    return errors.isEmpty
        ? DatabaseValidationResult.success()
        : DatabaseValidationResult.failure(errors, warnings);
  }

  /// Valida il database delle classi
  static DatabaseValidationResult validateClasses() {
    final errors = <String>[];
    final warnings = <String>[];

    AppLogger.debug("Validando ${classiList.length} classi");

    for (final classe in classiList) {
      // Valida nome
      if (classe.nome.trim().isEmpty) {
        errors.add("Classe trovata con nome vuoto");
        continue;
      }

      // Valida dado vita
      if (![4, 6, 8, 10, 12].contains(classe.dadoVita)) {
        errors.add("Classe '${classe.nome}': dado vita ${classe.dadoVita} non standard");
      }

      // Valida abilità da selezionare
      if (classe.abilitaDaSelezionare < 0 || classe.abilitaDaSelezionare > 6) {
        warnings.add("Classe '${classe.nome}': numero abilità da selezionare (${classe.abilitaDaSelezionare}) insolito");
      }

      // Valida abilità selezionabili
      if (classe.abilitaSelezionabili.isEmpty) {
        warnings.add("Classe '${classe.nome}': nessuna abilità selezionabile");
      }

      if (classe.abilitaSelezionabili.length < classe.abilitaDaSelezionare) {
        errors.add("Classe '${classe.nome}': abilità selezionabili (${classe.abilitaSelezionabili.length}) < abilità richieste (${classe.abilitaDaSelezionare})");
      }

      // Valida sottoclassi
      if (classe.sottoclassi.isEmpty) {
        warnings.add("Classe '${classe.nome}': nessuna sottoclasse definita");
      }

      // Valida tiri salvezza
      if (classe.tiriSalvezza.length != 2) {
        warnings.add("Classe '${classe.nome}': dovrebbe avere esattamente 2 tiri salvezza");
      }

      for (final ts in classe.tiriSalvezza) {
        if (!['FOR', 'DES', 'COS', 'INT', 'SAG', 'CAR'].contains(ts)) {
          errors.add("Classe '${classe.nome}': tiro salvezza '$ts' non valido");
        }
      }
    }

    return errors.isEmpty
        ? DatabaseValidationResult.success()
        : DatabaseValidationResult.failure(errors, warnings);
  }

  /// Valida il database delle specie
  static DatabaseValidationResult validateSpecies() {
    final errors = <String>[];
    final warnings = <String>[];

    AppLogger.debug("Validando ${specieList.length} specie");

    for (final specie in specieList) {
      // Valida nome
      if (specie.nome.trim().isEmpty) {
        errors.add("Specie trovata con nome vuoto");
        continue;
      }

      // Valida velocità
      if (specie.velocita <= 0 || specie.velocita > 60) {
        warnings.add("Specie '${specie.nome}': velocità ${specie.velocita} insolita");
      }

      // Valida linguaggi
      if (specie.linguaggi.isEmpty) {
        warnings.add("Specie '${specie.nome}': nessun linguaggio specificato");
      }

      // Valida tratti
      if (specie.abilitaInnate.isEmpty) {
        warnings.add("Specie '${specie.nome}': nessuna abilità innata");
      }
    }

    return errors.isEmpty
        ? DatabaseValidationResult.success()
        : DatabaseValidationResult.failure(errors, warnings);
  }

  /// Verifica se un nome di classe è valido
  static bool _isValidClassName(String className) {
    const validClasses = [
      'Barbaro', 'Bardo', 'Chierico', 'Druido', 'Guerriero',
      'Ladro', 'Mago', 'Monaco', 'Paladino', 'Ranger',
      'Stregone', 'Warlock', 'Artefice'
    ];
    return validClasses.contains(className);
  }

  /// Ottiene statistiche del database
  static Map<String, dynamic> getDatabaseStats() {
    return {
      'incantesimi': {
        'totale': incantesimiList.length,
        'trucchetti': incantesimiList.where((s) => s.eTrucchetto).length,
        'per_livello': _getSpellsByLevel(),
        'per_scuola': _getSpellsBySchool(),
      },
      'classi': {
        'totale': classiList.length,
        'dado_vita_medio': _getAverageHitDie(),
      },
      'specie': {
        'totale': specieList.length,
        'velocita_media': _getAverageSpeed(),
      },
    };
  }

  static Map<int, int> _getSpellsByLevel() {
    final byLevel = <int, int>{};
    for (final spell in incantesimiList) {
      byLevel[spell.livello] = (byLevel[spell.livello] ?? 0) + 1;
    }
    return byLevel;
  }

  static Map<String, int> _getSpellsBySchool() {
    final bySchool = <String, int>{};
    for (final spell in incantesimiList) {
      bySchool[spell.scuola] = (bySchool[spell.scuola] ?? 0) + 1;
    }
    return bySchool;
  }

  static double _getAverageHitDie() {
    if (classiList.isEmpty) return 0;
    final total = classiList.map((c) => c.dadoVita).reduce((a, b) => a + b);
    return total / classiList.length;
  }

  static double _getAverageSpeed() {
    if (specieList.isEmpty) return 0;
    final total = specieList.map((s) => s.velocita).reduce((a, b) => a + b);
    return total / specieList.length;
  }
}