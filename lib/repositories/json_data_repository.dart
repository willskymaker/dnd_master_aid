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
  static Map<String, dynamic>? _cachedEquipment;
  static Map<String, dynamic>? _cachedBackgrounds;
  static Map<String, dynamic>? _cachedFeats;
  static Map<String, dynamic>? _cachedMonsters;

  /// Carica le specie dal file JSON
  static Future<List<Specie>> loadSpecies() async {
    try {
      if (_cachedSpecies == null) {
        AppLogger.info("Caricando specie da JSON");
        final String jsonString = await rootBundle.loadString('assets/data/species.json');
        _cachedSpecies = json.decode(jsonString);
        AppLogger.info("Specie caricate correttamente dal JSON");
      }
    } catch (e) {
      AppLogger.error("Errore nel caricamento specie da JSON, usando fallback", e);
      // Fallback ai dati hardcoded se il JSON non è disponibile
      return _getHardcodedSpecies();
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
    try {
      if (_cachedClasses == null) {
        AppLogger.info("Caricando classi da JSON");
        final String jsonString = await rootBundle.loadString('assets/data/classes.json');
        _cachedClasses = json.decode(jsonString);
        AppLogger.info("Classi caricate correttamente dal JSON");
      }
    } catch (e) {
      AppLogger.error("Errore nel caricamento classi da JSON, usando fallback", e);
      return _getHardcodedClasses();
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

  /// Carica l'equipaggiamento dal file JSON
  static Future<Map<String, dynamic>> loadEquipment() async {
    if (_cachedEquipment == null) {
      AppLogger.info("Caricando equipaggiamento da JSON");
      final String jsonString = await rootBundle.loadString('assets/data/equipment.json');
      _cachedEquipment = json.decode(jsonString);
    }

    AppLogger.info("Caricato equipaggiamento dal JSON");
    return _cachedEquipment!;
  }

  /// Carica i background dal file JSON
  static Future<List<Map<String, dynamic>>> loadBackgrounds() async {
    if (_cachedBackgrounds == null) {
      AppLogger.info("Caricando background da JSON");
      final String jsonString = await rootBundle.loadString('assets/data/backgrounds.json');
      _cachedBackgrounds = json.decode(jsonString);
    }

    final List<dynamic> backgroundsData = _cachedBackgrounds!['backgrounds'];
    final List<Map<String, dynamic>> backgrounds = backgroundsData.cast<Map<String, dynamic>>();

    AppLogger.info("Caricati ${backgrounds.length} background dal JSON");
    return backgrounds;
  }

  /// Carica i talenti dal file JSON
  static Future<List<Map<String, dynamic>>> loadFeats() async {
    if (_cachedFeats == null) {
      AppLogger.info("Caricando talenti da JSON");
      final String jsonString = await rootBundle.loadString('assets/data/feats.json');
      _cachedFeats = json.decode(jsonString);
    }

    final List<dynamic> featsData = _cachedFeats!['feats'];
    final List<Map<String, dynamic>> feats = featsData.cast<Map<String, dynamic>>();

    AppLogger.info("Caricati ${feats.length} talenti dal JSON");
    return feats;
  }

  /// Carica i mostri dal file JSON
  static Future<List<Map<String, dynamic>>> loadMonsters() async {
    if (_cachedMonsters == null) {
      AppLogger.info("Caricando mostri da JSON");
      final String jsonString = await rootBundle.loadString('assets/data/monsters.json');
      _cachedMonsters = json.decode(jsonString);
    }

    final List<dynamic> monstersData = _cachedMonsters!['monsters'];
    final List<Map<String, dynamic>> monsters = monstersData.cast<Map<String, dynamic>>();

    AppLogger.info("Caricati ${monsters.length} mostri dal JSON");
    return monsters;
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
    _cachedEquipment = null;
    _cachedBackgrounds = null;
    _cachedFeats = null;
    _cachedMonsters = null;
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

      if (_cachedEquipment == null) {
        final String equipmentJson = await rootBundle.loadString('assets/data/equipment.json');
        _cachedEquipment = json.decode(equipmentJson);
      }
      versions['equipment'] = _cachedEquipment!['version'] ?? 'unknown';

      if (_cachedBackgrounds == null) {
        final String backgroundsJson = await rootBundle.loadString('assets/data/backgrounds.json');
        _cachedBackgrounds = json.decode(backgroundsJson);
      }
      versions['backgrounds'] = _cachedBackgrounds!['version'] ?? 'unknown';

      if (_cachedFeats == null) {
        final String featsJson = await rootBundle.loadString('assets/data/feats.json');
        _cachedFeats = json.decode(featsJson);
      }
      versions['feats'] = _cachedFeats!['version'] ?? 'unknown';

      if (_cachedMonsters == null) {
        final String monstersJson = await rootBundle.loadString('assets/data/monsters.json');
        _cachedMonsters = json.decode(monstersJson);
      }
      versions['monsters'] = _cachedMonsters!['version'] ?? 'unknown';
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

  /// Cerca background per nome o descrizione
  static Future<List<Map<String, dynamic>>> searchBackgrounds(String query) async {
    final backgrounds = await loadBackgrounds();
    final lowercaseQuery = query.toLowerCase();

    return backgrounds.where((background) {
      final name = background['name']?.toLowerCase() ?? '';
      final italianName = background['italian_name']?.toLowerCase() ?? '';
      final description = background['description']?.toLowerCase() ?? '';

      return name.contains(lowercaseQuery) ||
             italianName.contains(lowercaseQuery) ||
             description.contains(lowercaseQuery);
    }).toList();
  }

  /// Cerca talenti per nome o descrizione
  static Future<List<Map<String, dynamic>>> searchFeats(String query) async {
    final feats = await loadFeats();
    final lowercaseQuery = query.toLowerCase();

    return feats.where((feat) {
      final name = feat['name']?.toLowerCase() ?? '';
      final italianName = feat['italian_name']?.toLowerCase() ?? '';
      final description = feat['description']?.toLowerCase() ?? '';

      return name.contains(lowercaseQuery) ||
             italianName.contains(lowercaseQuery) ||
             description.contains(lowercaseQuery);
    }).toList();
  }

  /// Cerca mostri con filtri
  static Future<List<Map<String, dynamic>>> searchMonsters({
    String? query,
    String? size,
    String? type,
    String? challengeRating,
  }) async {
    final monsters = await loadMonsters();

    return monsters.where((monster) {
      // Filtro per query di testo
      if (query != null && query.isNotEmpty) {
        final lowercaseQuery = query.toLowerCase();
        final name = monster['name']?.toLowerCase() ?? '';
        final italianName = monster['italian_name']?.toLowerCase() ?? '';

        if (!name.contains(lowercaseQuery) && !italianName.contains(lowercaseQuery)) {
          return false;
        }
      }

      // Filtro per taglia
      if (size != null && monster['size'] != size) {
        return false;
      }

      // Filtro per tipo
      if (type != null && !monster['type'].toString().contains(type)) {
        return false;
      }

      // Filtro per grado di sfida
      if (challengeRating != null && monster['challenge_rating'] != challengeRating) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Cerca equipaggiamento per categoria
  static Future<List<Map<String, dynamic>>> searchEquipment({
    String? query,
    String? category, // 'weapons', 'armor', 'adventuring_gear', 'tools', 'kits'
    String? weaponType, // 'simple_melee', 'simple_ranged', 'martial_melee', 'martial_ranged'
    String? armorType, // 'light', 'medium', 'heavy', 'shields'
  }) async {
    final equipment = await loadEquipment();
    final List<Map<String, dynamic>> results = [];

    // Cerca in tutte le categorie se non specificata
    List<String> categoriesToSearch = [];
    if (category != null) {
      categoriesToSearch = [category];
    } else {
      categoriesToSearch = ['weapons', 'armor', 'adventuring_gear', 'tools', 'kits'];
    }

    for (String cat in categoriesToSearch) {
      if (equipment.containsKey(cat)) {
        if (cat == 'weapons' && weaponType != null) {
          // Cerca solo nel tipo di arma specificato
          if (equipment[cat].containsKey(weaponType)) {
            final List<dynamic> items = equipment[cat][weaponType];
            results.addAll(_filterEquipmentItems(items.cast<Map<String, dynamic>>(), query, cat));
          }
        } else if (cat == 'armor' && armorType != null) {
          // Cerca solo nel tipo di armatura specificato
          if (equipment[cat].containsKey(armorType)) {
            final List<dynamic> items = equipment[cat][armorType];
            results.addAll(_filterEquipmentItems(items.cast<Map<String, dynamic>>(), query, cat));
          }
        } else if (cat == 'weapons' || cat == 'armor') {
          // Cerca in tutti i sottotipi
          final Map<String, dynamic> categoryData = equipment[cat];
          for (String subtype in categoryData.keys) {
            final List<dynamic> items = categoryData[subtype];
            results.addAll(_filterEquipmentItems(items.cast<Map<String, dynamic>>(), query, cat));
          }
        } else {
          // Categorie semplici (adventuring_gear, tools, kits)
          final List<dynamic> items = equipment[cat];
          results.addAll(_filterEquipmentItems(items.cast<Map<String, dynamic>>(), query, cat));
        }
      }
    }

    return results;
  }

  /// Filtra gli oggetti dell'equipaggiamento per query
  static List<Map<String, dynamic>> _filterEquipmentItems(
    List<Map<String, dynamic>> items,
    String? query,
    String category
  ) {
    if (query == null || query.isEmpty) {
      return items.map((item) => {...item, 'category': category}).toList();
    }

    final lowercaseQuery = query.toLowerCase();
    return items.where((item) {
      final name = item['name']?.toLowerCase() ?? '';
      final italianName = item['italian_name']?.toLowerCase() ?? '';

      return name.contains(lowercaseQuery) || italianName.contains(lowercaseQuery);
    }).map((item) => {...item, 'category': category}).toList();
  }

  /// Fallback method per specie hardcoded
  static List<Specie> _getHardcodedSpecies() {
    return [
      Specie(
        nome: 'Umano',
        descrizione: 'Versatili e ambiziosi, gli umani sono una delle razze più diffuse.',
        velocita: 30,
        competenze: [],
        resistenze: [],
        abilitaInnate: [],
        linguaggi: ['Comune'],
        personalizzazionePunteggi: true,
      ),
      Specie(
        nome: 'Elfo',
        descrizione: 'Creature magiche ed eleganti con una lunga vita.',
        velocita: 30,
        competenze: ['Percezione'],
        resistenze: [],
        abilitaInnate: ['Scurovisione', 'Sensi Acuti'],
        linguaggi: ['Comune', 'Elfico'],
        personalizzazionePunteggi: false,
      ),
      Specie(
        nome: 'Nano',
        descrizione: 'Robusti guerrieri delle montagne, esperti forgiatori.',
        velocita: 25,
        competenze: [],
        resistenze: ['Veleno'],
        abilitaInnate: ['Scurovisione', 'Resistenza Nanica'],
        linguaggi: ['Comune', 'Nanico'],
        personalizzazionePunteggi: false,
      ),
    ];
  }

  /// Fallback method per classi hardcoded
  static List<Classe> _getHardcodedClasses() {
    return [
      Classe(
        nome: 'Guerriero',
        descrizione: 'Maestro delle armi e della tattica di combattimento.',
        dadoVita: 10,
        competenzeArmi: ['Armi semplici', 'Armi da guerra'],
        competenzeArmature: ['Tutte le armature', 'Scudi'],
        competenzeStrumenti: [],
        tiriSalvezza: ['Forza', 'Costituzione'],
        abilitaSelezionabili: ['Acrobazia', 'Addestrare Animali', 'Atletica', 'Storia', 'Intuizione', 'Intimidire', 'Percezione', 'Sopravvivenza'],
        abilitaDaSelezionare: 2,
        sottoclassi: ['Campione', 'Maestro di Battaglia', 'Cavaliere Mistico'],
      ),
      Classe(
        nome: 'Mago',
        descrizione: 'Studioso delle arti arcane e della magia.',
        dadoVita: 6,
        competenzeArmi: ['Pugnali', 'Dardi', 'Fionde', 'Bastoni ferrati', 'Balestre leggere'],
        competenzeArmature: [],
        competenzeStrumenti: [],
        tiriSalvezza: ['Intelligenza', 'Saggezza'],
        abilitaSelezionabili: ['Arcano', 'Storia', 'Intuizione', 'Investigare', 'Medicina', 'Religione'],
        abilitaDaSelezionare: 2,
        sottoclassi: ['Scuola di Evocazione', 'Scuola di Divinazione', 'Scuola di Incantamento'],
      ),
    ];
  }
}