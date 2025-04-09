// lib/data/db_classi.dart

class Classe {
  final String nome;
  final String descrizione;
  final int dadoVita;
  final List<String> competenzeArmature;
  final List<String> competenzeArmi;
  final List<String> competenzeStrumenti;
  final List<String> tiriSalvezza;
  final List<String> abilitaSelezionabili;
  final int abilitaDaSelezionare;
  final List<String> sottoclassi;

  Classe({
    required this.nome,
    required this.descrizione,
    required this.dadoVita,
    required this.competenzeArmature,
    required this.competenzeArmi,
    required this.competenzeStrumenti,
    required this.tiriSalvezza,
    required this.abilitaSelezionabili,
    required this.abilitaDaSelezionare,
    required this.sottoclassi,
  });
}

final List<Classe> classiList = [
  //Barbaro e rispettive sottoclassi
  Classe(
    nome: "Barbaro",
    descrizione: "Un guerriero brutale spinto dalla furia, specializzato nel combattimento corpo a corpo.",
    dadoVita: 12,
    competenzeArmature: ["Leggere", "Medie", "Scudi"],
    competenzeArmi: ["Armi semplici", "Armi da guerra"],
    competenzeStrumenti: [],
    tiriSalvezza: ["Forza", "Costituzione"],
    abilitaSelezionabili: [
      "Addestrare animali",
      "Atletica",
      "Intimidazione",
      "Natura",
      "Percezione",
      "Sopravvivenza"
    ],
    abilitaDaSelezionare: 2,
    sottoclassi: [
      "Cammino del Berserker",
      "Cammino del Totem",
      "Cammino del Guerriero Selvaggio",
      "Cammino dell'Ancestrale"
    ],
  ),
  //Bardo e rispettive sottoclassi
  Classe(
    nome: "Bardo",
    descrizione: "Artista incantatore che trae potere dalla musica e dalla conoscenza.",
    dadoVita: 8,
    competenzeArmature: ["Leggere"],
    competenzeArmi: ["Armi semplici", "Balestre leggere", "Spade corte", "Spade lunghe", "Stocchi"],
    competenzeStrumenti: ["Tre strumenti musicali a scelta"],
    tiriSalvezza: ["Destrezza", "Carisma"],
    abilitaSelezionabili: [
      "Acrobazia",
      "Addestrare animali",
      "Arcano",
      "Atletica",
      "Furtività",
      "Indagare",
      "Intimidazione",
      "Intrattenere",
      "Intuizione",
      "Medicina",
      "Natura",
      "Percezione",
      "Persuasione",
      "Religione",
      "Sopravvivenza",
      "Storia"
    ],
    abilitaDaSelezionare: 3,
    sottoclassi: [
      "Collegio della Conoscenza",
      "Collegio del Valore",
      "Collegio delle Spade",
      "Collegio della Musica Funesta"
    ],
  ),
  //Chierico e rispettive sottoclassi
  Classe(
    nome: "Chierico",
    descrizione: "Incantatore divino devoto a una divinità, canalizza energia sacra per curare o distruggere.",
    dadoVita: 8,
    competenzeArmature: ["Leggere", "Medie", "Scudi"],
    competenzeArmi: ["Armi semplici"],
    competenzeStrumenti: [],
    tiriSalvezza: ["Saggezza", "Carisma"],
    abilitaSelezionabili: [
      "Intuizione",
      "Medicina",
      "Persuasione",
      "Religione",
      "Storia"
    ],
    abilitaDaSelezionare: 2,
    sottoclassi: [
      "Dominio della Vita",
      "Dominio della Guerra",
      "Dominio della Conoscenza",
      "Dominio della Tempesta",
      "Dominio della Tomba",
      "Dominio dell'Oscurità"
    ],
  ),
  //Druido e rispettive sottoclassi
  Classe(
    nome: "Druido",
    descrizione: "Custode della natura capace di trasformarsi in animali e lanciare incantesimi druidici.",
    dadoVita: 8,
    competenzeArmature: ["Leggere", "Medie", "Scudi (non metallici)"],
    competenzeArmi: ["Bastoni", "Fionde", "Lance", "Pugnali", "Falci", "Mazze", "Bastoni ferrati", "Dardi"],
    competenzeStrumenti: ["Erboristeria"],
    tiriSalvezza: ["Intelligenza", "Saggezza"],
    abilitaSelezionabili: [
      "Intuizione",
      "Medicina",
      "Natura",
      "Percezione",
      "Sopravvivenza",
      "Addestrare animali"
    ],
    abilitaDaSelezionare: 2,
    sottoclassi: [
      "Circolo della Terra",
      "Circolo della Luna",
      "Circolo delle Stelle",
      "Circolo del Fuoco Selvaggio"
    ],
  ),
  //Guerriero e rispettive sottoclassi
  Classe(
    nome: "Guerriero",
    descrizione: "Maestro del combattimento marziale, abile con ogni tipo di arma e tattica.",
    dadoVita: 10,
    competenzeArmature: ["Tutte le armature", "Scudi"],
    competenzeArmi: ["Armi semplici", "Armi da guerra"],
    competenzeStrumenti: [],
    tiriSalvezza: ["Forza", "Costituzione"],
    abilitaSelezionabili: [
      "Acrobazia",
      "Addestrare animali",
      "Atletica",
      "Furtività",
      "Intimidazione",
      "Percezione",
      "Sopravvivenza",
      "Storia"
    ],
    abilitaDaSelezionare: 2,
    sottoclassi: [
      "Campione",
      "Cavaliere Mistico",
      "Maestro di Battaglia",
      "Samurai",
      "Cavaliere dell'Eco"
    ],
  ),
  //Ladro e rispettive sottoclassi
  Classe(
    nome: "Ladro",
    descrizione: "Agile, furtivo e scaltro. Esperto nello scassinare, infiltrarsi e colpire con precisione.",
    dadoVita: 8,
    competenzeArmature: ["Leggere"],
    competenzeArmi: ["Armi semplici", "Balestre leggere", "Spade corte", "Spade lunghe", "Stocchi"],
    competenzeStrumenti: ["Attrezzi da ladro"],
    tiriSalvezza: ["Destrezza", "Intelligenza"],
    abilitaSelezionabili: [
      "Acrobazia",
      "Atletica",
      "Furtività",
      "Indagare",
      "Intimidazione",
      "Intuizione",
      "Percezione",
      "Rapidità di mano",
      "Inganno"
    ],
    abilitaDaSelezionare: 4,
    sottoclassi: [
      "Ladro Gentiluomo",
      "Assassino",
      "Mistificatore Arcano",
      "Cecchino delle Ombre"
    ],
  ),
  //Mago e rispettive sottoclassi
  Classe(
    nome: "Mago",
    descrizione: "Studioso della magia arcana, specializzato in incantesimi di grande potere e versatilità.",
    dadoVita: 6,
    competenzeArmature: [],
    competenzeArmi: ["Pugnali", "Bastoni", "Fionde", "Dardi", "Bastoni ferrati"],
    competenzeStrumenti: [],
    tiriSalvezza: ["Intelligenza", "Saggezza"],
    abilitaSelezionabili: [
      "Arcano",
      "Indagare",
      "Intuizione",
      "Storia",
      "Religione"
    ],
    abilitaDaSelezionare: 2,
    sottoclassi: [
      "Scuola di Abiurazione",
      "Scuola di Evocazione",
      "Scuola di Illusione",
      "Scuola di Necromanzia",
      "Scuola della Cronomanzia"
    ],
  ),
  //Monaco e rispettive sottoclassi
  Classe(
    nome: "Monaco",
    descrizione: "Guerriero spirituale che canalizza l’energia del ki per compiere imprese fisiche sovrumane.",
    dadoVita: 8,
    competenzeArmature: [],
    competenzeArmi: ["Armi semplici", "Spade corte"],
    competenzeStrumenti: ["Uno strumento musicale o artigianale a scelta"],
    tiriSalvezza: ["Forza", "Destrezza"],
    abilitaSelezionabili: [
      "Acrobazia",
      "Atletica",
      "Furtività",
      "Intuizione",
      "Religione"
    ],
    abilitaDaSelezionare: 2,
    sottoclassi: [
      "Via della Mano Aperta",
      "Via dell’Ombra",
      "Via degli Elementi",
      "Via del Sole Ardente"
    ],
  ),
  Classe(
    nome: "Paladino",
    descrizione: "Guerriero sacro che combatte per la giustizia, armato di fede e poteri divini.",
    dadoVita: 10,
    competenzeArmature: ["Tutte le armature", "Scudi"],
    competenzeArmi: ["Armi semplici", "Armi da guerra"],
    competenzeStrumenti: [],
    tiriSalvezza: ["Saggezza", "Carisma"],
    abilitaSelezionabili: [
      "Addestrare animali",
      "Atletica",
      "Intimidazione",
      "Intuizione",
      "Medicina",
      "Religione"
    ],
    abilitaDaSelezionare: 2,
    sottoclassi: [
      "Giuramento della Devozione",
      "Giuramento della Vendetta",
      "Giuramento degli Antichi",
      "Giuramento della Corona"
    ],
  ),
  Classe(
    nome: "Ranger",
    descrizione: "Esploratore abile nella caccia e nel combattimento nella natura, con magie druidiche leggere.",
    dadoVita: 10,
    competenzeArmature: ["Leggere", "Medie", "Scudi"],
    competenzeArmi: ["Armi semplici", "Armi da guerra"],
    competenzeStrumenti: [],
    tiriSalvezza: ["Forza", "Destrezza"],
    abilitaSelezionabili: [
      "Addestrare animali",
      "Atletica",
      "Furtività",
      "Intuizione",
      "Natura",
      "Percezione",
      "Sopravvivenza"
    ],
    abilitaDaSelezionare: 3,
    sottoclassi: [
      "Cacciatore",
      "Maestro delle Bestie",
      "Esploratore dell'Orizzonte",
      "Cacciatore delle Ombre"
    ],
  ),
  Classe(
    nome: "Stregone",
    descrizione: "Incantatore che attinge potere da un'origine mistica, con grande potenza e versatilità.",
    dadoVita: 6,
    competenzeArmature: [],
    competenzeArmi: ["Armi semplici"],
    competenzeStrumenti: [],
    tiriSalvezza: ["Costituzione", "Carisma"],
    abilitaSelezionabili: [
      "Arcano",
      "Inganno",
      "Intimidazione",
      "Persuasione",
      "Religione"
    ],
    abilitaDaSelezionare: 2,
    sottoclassi: [
      "Origine Draconica",
      "Magia del Caos",
      "Anima Divina",
      "Fiamma Eterna"
    ],
  ),
  Classe(
    nome: "Warlock",
    descrizione: "Incantatore che stipula un patto con un'entità ultraterrena per ottenere poteri arcani.",
    dadoVita: 8,
    competenzeArmature: ["Leggere"],
    competenzeArmi: ["Armi semplici"],
    competenzeStrumenti: [],
    tiriSalvezza: ["Saggezza", "Carisma"],
    abilitaSelezionabili: [
      "Arcano",
      "Inganno",
      "Intimidazione",
      "Investigare",
      "Religione"
    ],
    abilitaDaSelezionare: 2,
    sottoclassi: [
      "Patto dell'Inferno",
      "Patto dell’Abisso",
      "Patto del Grande Antico",
      "Patto della Lama"
    ],
  ),
];
