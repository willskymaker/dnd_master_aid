// lib/data/db_equip.dart

import 'db_classi.dart';

/// Alcune classi hanno competenze su armi specifiche (non l'intera
/// categoria "semplici"/"da guerra"), elencate in db_classi.dart con il
/// nome italiano dell'arma al plurale (es. "Spade corte"). Mappa quei nomi
/// al nome inglese stabile dell'arma corrispondente in equipment.json, per
/// poter derivare le classi consigliate anche per il catalogo importato.
const Map<String, String> _aliasCompetenzaArma = {
  'Balestre leggere': 'Crossbow, light',
  'Balestre a mano': 'Crossbow, hand',
  'Spade corte': 'Shortsword',
  'Spade lunghe': 'Longsword',
  'Stocchi': 'Rapier',
  'Bastoni': 'Quarterstaff',
  'Bastoni ferrati': 'Quarterstaff',
  'Fionde': 'Sling',
  'Lance': 'Spear',
  'Pugnali': 'Dagger',
  'Falci': 'Sickle',
  'Mazze': 'Mace',
  'Dardi': 'Dart',
};

bool _classeCompetenteArma(Classe classe, String categoria, String nomeArma) {
  final generica =
      categoria.startsWith('simple') ? 'Armi semplici' : 'Armi da guerra';
  if (classe.competenzeArmi.contains(generica)) return true;
  return classe.competenzeArmi.any((c) => _aliasCompetenzaArma[c] == nomeArma);
}

/// Classi consigliate per un'arma importata da equipment.json, derivate
/// dalle competenze d'arma di ciascuna classe in db_classi.dart.
List<String> classiConsigliatePerArma(String categoria, String nomeArma) =>
    classiList
        .where((c) => _classeCompetenteArma(c, categoria, nomeArma))
        .map((c) => c.nome)
        .toList();

bool _classeCompetenteArmatura(Classe classe, String categoria) {
  switch (categoria) {
    case 'light':
      return classe.competenzeArmature.any((c) => c.startsWith('Leggere')) ||
          classe.competenzeArmature.contains('Tutte le armature');
    case 'medium':
      return classe.competenzeArmature.any((c) => c.startsWith('Medie')) ||
          classe.competenzeArmature.contains('Tutte le armature');
    case 'heavy':
      return classe.competenzeArmature.contains('Tutte le armature');
    case 'shields':
      return classe.competenzeArmature.any((c) => c.startsWith('Scudi'));
    default:
      return false;
  }
}

/// Classi consigliate per un'armatura importata da equipment.json, derivate
/// dalle competenze d'armatura di ciascuna classe in db_classi.dart.
List<String> classiConsigliatePerArmatura(String categoria) =>
    classiList
        .where((c) => _classeCompetenteArmatura(c, categoria))
        .map((c) => c.nome)
        .toList();

/// Pacchetti di equipaggiamento (kit): la scelta e' legata all'opzione
/// offerta a inizio partita da ciascuna classe nel PHB, non a una
/// competenza vera e propria - non deriva quindi da db_classi.dart ma da
/// una mappa curata a mano, come per gli oggetti sotto in questo file.
const Map<String, List<String>> _classiPerPacco = {
  "Burglar's Pack": ["Ladro"],
  "Diplomat's Pack": ["Bardo"],
  "Dungeoneer's Pack": [
    "Guerriero",
    "Monaco",
    "Ranger",
    "Ladro",
    "Stregone",
    "Warlock",
  ],
  "Entertainer's Pack": ["Bardo"],
  "Explorer's Pack": [
    "Barbaro",
    "Chierico",
    "Druido",
    "Guerriero",
    "Monaco",
    "Paladino",
    "Ranger",
    "Ladro",
    "Stregone",
    "Mago",
  ],
  "Priest's Pack": ["Chierico", "Paladino"],
  "Scholar's Pack": ["Mago", "Warlock"],
};

/// Classi consigliate per un pacco importato da equipment.json (chiave:
/// nome inglese stabile, es. "Priest's Pack").
List<String> classiConsigliatePerKit(String nomeInglese) =>
    _classiPerPacco[nomeInglese] ?? const [];

/// Classi consigliate per uno strumento importato da equipment.json.
/// Gli strumenti musicali sono competenza del Bardo (tre a scelta) e del
/// Monaco (uno a scelta); gli attrezzi da scasso/erboristeria ricalcano le
/// competenze specifiche di db_classi.dart. Gli strumenti puramente
/// artigianali (falegname, fabbro, ecc.) non sono legati a nessuna classe
/// in particolare e restano disponibili per tutti.
List<String> classiConsigliatePerStrumento(String nomeInglese) {
  if (nomeInglese.startsWith('Musical instrument')) {
    return const ['Bardo', 'Monaco'];
  }
  switch (nomeInglese) {
    case "Thieves' tools":
    case 'Disguise kit':
    case 'Forgery kit':
    case "Poisoner's kit":
      return const ['Ladro'];
    case 'Herbalism kit':
      return const ['Druido', 'Ranger'];
    default:
      return const [];
  }
}

class OggettoEquip {
  final String nome;
  final String tipo; // "arma", "armatura", "oggetto"
  final String
  categoria; // es: "leggera", "media", "pesante", "da guerra", "comune", ecc.
  final String descrizione;
  final String proprieta; // [versatile, magico]
  final String? danno; // es: "1d8", "1d10", oppure null per oggetti e armature
  final double costoMO;
  final double pesoKg;
  final List<String> classiConsigliate;

  OggettoEquip({
    required this.nome,
    required this.tipo,
    required this.categoria,
    required this.descrizione,
    required this.proprieta,
    required this.costoMO,
    required this.pesoKg,
    this.danno,
    this.classiConsigliate = const [],
  });

  factory OggettoEquip.fromWeaponJson(
    Map<String, dynamic> json,
    String weaponType,
  ) {
    return OggettoEquip(
      nome: json['italian_name'] ?? json['name'] ?? '',
      tipo: 'arma',
      categoria: weaponType,
      descrizione: json['damage_type'] ?? '',
      proprieta: (json['properties'] as List?)?.join(', ') ?? '',
      danno: json['damage'],
      costoMO: _parseCost(json['cost']),
      pesoKg: _parseWeight(json['weight']),
      classiConsigliate: classiConsigliatePerArma(
        weaponType,
        json['name'] ?? '',
      ),
    );
  }

  factory OggettoEquip.fromArmorJson(
    Map<String, dynamic> json,
    String armorType,
  ) {
    return OggettoEquip(
      nome: json['italian_name'] ?? json['name'] ?? '',
      tipo: 'armatura',
      categoria: armorType,
      descrizione: json['armor_class'] ?? '',
      proprieta: (json['properties'] as List?)?.join(', ') ?? '',
      danno: null,
      costoMO: _parseCost(json['cost']),
      pesoKg: _parseWeight(json['weight']),
      classiConsigliate: classiConsigliatePerArmatura(armorType),
    );
  }

  factory OggettoEquip.fromKitJson(Map<String, dynamic> json) {
    final contents = (json['contents'] as List?)?.join(', ') ?? '';
    return OggettoEquip(
      nome: json['italian_name'] ?? json['name'] ?? '',
      tipo: 'oggetto',
      categoria: 'kit',
      descrizione: contents,
      proprieta: '',
      danno: null,
      costoMO: _parseCost(json['cost']),
      pesoKg: 0,
      classiConsigliate: classiConsigliatePerKit(json['name'] ?? ''),
    );
  }

  factory OggettoEquip.fromToolJson(Map<String, dynamic> json) {
    return OggettoEquip(
      nome: json['italian_name'] ?? json['name'] ?? '',
      tipo: 'oggetto',
      categoria: 'strumento',
      descrizione: json['description'] ?? '',
      proprieta: '',
      danno: null,
      costoMO: _parseCost(json['cost']),
      pesoKg: _parseWeight(json['weight']),
      classiConsigliate: classiConsigliatePerStrumento(json['name'] ?? ''),
    );
  }

  static double _parseCost(dynamic cost) {
    if (cost == null) return 0;
    final parts = cost.toString().replaceAll(',', '').split(' ');
    if (parts.length < 2) return 0;
    final value = double.tryParse(parts[0]) ?? 0;
    switch (parts[1].toLowerCase()) {
      case 'gp':
        return value;
      case 'sp':
        return value / 10;
      case 'cp':
        return value / 100;
      default:
        return value;
    }
  }

  static double _parseWeight(dynamic weight) {
    if (weight == null) return 0;
    final lb =
        double.tryParse(weight.toString().replaceAll(',', '').split(' ')[0]) ??
        0;
    return lb * 0.453592;
  }
}

final List<OggettoEquip> oggettiEquipList = [
  OggettoEquip(
    nome: "Spada lunga",
    tipo: "arma",
    categoria: "da guerra",
    descrizione: "Un'arma versatile che può essere impugnata a una o due mani.",
    proprieta: "versatile, tagliente",
    danno: "1d8 / 1d10",
    costoMO: 15,
    pesoKg: 1.5,
    classiConsigliate: ["Guerriero", "Paladino", "Ranger"],
  ),
  OggettoEquip(
    nome: "Arco lungo",
    tipo: "arma",
    categoria: "da guerra",
    descrizione: "Arma a distanza con gittata lunga.",
    proprieta: "a due mani, distanza (45/180)",
    danno: "1d8",
    costoMO: 50,
    pesoKg: 1.8,
    classiConsigliate: ["Ranger", "Guerriero"],
  ),
  OggettoEquip(
    nome: "Giaco di maglia",
    tipo: "armatura",
    categoria: "media",
    descrizione:
        "CA base 14 + Des (max 2). Richiede competenza in armature medie.",
    proprieta: "rumorosa",
    danno: null,
    costoMO: 50,
    pesoKg: 10.0,
    classiConsigliate: ["Guerriero", "Chierico", "Ranger"],
  ),
  OggettoEquip(
    nome: "Scudo",
    tipo: "armatura",
    categoria: "scudo",
    descrizione: "+2 alla Classe Armatura se impugnato.",
    proprieta: "richiede mano libera",
    danno: null,
    costoMO: 10,
    pesoKg: 3.0,
    classiConsigliate: ["Paladino", "Chierico", "Guerriero"],
  ),
  OggettoEquip(
    nome: "Corda di canapa (15 metri)",
    tipo: "oggetto",
    categoria: "comune",
    descrizione: "Resistente e utile per scalate, legature o trappole.",
    proprieta: "non magico",
    danno: null,
    costoMO: 1,
    pesoKg: 4.5,
    classiConsigliate: [],
  ),
  OggettoEquip(
    nome: "Pugnale",
    tipo: "arma",
    categoria: "semplice",
    descrizione:
        "Arma leggera e lanciabile, utile sia in corpo a corpo che a distanza.",
    proprieta: "leggera, finesse, lancio (6/18)",
    danno: "1d4",
    costoMO: 2,
    pesoKg: 0.5,
    classiConsigliate: ["Ladro", "Stregone", "Bardo"],
  ),
  OggettoEquip(
    nome: "Fionda",
    tipo: "arma",
    categoria: "semplice",
    descrizione: "Piccola arma a distanza, richiede sassi o proiettili.",
    proprieta: "distanza (9/36)",
    danno: "1d4",
    costoMO: 0,
    pesoKg: 0.2,
    classiConsigliate: ["Druido", "Mago"],
  ),
  OggettoEquip(
    nome: "Bastone ferrato",
    tipo: "arma",
    categoria: "semplice",
    descrizione:
        "Arma da mischia comune, spesso usata anche come supporto per la camminata.",
    proprieta: "versatile",
    danno: "1d6 / 1d8",
    costoMO: 0,
    pesoKg: 2.0,
    classiConsigliate: ["Mago", "Monaco", "Druido"],
  ),
  OggettoEquip(
    nome: "Armatura di cuoio",
    tipo: "armatura",
    categoria: "leggera",
    descrizione: "CA = 11 + modificatore di Destrezza.",
    proprieta: "silenziosa",
    danno: null,
    costoMO: 10,
    pesoKg: 4.0,
    classiConsigliate: ["Ladro", "Bardo", "Stregone"],
  ),
  OggettoEquip(
    nome: "Zaino",
    tipo: "oggetto",
    categoria: "comune",
    descrizione: "Contenitore standard per trasportare altri oggetti.",
    proprieta: "può contenere fino a 15 kg",
    danno: null,
    costoMO: 2,
    pesoKg: 2.0,
    classiConsigliate: [],
  ),
  OggettoEquip(
    nome: "Martello da guerra",
    tipo: "arma",
    categoria: "da guerra",
    descrizione: "Arma versatile a una o due mani.",
    proprieta: "versatile, contundente",
    danno: "1d8 / 1d10",
    costoMO: 15,
    pesoKg: 2.5,
    classiConsigliate: ["Chierico", "Paladino"],
  ),
  OggettoEquip(
    nome: "Ascia bipenne",
    tipo: "arma",
    categoria: "da guerra",
    descrizione: "Arma a due mani molto potente.",
    proprieta: "a due mani, tagliente",
    danno: "1d12",
    costoMO: 30,
    pesoKg: 3.5,
    classiConsigliate: ["Barbaro", "Guerriero"],
  ),
  OggettoEquip(
    nome: "Armatura a piastre",
    tipo: "armatura",
    categoria: "pesante",
    descrizione: "CA 18. Richiede competenza e Forza 15.",
    proprieta: "rumorosa, Svantaggio a Furtività",
    danno: null,
    costoMO: 1500,
    pesoKg: 29.5,
    classiConsigliate: ["Paladino", "Guerriero"],
  ),
  OggettoEquip(
    nome: "Lanterna a campana",
    tipo: "oggetto",
    categoria: "comune",
    descrizione: "Produce luce in un raggio di 18 metri. Richiede olio.",
    proprieta: "luce, richiede manutenzione",
    danno: null,
    costoMO: 5,
    pesoKg: 1.0,
    classiConsigliate: [],
  ),
  OggettoEquip(
    nome: "Razioni (1 giorno)",
    tipo: "oggetto",
    categoria: "comune",
    descrizione: "Cibo secco per sopravvivere un giorno.",
    proprieta: "consumabile",
    danno: null,
    costoMO: 0.5,
    pesoKg: 1.0,
    classiConsigliate: [],
  ),
  OggettoEquip(
    nome: "Borraccia",
    tipo: "oggetto",
    categoria: "comune",
    descrizione: "Contiene fino a 2 litri di liquido.",
    proprieta: "essenziale per viaggi",
    danno: null,
    costoMO: 1,
    pesoKg: 1.5,
    classiConsigliate: [],
  ),
  OggettoEquip(
    nome: "Tenda piccola",
    tipo: "oggetto",
    categoria: "comune",
    descrizione: "Fornisce riparo per 2 persone.",
    proprieta: "montabile, non magico",
    danno: null,
    costoMO: 10,
    pesoKg: 9.0,
    classiConsigliate: [],
  ),
  OggettoEquip(
    nome: "Balestra leggera",
    tipo: "arma",
    categoria: "semplice",
    descrizione: "Arma a distanza. Richiede un'azione per ricaricare.",
    proprieta: "distanza (24/96), ricarica, a due mani",
    danno: "1d8",
    costoMO: 25,
    pesoKg: 4.5,
    classiConsigliate: ["Ladro", "Guerriero"],
  ),
  OggettoEquip(
    nome: "Frusta",
    tipo: "arma",
    categoria: "da guerra",
    descrizione: "Arma a portata con danni taglienti.",
    proprieta: "portata, finesse",
    danno: "1d4",
    costoMO: 2,
    pesoKg: 1.5,
    classiConsigliate: ["Ladro", "Bardo"],
  ),
  OggettoEquip(
    nome: "Armatura di scaglie",
    tipo: "armatura",
    categoria: "media",
    descrizione: "CA base 14 + Des (max 2), impone svantaggio a Furtività.",
    proprieta: "rumorosa, richiede competenza",
    danno: null,
    costoMO: 50,
    pesoKg: 20.0,
    classiConsigliate: ["Chierico", "Ranger"],
  ),
  OggettoEquip(
    nome: "Torcia",
    tipo: "oggetto",
    categoria: "comune",
    descrizione: "Produce luce per 6 metri, brucia per 1 ora.",
    proprieta: "consumabile, luce",
    danno: null,
    costoMO: 0.01,
    pesoKg: 0.5,
    classiConsigliate: [],
  ),
  OggettoEquip(
    nome: "Piedi di porco",
    tipo: "oggetto",
    categoria: "comune",
    descrizione: "Vantaggio alle prove di Forza per forzare.",
    proprieta: "strumento",
    danno: null,
    costoMO: 2,
    pesoKg: 2.0,
    classiConsigliate: ["Ladro", "Guerriero"],
  ),
  OggettoEquip(
    nome: "Attrezzi da ladro",
    tipo: "oggetto",
    categoria: "strumento",
    descrizione: "Grimaldelli e attrezzi da scasso.",
    proprieta: "richiede competenza",
    danno: null,
    costoMO: 25,
    pesoKg: 0.5,
    classiConsigliate: ["Ladro"],
  ),
  OggettoEquip(
    nome: "Pozione di guarigione",
    tipo: "oggetto",
    categoria: "magico",
    descrizione: "Ripristina 2d4+2 PF.",
    proprieta: "consumabile, magico",
    danno: null,
    costoMO: 50,
    pesoKg: 0.5,
    classiConsigliate: [],
  ),
  OggettoEquip(
    nome: "Liuto da bardo",
    tipo: "oggetto",
    categoria: "strumento musicale",
    descrizione: "Strumento magico per Ispirazione Bardica.",
    proprieta: "musicale, fragile",
    danno: null,
    costoMO: 35,
    pesoKg: 1.5,
    classiConsigliate: ["Bardo"],
  ),
  OggettoEquip(
    nome: "Kit da erborista",
    tipo: "oggetto",
    categoria: "strumento",
    descrizione: "Utile per creare pozioni e veleni naturali.",
    proprieta: "richiede competenza",
    danno: null,
    costoMO: 5,
    pesoKg: 1.0,
    classiConsigliate: ["Druido", "Ranger"],
  ),
];
