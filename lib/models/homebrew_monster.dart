import 'package:uuid/uuid.dart';

/// Modello di un mostro homebrew creato dall'utente.
/// Serializzabile in `Map<String, dynamic>` compatibile con il formato
/// monsters.json per l'integrazione con il combat tracker.
class HomebrewMonster {
  final String id; // UUID locale generato alla creazione
  final String nome; // nome in italiano
  final String nomeEn; // nome inglese (opzionale, default = nome)

  // Caratteristiche
  final int forza;
  final int destrezza;
  final int costituzione;
  final int intelligenza;
  final int saggezza;
  final int carisma;

  // Combattimento
  final int ca;
  final int pf;
  final String? dadiVita; // es. "2d8+4"

  // Velocità
  final int velocita; // ft walk

  // Azioni e abilità speciali
  final List<AzioneHomebrew> azioni;
  final List<AbilitaSpecialeHomebrew> abilitaSpeciali;

  // Resistenze e immunità (tipi di danno in inglese)
  final List<String> resistenze;
  final List<String> immunitaDanno;

  // GS e XP
  final String challengeRating; // "0", "1/8", "1/4", "1/2", "1" …
  final int experiencePoints;

  // Tipo e taglia
  final String tipo; // es. "humanoid", "beast", "undead"
  final String
  taglia; // "Tiny", "Small", "Medium", "Large", "Huge", "Gargantuan"

  const HomebrewMonster({
    required this.id,
    required this.nome,
    required this.nomeEn,
    required this.forza,
    required this.destrezza,
    required this.costituzione,
    required this.intelligenza,
    required this.saggezza,
    required this.carisma,
    required this.ca,
    required this.pf,
    this.dadiVita,
    required this.velocita,
    required this.azioni,
    required this.abilitaSpeciali,
    required this.resistenze,
    required this.immunitaDanno,
    required this.challengeRating,
    required this.experiencePoints,
    required this.tipo,
    required this.taglia,
  });

  /// Crea un nuovo [HomebrewMonster] con un ID generato automaticamente.
  factory HomebrewMonster.create({
    required String nome,
    String? nomeEn,
    int forza = 10,
    int destrezza = 10,
    int costituzione = 10,
    int intelligenza = 10,
    int saggezza = 10,
    int carisma = 10,
    int ca = 10,
    int pf = 10,
    String? dadiVita,
    int velocita = 30,
    List<AzioneHomebrew>? azioni,
    List<AbilitaSpecialeHomebrew>? abilitaSpeciali,
    List<String>? resistenze,
    List<String>? immunitaDanno,
    String challengeRating = '1',
    int experiencePoints = 200,
    String tipo = 'humanoid',
    String taglia = 'Medium',
  }) {
    return HomebrewMonster(
      id: const Uuid().v4(),
      nome: nome,
      nomeEn: nomeEn ?? nome,
      forza: forza,
      destrezza: destrezza,
      costituzione: costituzione,
      intelligenza: intelligenza,
      saggezza: saggezza,
      carisma: carisma,
      ca: ca,
      pf: pf,
      dadiVita: dadiVita,
      velocita: velocita,
      azioni: azioni ?? const [],
      abilitaSpeciali: abilitaSpeciali ?? const [],
      resistenze: resistenze ?? const [],
      immunitaDanno: immunitaDanno ?? const [],
      challengeRating: challengeRating,
      experiencePoints: experiencePoints,
      tipo: tipo,
      taglia: taglia,
    );
  }

  // ---------------------------------------------------------------------------
  // JSON persistence (internal format)
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'nome_en': nomeEn,
      'forza': forza,
      'destrezza': destrezza,
      'costituzione': costituzione,
      'intelligenza': intelligenza,
      'saggezza': saggezza,
      'carisma': carisma,
      'ca': ca,
      'pf': pf,
      'dadi_vita': dadiVita,
      'velocita': velocita,
      'azioni': azioni.map((a) => a.toJson()).toList(),
      'abilita_speciali': abilitaSpeciali.map((a) => a.toJson()).toList(),
      'resistenze': resistenze,
      'immunita_danno': immunitaDanno,
      'challenge_rating': challengeRating,
      'experience_points': experiencePoints,
      'tipo': tipo,
      'taglia': taglia,
    };
  }

  factory HomebrewMonster.fromJson(Map<String, dynamic> json) {
    return HomebrewMonster(
      id: json['id'] as String,
      nome: json['nome'] as String,
      nomeEn: json['nome_en'] as String? ?? json['nome'] as String,
      forza: (json['forza'] as num).toInt(),
      destrezza: (json['destrezza'] as num).toInt(),
      costituzione: (json['costituzione'] as num).toInt(),
      intelligenza: (json['intelligenza'] as num).toInt(),
      saggezza: (json['saggezza'] as num).toInt(),
      carisma: (json['carisma'] as num).toInt(),
      ca: (json['ca'] as num).toInt(),
      pf: (json['pf'] as num).toInt(),
      dadiVita: json['dadi_vita'] as String?,
      velocita: (json['velocita'] as num).toInt(),
      azioni:
          (json['azioni'] as List<dynamic>? ?? [])
              .map((e) => AzioneHomebrew.fromJson(e as Map<String, dynamic>))
              .toList(),
      abilitaSpeciali:
          (json['abilita_speciali'] as List<dynamic>? ?? [])
              .map(
                (e) =>
                    AbilitaSpecialeHomebrew.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      resistenze: List<String>.from(json['resistenze'] as List? ?? []),
      immunitaDanno: List<String>.from(json['immunita_danno'] as List? ?? []),
      challengeRating: json['challenge_rating'] as String,
      experiencePoints: (json['experience_points'] as num).toInt(),
      tipo: json['tipo'] as String,
      taglia: json['taglia'] as String,
    );
  }

  // ---------------------------------------------------------------------------
  // Combat-tracker compatible format (mirrors monsters.json schema)
  // ---------------------------------------------------------------------------

  /// Converte il mostro nel formato `Map<String, dynamic>` atteso da
  /// [_aggiungiMostro] nel combat tracker.
  Map<String, dynamic> toTrackerMap() {
    return {
      'name': nomeEn,
      'italian_name': nome,
      'hit_points': pf,
      'armor_class': ca,
      'ability_scores': {
        'strength': forza,
        'dexterity': destrezza,
        'constitution': costituzione,
        'intelligence': intelligenza,
        'wisdom': saggezza,
        'charisma': carisma,
      },
      'speed': {'walk': velocita},
      'challenge_rating': challengeRating,
      'experience_points': experiencePoints,
      'damage_resistances': resistenze,
      'damage_immunities': immunitaDanno,
      // legendary_actions is null → combat tracker treats it as no legendary actions
      'legendary_actions': null,
      'actions':
          azioni
              .map(
                (a) => {
                  'name': a.nome,
                  'description': a.descrizione,
                  'damage': a.danno,
                  'attack_bonus': a.bonusAttacco,
                },
              )
              .toList(),
      'special_abilities':
          abilitaSpeciali
              .map((a) => {'name': a.nome, 'description': a.descrizione})
              .toList(),
      'source': 'Homebrew',
    };
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  HomebrewMonster copyWith({
    String? id,
    String? nome,
    String? nomeEn,
    int? forza,
    int? destrezza,
    int? costituzione,
    int? intelligenza,
    int? saggezza,
    int? carisma,
    int? ca,
    int? pf,
    Object? dadiVita = _sentinel,
    int? velocita,
    List<AzioneHomebrew>? azioni,
    List<AbilitaSpecialeHomebrew>? abilitaSpeciali,
    List<String>? resistenze,
    List<String>? immunitaDanno,
    String? challengeRating,
    int? experiencePoints,
    String? tipo,
    String? taglia,
  }) {
    return HomebrewMonster(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      nomeEn: nomeEn ?? this.nomeEn,
      forza: forza ?? this.forza,
      destrezza: destrezza ?? this.destrezza,
      costituzione: costituzione ?? this.costituzione,
      intelligenza: intelligenza ?? this.intelligenza,
      saggezza: saggezza ?? this.saggezza,
      carisma: carisma ?? this.carisma,
      ca: ca ?? this.ca,
      pf: pf ?? this.pf,
      dadiVita: dadiVita == _sentinel ? this.dadiVita : dadiVita as String?,
      velocita: velocita ?? this.velocita,
      azioni: azioni ?? this.azioni,
      abilitaSpeciali: abilitaSpeciali ?? this.abilitaSpeciali,
      resistenze: resistenze ?? this.resistenze,
      immunitaDanno: immunitaDanno ?? this.immunitaDanno,
      challengeRating: challengeRating ?? this.challengeRating,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      tipo: tipo ?? this.tipo,
      taglia: taglia ?? this.taglia,
    );
  }
}

// Sentinel object used by copyWith to distinguish "not provided" from explicit null.
const Object _sentinel = Object();

// ---------------------------------------------------------------------------
// Sub-models
// ---------------------------------------------------------------------------

class AzioneHomebrew {
  final String nome;
  final String descrizione;
  final String? danno; // es. "1d6+2 slashing"
  final String? bonusAttacco; // es. "+4"

  const AzioneHomebrew({
    required this.nome,
    required this.descrizione,
    this.danno,
    this.bonusAttacco,
  });

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'descrizione': descrizione,
    'danno': danno,
    'bonus_attacco': bonusAttacco,
  };

  factory AzioneHomebrew.fromJson(Map<String, dynamic> json) => AzioneHomebrew(
    nome: json['nome'] as String,
    descrizione: json['descrizione'] as String,
    danno: json['danno'] as String?,
    bonusAttacco: json['bonus_attacco'] as String?,
  );
}

class AbilitaSpecialeHomebrew {
  final String nome;
  final String descrizione;

  const AbilitaSpecialeHomebrew({
    required this.nome,
    required this.descrizione,
  });

  Map<String, dynamic> toJson() => {'nome': nome, 'descrizione': descrizione};

  factory AbilitaSpecialeHomebrew.fromJson(Map<String, dynamic> json) =>
      AbilitaSpecialeHomebrew(
        nome: json['nome'] as String,
        descrizione: json['descrizione'] as String,
      );
}
