import 'dart:convert';
import 'package:flutter/services.dart';
import '../core/logger.dart';
import '../data/db_specie.dart';
import '../data/db_classi.dart';
import '../data/db_incantesimi.dart';

/// Repository per gestire dati JSON da assets
class JsonDataRepository {
  // Cache per i dati caricati
  static Map<String, dynamic>? _cachedSpecies;
  static Map<String, dynamic>? _cachedClasses;
  static Map<String, dynamic>? _cachedSpells;

  /// Carica le specie dal file JSON
  static Future<List<Specie>> loadSpecies() async {
    if (_cachedSpecies == null) {
      AppLogger.info("Caricando specie da JSON");
      final String jsonString = await rootBundle.loadString('assets/data/species.json');
      _cachedSpecies = json.decode(jsonString);
    }

    final List<dynamic> speciesData = _cachedSpecies!['species'];
    final List<Specie> species = [];

    for (var data in speciesData) {
      try {
        final specie = _parseSpecieFromJson(data);
        species.add(specie);

        // Aggiungi sottospecie se presenti
        if (data['sottospecie'] != null) {
          final List<dynamic> sottospecie = data['sottospecie'];
          final List<Specie> subSpecies = sottospecie.map((sub) => _parseSubspecieFromJson(sub, data)).toList();
          // Per ora aggiungiamo le sottospecie come specie separate
          species.addAll(subSpecies);
        }
      } catch (e) {
        AppLogger.error("Errore nel parsing della specie: ${data['nome']}", e);
      }
    }

    AppLogger.info("Caricate ${species.length} specie dal JSON");
    return species;
  }

  /// Carica le classi dal file JSON
  static Future<List<Classe>> loadClasses() async {
    if (_cachedClasses == null) {
      AppLogger.info("Caricando classi da JSON");
      final String jsonString = await rootBundle.loadString('assets/data/classes.json');
      _cachedClasses = json.decode(jsonString);
    }

    final List<dynamic> classesData = _cachedClasses!['classes'];
    final List<Classe> classes = [];

    for (var data in classesData) {
      try {
        final classe = _parseClasseFromJson(data);
        classes.add(classe);
      } catch (e) {
        AppLogger.error("Errore nel parsing della classe: ${data['nome']}", e);
      }
    }

    AppLogger.info("Caricate ${classes.length} classi dal JSON");
    return classes;
  }

  /// Carica gli incantesimi dal file JSON
  static Future<List<Incantesimo>> loadSpells() async {
    if (_cachedSpells == null) {
      AppLogger.info("Caricando incantesimi da JSON");
      final String jsonString = await rootBundle.loadString('assets/data/spells.json');
      _cachedSpells = json.decode(jsonString);
    }

    final List<dynamic> spellsData = _cachedSpells!['spells'];
    final List<Incantesimo> spells = [];

    for (var data in spellsData) {
      try {
        final incantesimo = _parseIncantesimoFromJson(data);
        spells.add(incantesimo);
      } catch (e) {
        AppLogger.error("Errore nel parsing dell'incantesimo: ${data['nome']}", e);
      }
    }

    AppLogger.info("Caricati ${spells.length} incantesimi dal JSON");
    return spells;
  }

  /// Converte dati JSON in oggetto Specie
  static Specie _parseSpecieFromJson(Map<String, dynamic> data) {
    return Specie(
      nome: data['nome'] ?? '',
      descrizione: data['descrizione'] ?? '',
      velocita: data['velocita'] ?? 30,
      competenze: List<String>.from(data['competenze'] ?? []),
      resistenze: List<String>.from(data['resistenze'] ?? []),
      abilitaInnate: List<String>.from(data['abilitaInnate'] ?? []),
      linguaggi: List<String>.from(data['linguaggi'] ?? []),
      personalizzazionePunteggi: data['personalizzazionePunteggi'] ?? true,
    );
  }

  /// Converte dati JSON sottospecie in oggetto Specie
  static Specie _parseSubspecieFromJson(Map<String, dynamic> subData, Map<String, dynamic> parentData) {
    return Specie(
      nome: "${parentData['nome']} (${subData['nome']})",
      descrizione: subData['descrizione'] ?? parentData['descrizione'],
      velocita: subData['velocita'] ?? parentData['velocita'],
      competenze: List<String>.from(subData['competenze_aggiuntive'] ?? parentData['competenze'] ?? []),
      resistenze: [
        ...List<String>.from(parentData['resistenze'] ?? []),
        ...List<String>.from(subData['resistenze_aggiuntive'] ?? [])
      ],
      abilitaInnate: [
        ...List<String>.from(parentData['abilitaInnate'] ?? []),
        ...List<String>.from(subData['abilitaInnate_aggiuntive'] ?? [])
      ],
      linguaggi: List<String>.from(parentData['linguaggi'] ?? []),
      personalizzazionePunteggi: parentData['personalizzazionePunteggi'] ?? true,
    );
  }

  /// Converte dati JSON in oggetto Classe
  static Classe _parseClasseFromJson(Map<String, dynamic> data) {
    // Parsing delle sottoclassi
    final List<dynamic> sottoclassiData = data['sottoclassi'] ?? [];
    final List<String> sottoclassi = sottoclassiData.map((sub) => sub['nome'] as String).toList();

    return Classe(
      nome: data['nome'] ?? '',
      descrizione: data['descrizione'] ?? '',
      dadoVita: data['dadoVita'] ?? 8,
      competenzeArmi: List<String>.from(data['competenzeArmi'] ?? []),
      competenzeArmature: List<String>.from(data['competenzeArmature'] ?? []),
      competenzeStrumenti: List<String>.from(data['competenzeStrumenti'] ?? []),
      tiriSalvezza: List<String>.from(data['tiriSalvezza'] ?? []),
      abilitaSelezionabili: _parseAbilitaSelezionabili(data['abilitaSelezionabili']),
      abilitaDaSelezionare: data['abilitaDaSelezionare'] ?? 2,
      sottoclassi: sottoclassi,
    );
  }

  /// Gestisce il parsing delle abilità selezionabili (può essere "Tutte" o lista)
  static List<String> _parseAbilitaSelezionabili(dynamic abilitaData) {
    if (abilitaData is String && abilitaData == "Tutte") {
      // Per il Bardo che può scegliere da tutte le abilità
      return [
        "Atletica", "Acrobazia", "Furtività", "Rapidità di Mano",
        "Arcano", "Storia", "Investigare", "Natura", "Religione",
        "Addestrare Animali", "Intuizione", "Medicina", "Percezione", "Sopravvivenza",
        "Inganno", "Intimidire", "Intrattenere", "Persuasione"
      ];
    }
    return List<String>.from(abilitaData ?? []);
  }

  /// Converte dati JSON in oggetto Incantesimo
  static Incantesimo _parseIncantesimoFromJson(Map<String, dynamic> data) {
    return Incantesimo(
      nome: data['nome'] ?? '',
      livello: data['livello'] ?? 0,
      scuola: data['scuola'] ?? '',
      classi: List<String>.from(data['classi'] ?? []),
      descrizione: data['descrizione'] ?? '',
      raggio: data['raggio'] ?? '',
      durata: data['durata'] ?? '',
      tempoLancio: data['tempo_lancio'] ?? '',
      componenti: List<String>.from(data['componenti'] ?? []),
      eTrucchetto: data['eTrucchetto'] ?? false,
    );
  }

  /// Pulisce la cache
  static void clearCache() {
    _cachedSpecies = null;
    _cachedClasses = null;
    _cachedSpells = null;
    AppLogger.info("Cache JSON repository pulita");
  }

  /// Ottiene informazioni sulla versione dei dati
  static Future<Map<String, String>> getDataVersions() async {
    final Map<String, String> versions = {};

    try {
      if (_cachedSpecies == null) {
        final String speciesJson = await rootBundle.loadString('assets/data/species.json');
        _cachedSpecies = json.decode(speciesJson);
      }
      versions['species'] = _cachedSpecies!['version'] ?? 'unknown';

      if (_cachedClasses == null) {
        final String classesJson = await rootBundle.loadString('assets/data/classes.json');
        _cachedClasses = json.decode(classesJson);
      }
      versions['classes'] = _cachedClasses!['version'] ?? 'unknown';

      if (_cachedSpells == null) {
        final String spellsJson = await rootBundle.loadString('assets/data/spells.json');
        _cachedSpells = json.decode(spellsJson);
      }
      versions['spells'] = _cachedSpells!['version'] ?? 'unknown';
    } catch (e) {
      AppLogger.error("Errore nel recupero versioni dati", e);
    }

    return versions;
  }

  /// Cerca specie per nome o descrizione
  static Future<List<Specie>> searchSpecies(String query) async {
    final species = await loadSpecies();
    final lowercaseQuery = query.toLowerCase();

    return species.where((specie) =>
      specie.nome.toLowerCase().contains(lowercaseQuery) ||
      specie.descrizione.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  /// Cerca classi per nome o descrizione
  static Future<List<Classe>> searchClasses(String query) async {
    final classes = await loadClasses();
    final lowercaseQuery = query.toLowerCase();

    return classes.where((classe) =>
      classe.nome.toLowerCase().contains(lowercaseQuery) ||
      classe.descrizione.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  /// Cerca incantesimi con filtri avanzati
  static Future<List<Incantesimo>> searchSpells({
    String? query,
    int? livello,
    String? scuola,
    String? classe,
    bool? soloTrucchetti,
  }) async {
    final spells = await loadSpells();

    return spells.where((incantesimo) {
      // Filtro per query di testo
      if (query != null && query.isNotEmpty) {
        final lowercaseQuery = query.toLowerCase();
        if (!incantesimo.nome.toLowerCase().contains(lowercaseQuery) &&
            !incantesimo.descrizione.toLowerCase().contains(lowercaseQuery)) {
          return false;
        }
      }

      // Filtro per livello
      if (livello != null && incantesimo.livello != livello) {
        return false;
      }

      // Filtro per scuola
      if (scuola != null && incantesimo.scuola != scuola) {
        return false;
      }

      // Filtro per classe
      if (classe != null && !incantesimo.classi.contains(classe)) {
        return false;
      }

      // Filtro per trucchetti
      if (soloTrucchetti != null && incantesimo.eTrucchetto != soloTrucchetti) {
        return false;
      }

      return true;
    }).toList();
  }
}