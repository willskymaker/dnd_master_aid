import 'package:flutter/foundation.dart';
import '../factory_pg_base.dart';
import '../core/logger.dart';
import '../services/character_service.dart';
import '../services/validation_service.dart';

enum CharacterCreationStep {
  nome,
  specie,
  classe,
  livello,
  caratteristiche,
  abilita,
  equipaggiamento,
  export,
  completed
}

class CharacterProvider extends ChangeNotifier {
  final PGBaseFactory _factory = PGBaseFactory();
  CharacterCreationStep _currentStep = CharacterCreationStep.nome;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasUnsavedChanges = false;

  // Getters
  PGBaseFactory get factory => _factory;
  CharacterCreationStep get currentStep => _currentStep;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasUnsavedChanges => _hasUnsavedChanges;

  bool get canGoNext => _currentStep.index < CharacterCreationStep.completed.index;
  bool get canGoPrevious => _currentStep.index > CharacterCreationStep.nome.index;

  // Character data getters
  String get nome => _factory.build().nome;
  String get specie => _factory.build().specie;
  String get classe => _factory.build().classe;
  int get livello => _factory.build().livello;
  bool get caratteristicheImpostate => _factory.caratteristicheImpostate;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void markUnsavedChanges() {
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void markSaved() {
    _hasUnsavedChanges = false;
    notifyListeners();
  }

  void nextStep() {
    if (canGoNext) {
      _currentStep = CharacterCreationStep.values[_currentStep.index + 1];
      AppLogger.info("Avanzato allo step: ${_currentStep.name}");
      notifyListeners();
    }
  }

  void previousStep() {
    if (canGoPrevious) {
      _currentStep = CharacterCreationStep.values[_currentStep.index - 1];
      AppLogger.info("Tornato allo step: ${_currentStep.name}");
      notifyListeners();
    }
  }

  void goToStep(CharacterCreationStep step) {
    _currentStep = step;
    AppLogger.info("Navigato allo step: ${_currentStep.name}");
    notifyListeners();
  }

  // Character building methods
  void setNome(String nome) {
    try {
      final validation = ValidationService.validateCharacterName(nome);
      if (!validation.isValid) {
        setError(validation.errorMessage!);
        return;
      }

      _factory.setNome(nome.trim());
      markUnsavedChanges();
      AppLogger.debug("Nome impostato: $nome");

      // Mostra avvisi se presenti
      if (validation.warnings.isNotEmpty) {
        AppLogger.warning("Avvisi nome: ${validation.warnings.join(', ')}");
      }
    } catch (e) {
      AppLogger.error("Errore nell'impostare il nome", e);
      setError("Errore nell'impostare il nome: $e");
    }
  }

  void setSpecie(String specie) {
    try {
      _factory.setSpecie(specie);
      markUnsavedChanges();
      AppLogger.debug("Specie impostata: $specie");
    } catch (e) {
      AppLogger.error("Errore nell'impostare la specie", e);
      setError("Errore nell'impostare la specie: $e");
    }
  }

  void setClasse(String classe) {
    try {
      _factory.setClasse(classe);
      markUnsavedChanges();
      AppLogger.debug("Classe impostata: $classe");
    } catch (e) {
      AppLogger.error("Errore nell'impostare la classe", e);
      setError("Errore nell'impostare la classe: $e");
    }
  }

  void setLivello(int livello) {
    try {
      _factory.setLivello(livello);
      markUnsavedChanges();
      AppLogger.debug("Livello impostato: $livello");
    } catch (e) {
      AppLogger.error("Errore nell'impostare il livello", e);
      setError("Errore nell'impostare il livello: $e");
    }
  }

  void setCaratteristiche(Map<String, int> caratteristiche) {
    try {
      final validation = ValidationService.validateCharacteristics(caratteristiche);
      if (!validation.isValid) {
        setError(validation.errorMessage!);
        return;
      }

      _factory.setCaratteristiche(caratteristiche);
      markUnsavedChanges();
      AppLogger.debug("Caratteristiche impostate: $caratteristiche");

      // Mostra avvisi se presenti
      if (validation.warnings.isNotEmpty) {
        AppLogger.warning("Avvisi caratteristiche: ${validation.warnings.join(', ')}");
      }
    } catch (e) {
      AppLogger.error("Errore nell'impostare le caratteristiche", e);
      setError("Errore nell'impostare le caratteristiche: $e");
    }
  }

  void setAbilita(List<String> abilita) {
    try {
      // Validazione con la classe corrente
      if (classe.isNotEmpty) {
        final availableAbilities = CharacterService.getAvailableAbilitiesForClass(classe);
        final requiredCount = CharacterService.getClasseByName(classe)?.abilitaDaSelezionare ?? 0;

        final validation = ValidationService.validateAbilitySelection(
          abilita,
          availableAbilities,
          requiredCount
        );

        if (!validation.isValid) {
          setError(validation.errorMessage!);
          return;
        }
      }

      _factory.setAbilitaClasse(abilita);
      markUnsavedChanges();
      AppLogger.debug("Abilità impostate: $abilita");
    } catch (e) {
      AppLogger.error("Errore nell'impostare le abilità", e);
      setError("Errore nell'impostare le abilità: $e");
    }
  }

  void setEquipaggiamento(List<String> equipaggiamento) {
    try {
      _factory.addEquipaggiamento(equipaggiamento);
      markUnsavedChanges();
      AppLogger.debug("Equipaggiamento impostato: $equipaggiamento");
    } catch (e) {
      AppLogger.error("Errore nell'impostare l'equipaggiamento", e);
      setError("Errore nell'impostare l'equipaggiamento: $e");
    }
  }

  PGBase buildCharacter() {
    try {
      final character = _factory.build();
      markSaved();
      AppLogger.info("Personaggio completato: ${character.nome}");
      return character;
    } catch (e) {
      AppLogger.error("Errore nella costruzione del personaggio", e);
      setError("Errore nella costruzione del personaggio: $e");
      rethrow;
    }
  }

  void reset() {
    // Reimpostare il factory (per ora mantengo la logica esistente)
    _currentStep = CharacterCreationStep.nome;
    _isLoading = false;
    _errorMessage = null;
    _hasUnsavedChanges = false;
    AppLogger.info("Provider reset completato");
    notifyListeners();
  }

  String getStepTitle(CharacterCreationStep step) {
    switch (step) {
      case CharacterCreationStep.nome:
        return "Nome Personaggio";
      case CharacterCreationStep.specie:
        return "Specie";
      case CharacterCreationStep.classe:
        return "Classe";
      case CharacterCreationStep.livello:
        return "Livello";
      case CharacterCreationStep.caratteristiche:
        return "Caratteristiche";
      case CharacterCreationStep.abilita:
        return "Abilità";
      case CharacterCreationStep.equipaggiamento:
        return "Equipaggiamento";
      case CharacterCreationStep.export:
        return "Esportazione";
      case CharacterCreationStep.completed:
        return "Completato";
    }
  }

  double get progress => (_currentStep.index + 1) / CharacterCreationStep.values.length;
}