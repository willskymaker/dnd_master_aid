import '../core/logger.dart';

class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.warnings = const [],
  });

  factory ValidationResult.success({List<String> warnings = const []}) {
    return ValidationResult(isValid: true, warnings: warnings);
  }

  factory ValidationResult.error(String message, {List<String> warnings = const []}) {
    return ValidationResult(isValid: false, errorMessage: message, warnings: warnings);
  }
}

class ValidationService {
  /// Valida il nome del personaggio
  static ValidationResult validateCharacterName(String nome) {
    final trimmedName = nome.trim();

    if (trimmedName.isEmpty) {
      return ValidationResult.error("Il nome non può essere vuoto");
    }

    if (trimmedName.length < 2) {
      return ValidationResult.error("Il nome deve avere almeno 2 caratteri");
    }

    if (trimmedName.length > 30) {
      return ValidationResult.error("Il nome non può superare i 30 caratteri");
    }

    // Controllo caratteri ammessi
    final regex = RegExp(r"^[a-zA-ZÀ-ÿ\s'\-]+$");
    if (!regex.hasMatch(trimmedName)) {
      return ValidationResult.error("Il nome contiene caratteri non validi");
    }

    // Controllo parole offensive (base)
    final offensiveWords = ['test', 'debug']; // Lista di esempio
    final lowerName = trimmedName.toLowerCase();
    for (var word in offensiveWords) {
      if (lowerName.contains(word)) {
        return ValidationResult.error("Il nome contiene parole non appropriate");
      }
    }

    List<String> warnings = [];

    // Avvisi
    if (trimmedName.length < 3) {
      warnings.add("Il nome è molto corto");
    }

    if (trimmedName.split(' ').length > 3) {
      warnings.add("Il nome è molto lungo");
    }

    AppLogger.debug("Nome validato: '$trimmedName'");
    return ValidationResult.success(warnings: warnings);
  }

  /// Valida le caratteristiche
  static ValidationResult validateCharacteristics(Map<String, int> characteristics) {
    const validAbilities = ['FOR', 'DES', 'COS', 'INT', 'SAG', 'CAR'];
    const minValue = 3;
    const maxValue = 20;

    // Verifica che tutte le caratteristiche siano presenti
    for (var ability in validAbilities) {
      if (!characteristics.containsKey(ability)) {
        return ValidationResult.error("Manca la caratteristica $ability");
      }

      final value = characteristics[ability]!;
      if (value < minValue) {
        return ValidationResult.error("$ability non può essere inferiore a $minValue");
      }

      if (value > maxValue) {
        return ValidationResult.error("$ability non può essere superiore a $maxValue");
      }
    }

    List<String> warnings = [];

    // Verifica valori molto bassi
    characteristics.forEach((key, value) {
      if (value <= 8) {
        warnings.add("$key ha un valore molto basso ($value)");
      }
      if (value >= 18) {
        warnings.add("$key ha un valore molto alto ($value)");
      }
    });

    // Verifica distribuzione equilibrata
    final values = characteristics.values.toList()..sort();
    final lowest = values.first;
    final highest = values.last;

    if (highest - lowest > 10) {
      warnings.add("Le caratteristiche sono molto sbilanciate");
    }

    AppLogger.debug("Caratteristiche validate: $characteristics");
    return ValidationResult.success(warnings: warnings);
  }

  /// Valida il livello
  static ValidationResult validateLevel(int level) {
    const minLevel = 1;
    const maxLevel = 20;

    if (level < minLevel) {
      return ValidationResult.error("Il livello minimo è $minLevel");
    }

    if (level > maxLevel) {
      return ValidationResult.error("Il livello massimo è $maxLevel");
    }

    List<String> warnings = [];

    if (level == 1) {
      warnings.add("Personaggio di primo livello - considera di aumentare il livello");
    }

    if (level >= 15) {
      warnings.add("Personaggio di alto livello - assicurati di gestire correttamente le abilità avanzate");
    }

    AppLogger.debug("Livello validato: $level");
    return ValidationResult.success(warnings: warnings);
  }

  /// Valida la selezione delle abilità
  static ValidationResult validateAbilitySelection(
    List<String> selectedAbilities,
    List<String> availableAbilities,
    int requiredCount,
  ) {
    if (selectedAbilities.length != requiredCount) {
      return ValidationResult.error(
        "Seleziona esattamente $requiredCount abilità (attualmente: ${selectedAbilities.length})"
      );
    }

    // Verifica che tutte le abilità selezionate siano disponibili
    for (var ability in selectedAbilities) {
      if (!availableAbilities.contains(ability)) {
        return ValidationResult.error("L'abilità '$ability' non è disponibile per questa classe");
      }
    }

    // Verifica duplicati
    final uniqueAbilities = selectedAbilities.toSet();
    if (uniqueAbilities.length != selectedAbilities.length) {
      return ValidationResult.error("Non puoi selezionare la stessa abilità più volte");
    }

    List<String> warnings = [];

    // Suggerimenti basati sulla classe (da implementare)
    AppLogger.debug("Abilità validate: $selectedAbilities");
    return ValidationResult.success(warnings: warnings);
  }

  /// Valida l'equipaggiamento
  static ValidationResult validateEquipment(List<String> equipment) {
    if (equipment.isEmpty) {
      return ValidationResult.success(warnings: ["Nessun equipaggiamento selezionato"]);
    }

    List<String> warnings = [];

    // Verifica duplicati
    final uniqueItems = equipment.toSet();
    if (uniqueItems.length != equipment.length) {
      warnings.add("Ci sono oggetti duplicati nell'equipaggiamento");
    }

    // Verifica peso totale (da implementare con database equipaggiamento)
    if (equipment.length > 20) {
      warnings.add("Molti oggetti nell'equipaggiamento - controlla il peso totale");
    }

    AppLogger.debug("Equipaggiamento validato: ${equipment.length} oggetti");
    return ValidationResult.success(warnings: warnings);
  }

  /// Valida un personaggio completo
  static ValidationResult validateCompleteCharacter(
    String nome,
    String specie,
    String classe,
    int livello,
    Map<String, int> caratteristiche,
    List<String> abilita,
    List<String> equipaggiamento,
  ) {
    List<String> errors = [];
    List<String> warnings = [];

    // Validazioni individuali
    final nameResult = validateCharacterName(nome);
    if (!nameResult.isValid) {
      errors.add("Nome: ${nameResult.errorMessage}");
    }
    warnings.addAll(nameResult.warnings.map((w) => "Nome: $w"));

    final levelResult = validateLevel(livello);
    if (!levelResult.isValid) {
      errors.add("Livello: ${levelResult.errorMessage}");
    }
    warnings.addAll(levelResult.warnings.map((w) => "Livello: $w"));

    final charResult = validateCharacteristics(caratteristiche);
    if (!charResult.isValid) {
      errors.add("Caratteristiche: ${charResult.errorMessage}");
    }
    warnings.addAll(charResult.warnings.map((w) => "Caratteristiche: $w"));

    final equipResult = validateEquipment(equipaggiamento);
    if (!equipResult.isValid) {
      errors.add("Equipaggiamento: ${equipResult.errorMessage}");
    }
    warnings.addAll(equipResult.warnings.map((w) => "Equipaggiamento: $w"));

    // Validazioni tra campi
    if (specie.isEmpty) {
      errors.add("Devi selezionare una specie");
    }

    if (classe.isEmpty) {
      errors.add("Devi selezionare una classe");
    }

    if (errors.isNotEmpty) {
      AppLogger.warning("Validazione personaggio fallita: ${errors.join(', ')}");
      return ValidationResult.error(errors.first, warnings: warnings);
    }

    AppLogger.info("Personaggio validato con successo");
    return ValidationResult.success(warnings: warnings);
  }
}