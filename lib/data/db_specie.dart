// lib/data/specie.dart

class Specie {
  final String nome;
  final String descrizione;
  final int velocita;
  final List<String> competenze;
  final List<String> resistenze;
  final List<String> abilitaInnate;
  final List<String> linguaggi;
  final bool personalizzazionePunteggi;
  final List<Specie>? sottospecie;

  Specie({
    required this.nome,
    required this.descrizione,
    required this.velocita,
    required this.competenze,
    required this.resistenze,
    required this.abilitaInnate,
    required this.linguaggi,
    this.personalizzazionePunteggi = true,
    this.sottospecie,
  });
}

final List<Specie> specieList = [
  // Elfi con sottospecie
  Specie(
    nome: "Elfo",
    descrizione: "Agili, longevi, dotati di scurovisione e forte volontà.",
    velocita: 9,
    competenze: ["Percezione"],
    resistenze: ["Sonno magico"],
    abilitaInnate: ["Scurovisione"],
    linguaggi: ["Comune", "Elfico"],
    sottospecie: [
      Specie(
        nome: "Elfo Alto",
        descrizione: "Incline allo studio della magia, ottiene un trucchetto da mago.",
        velocita: 9,
        competenze: [],
        resistenze: [],
        abilitaInnate: ["Trucchetto da lista mago"],
        linguaggi: ["Uno a scelta"],
      ),
      Specie(
        nome: "Elfo dei Boschi",
        descrizione: "Silenzioso e veloce, padrone dei boschi.",
        velocita: 10,
        competenze: ["Furtività"],
        resistenze: [],
        abilitaInnate: ["Maschera della Natura"],
        linguaggi: [],
      ),
      Specie(
        nome: "Drow (Elfo Oscuro)",
        descrizione: "Originari del Sottosuolo, dotati di incantesimi innati.",
        velocita: 9,
        competenze: [],
        resistenze: [],
        abilitaInnate: ["Luce Danzante", "Scurovisione superiore"],
        linguaggi: ["Drow"],
      ),
    ],
  ),
  // Nani con sottospecie
  Specie(
    nome: "Nano",
    descrizione: "Robusti e determinati, abitanti di montagne e colline.",
    velocita: 7,
    competenze: ["Attrezzi da fabbro"],
    resistenze: ["Veleno"],
    abilitaInnate: ["Scurovisione"],
    linguaggi: ["Comune", "Nanico"],
    sottospecie: [
      Specie(
        nome: "Nano delle Colline",
        descrizione: "Più saggi e longevi, con un innato istinto di sopravvivenza.",
        velocita: 7,
        competenze: [],
        resistenze: [],
        abilitaInnate: ["Punti Ferita extra"],
        linguaggi: [],
      ),
      Specie(
        nome: "Nano delle Montagne",
        descrizione: "Più forti e addestrati al combattimento in armatura pesante.",
        velocita: 7,
        competenze: ["Armature leggere e medie"],
        resistenze: [],
        abilitaInnate: [],
        linguaggi: [],
      ),
    ],
  ),
  // Halfling con sottospecie
  Specie(
    nome: "Halfling",
    descrizione: "Piccoli e agili, dotati di grande fortuna e tenacia.",
    velocita: 7,
    competenze: [],
    resistenze: [],
    abilitaInnate: ["Fortuna (rilanciare 1)", "Movimento agile"],
    linguaggi: ["Comune", "Halfling"],
    sottospecie: [
      Specie(
        nome: "Halfling Piedelesto",
        descrizione: "Estremamente fortunato e sociale.",
        velocita: 7,
        competenze: [],
        resistenze: [],
        abilitaInnate: ["Vantaggio contro la paura"],
        linguaggi: [],
      ),
      Specie(
        nome: "Halfling Robusto",
        descrizione: "Più resistente, con costituzione più elevata.",
        velocita: 7,
        competenze: [],
        resistenze: ["Veleno"],
        abilitaInnate: [],
        linguaggi: [],
      ),
    ],
  ),
  // Gnomi con sottospecie
  Specie(
    nome: "Gnomo",
    descrizione: "Piccoli e intelligenti, dotati di mente acuta e abilità magiche innate.",
    velocita: 7,
    competenze: [],
    resistenze: ["Magia mentale"],
    abilitaInnate: ["Scurovisione"],
    linguaggi: ["Comune", "Gnomesco"],
    sottospecie: [
      Specie(
        nome: "Gnomo delle Foreste",
        descrizione: "Schivi e magici, ottimi illusionisti.",
        velocita: 7,
        competenze: [],
        resistenze: [],
        abilitaInnate: ["Illusione minore"],
        linguaggi: [],
      ),
      Specie(
        nome: "Gnomo delle Rocce",
        descrizione: "Esperti in meccanismi e artigianato.",
        velocita: 7,
        competenze: ["Attrezzi da artigiano"],
        resistenze: [],
        abilitaInnate: ["Tinker"],
        linguaggi: [],
      ),
    ],
  ),
  // Dragonidi con varianti elementali
  Specie(
    nome: "Dragonide",
    descrizione: "Discendenti dei draghi, con soffio elementale e resistenza associata.",
    velocita: 9,
    competenze: [],
    resistenze: [],
    abilitaInnate: ["Soffio draconico"],
    linguaggi: ["Comune", "Draconico"],
    sottospecie: [
      Specie(
        nome: "Dragonide Rosso",
        descrizione: "Discendenza da draghi rossi, fuoco ardente.",
        velocita: 9,
        competenze: [],
        resistenze: ["Fuoco"],
        abilitaInnate: [],
        linguaggi: [],
      ),
      Specie(
        nome: "Dragonide Blu",
        descrizione: "Discendenza da draghi blu, folgore.",
        velocita: 9,
        competenze: [],
        resistenze: ["Elettricità"],
        abilitaInnate: [],
        linguaggi: [],
      ),
      Specie(
        nome: "Dragonide Verde",
        descrizione: "Discendenza da draghi verdi, veleno.",
        velocita: 9,
        competenze: [],
        resistenze: ["Veleno"],
        abilitaInnate: [],
        linguaggi: [],
      ),
      Specie(
        nome: "Dragonide Bianco",
        descrizione: "Discendenza da draghi bianchi, gelo.",
        velocita: 9,
        competenze: [],
        resistenze: ["Ghiaccio"],
        abilitaInnate: [],
        linguaggi: [],
      ),
      Specie(
        nome: "Dragonide Nero",
        descrizione: "Discendenza da draghi neri, acido.",
        velocita: 9,
        competenze: [],
        resistenze: ["Acido"],
        abilitaInnate: [],
        linguaggi: [],
      ),
    ],
  ),
  // Tiefling
  Specie(
    nome: "Tiefling",
    descrizione: "Essere con lignaggio infernale, dotati di poteri magici e resistenza al fuoco.",
    velocita: 9,
    competenze: [],
    resistenze: ["Fuoco"],
    abilitaInnate: ["Scurovisione", "Taumaturgia", "Infernal Legacy"],
    linguaggi: ["Comune", "Infernale"],
  ),
  // Orco
  Specie(
    nome: "Orco Redento",
    descrizione: "Discendenti di stirpi brutali, ma determinati a riscattarsi nella società civile.",
    velocita: 9,
    competenze: ["Intimidazione"],
    resistenze: [],
    abilitaInnate: ["Spinta brutale", "Resistenza ferrea"],
    linguaggi: ["Comune", "Orchesco"],
  ),
  //Aarakocra
  Specie(
    nome: "Aarakocra",
    descrizione: "Uccelli umanoidi capaci di volare, provenienti da alte montagne e piani elementali.",
    velocita: 7,
    competenze: [],
    resistenze: [],
    abilitaInnate: ["Volo (12m con armature leggere)", "Artigli naturali"],
    linguaggi: ["Comune", "Aarakocrano"],
  ),
  //Mezzorco
  Specie(
    nome: "Mezzorco",
    descrizione: "Combattenti instancabili, portatori di forza brutale e resilienza.",
    velocita: 9,
    competenze: ["Intimidazione"],
    resistenze: [],
    abilitaInnate: ["Tenacia implacabile", "Colpo selvaggio"],
    linguaggi: ["Comune", "Orchesco"],
  ),
  //Mezzelfo
  Specie(
    nome: "Mezzelfo",
    descrizione: "Versatili e carismatici, ereditano tratti sia umani che elfici.",
    velocita: 9,
    competenze: ["Due abilità a scelta"],
    resistenze: [],
    abilitaInnate: ["Scurovisione", "Retaggio elfico (vantaggio contro charme)"],
    linguaggi: ["Comune", "Elfico", "Uno a scelta"],
  ),
  //Genasi e sottospecie elementali
  Specie(
    nome: "Genasi",
    descrizione: "Esseri legati ai piani elementali, manifestano poteri innati del loro elemento.",
    velocita: 9,
    competenze: [],
    resistenze: [],
    abilitaInnate: [],
    linguaggi: ["Comune", "Primordiale"],
    sottospecie: [
      Specie(
        nome: "Genasi del Fuoco",
        descrizione: "Pelle calda, affinità con fiamme e resistenza al fuoco.",
        velocita: 9,
        competenze: [],
        resistenze: ["Fuoco"],
        abilitaInnate: ["Produce Flame", "Scurovisione"],
        linguaggi: [],
      ),
      Specie(
        nome: "Genasi dell'Aria",
        descrizione: "Leggeri e veloci, capaci di levitazione temporanea.",
        velocita: 9,
        competenze: [],
        resistenze: [],
        abilitaInnate: ["Levitate (una volta al giorno)"],
        linguaggi: [],
      ),
      Specie(
        nome: "Genasi dell'Acqua",
        descrizione: "Affinità con ambienti acquatici, respirano sott'acqua.",
        velocita: 9,
        competenze: [],
        resistenze: [],
        abilitaInnate: ["Respirare sott'acqua", "Nuotare 9m"],
        linguaggi: [],
      ),
      Specie(
        nome: "Genasi della Terra",
        descrizione: "Solidi e duri come la roccia, ignorano terreni difficili.",
        velocita: 9,
        competenze: [],
        resistenze: [],
        abilitaInnate: ["Passare senza lasciare tracce"],
        linguaggi: [],
      ),
    ],
  ),
  //Goliath
  Specie(
    nome: "Goliath",
    descrizione: "Giganti delle montagne, forti, competitivi e incredibilmente resistenti.",
    velocita: 9,
    competenze: ["Atletica"],
    resistenze: [],
    abilitaInnate: ["Resistenza da montagna", "Portata potente"],
    linguaggi: ["Comune", "Gigante"],
  ),
  //Firbolg
  Specie(
    nome: "Firbolg",
    descrizione: "Guardiani gentili delle foreste, dotati di magia innata e comunione con la natura.",
    velocita: 9,
    competenze: ["Intuizione", "Disfarsi di tracce"],
    resistenze: [],
    abilitaInnate: ["Scurovisione", "Camuffare se stessi", "Parlare con animali e piante"],
    linguaggi: ["Comune", "Silvano"],
  ),
  //Leonin
  Specie(
    nome: "Leonin",
    descrizione: "Fieri felini guerrieri, originari di terre selvagge, con artigli e grande presenza.",
    velocita: 12,
    competenze: ["Intimidazione", "Percezione"],
    resistenze: [],
    abilitaInnate: ["Ruggito leonino", "Artigli"],
    linguaggi: ["Comune", "Leonin"],
  ),
  //Satiro
  Specie(
    nome: "Satiro",
    descrizione: "Creatura delle selve, allegra e agile, resistente agli effetti mentali.",
    velocita: 10,
    competenze: ["Intrattenere", "Persuasione"],
    resistenze: ["Charm", "Magia del sonno"],
    abilitaInnate: ["Salto prodigioso", "Artigli di capra"],
    linguaggi: ["Comune", "Silvano"],
  ),
  //Tritone
  Specie(
    nome: "Tritone",
    descrizione: "Creatura anfibia, protettrice degli oceani, adattata al combattimento subacqueo.",
    velocita: 9,
    competenze: ["Armi da guerra"],
    resistenze: [],
    abilitaInnate: ["Scurovisione", "Nuotare 9m", "Respirare sott’acqua"],
    linguaggi: ["Comune", "Primordiale"],
  ),
  //Kenku
    Specie(
    nome: "Kenku",
    descrizione: "Uccelli umanoidi incapaci di parlare ma dotati di mimica perfetta.",
    velocita: 9,
    competenze: ["Furtività", "Falsificazione", "Inganno"],
    resistenze: [],
    abilitaInnate: ["Mimica sonora"],
    linguaggi: ["Comune", "A scelta"],
  ),
  //Tabaxi
  Specie(
    nome: "Tabaxi",
    descrizione: "Felini umanoidi curiosi, agili e amanti delle storie e degli oggetti.",
    velocita: 12,
    competenze: ["Furtività", "Percezione"],
    resistenze: [],
    abilitaInnate: ["Artigli", "Sprint felino"],
    linguaggi: ["Comune", "A scelta"],
  ),
  //Goblin
  Specie(
    nome: "Goblin",
    descrizione: "Piccoli, astuti e veloci, con tendenze aggressive ma anche inventiva geniale.",
    velocita: 9,
    competenze: [],
    resistenze: [],
    abilitaInnate: ["Furia furfantesca", "Scappare veloce"],
    linguaggi: ["Comune", "Goblin"],
  ),
  //Hobgoblin
  Specie(
    nome: "Hobgoblin",
    descrizione: "Disciplinati e tattici, con una società rigidamente organizzata.",
    velocita: 9,
    competenze: [],
    resistenze: [],
    abilitaInnate: ["Aiuto da guerra", "Disciplina militare"],
    linguaggi: ["Comune", "Goblin"],
  ),
  //Kalashtar
  Specie(
    nome: "Kalashtar",
    descrizione: "Essere psionici con legami spirituali, calmi e intuitivi.",
    velocita: 9,
    competenze: ["Intuizione", "Religione"],
    resistenze: ["Incantesimi mentali"],
    abilitaInnate: ["Comunicazione telepatica"],
    linguaggi: ["Comune", "Quor"],
  ),
  //Yuan-ti PureBlood
  Specie(
    nome: "Yuan-ti Pureblood",
    descrizione: "Umanoidi serpenti, astuti e resistenti alla magia.",
    velocita: 9,
    competenze: ["Inganno", "Intimidazione"],
    resistenze: ["Magia"],
    abilitaInnate: ["Scurovisione", "Magia innata"],
    linguaggi: ["Comune", "Abissale"],
  ),
  //Changeling
  Specie(
    nome: "Changeling",
    descrizione: "Mutanti in grado di cambiare volto e forma, adattabili e sfuggenti.",
    velocita: 9,
    competenze: ["Inganno", "Persuasione"],
    resistenze: [],
    abilitaInnate: ["Mutare forma"],
    linguaggi: ["Comune", "Uno a scelta"],
  ),
  //Warforged
  Specie(
    nome: "Warforged",
    descrizione: "Costrutti senzienti creati per la guerra, ora in cerca di uno scopo.",
    velocita: 9,
    competenze: [],
    resistenze: ["Veleno", "Malattie"],
    abilitaInnate: ["Armatura integrata", "Riposo semicompleto"],
    linguaggi: ["Comune", "Uno a scelta"],
  ),
  //Simic Hybrid
  Specie(
    nome: "Simic Hybrid",
    descrizione: "Modificati magicamente con tratti di varie creature marine.",
    velocita: 9,
    competenze: [],
    resistenze: [],
    abilitaInnate: ["Adattamento biologico"],
    linguaggi: ["Comune", "Uno a scelta"],
  ),
  //Vedalken
  Specie(
    nome: "Vedalken",
    descrizione: "Intellettuali logici e riservati, dotati di resistenza mentale.",
    velocita: 9,
    competenze: ["Investigare", "Storia"],
    resistenze: ["Magia mentale"],
    abilitaInnate: ["Precisione Vedalken"],
    linguaggi: ["Comune", "Vedalken"],
  ),
  //Minotauro
  Specie(
    nome: "Minotauro",
    descrizione: "Essere taurino possente, guidato da istinto e onore.",
    velocita: 9,
    competenze: ["Intimidazione"],
    resistenze: [],
    abilitaInnate: ["Carica con corna", "Senso del labirinto"],
    linguaggi: ["Comune", "Uno a scelta"],
  ),
  //Aasimar e sottospecie
  Specie(
    nome: "Aasimar",
    descrizione: "Esseri benedetti da poteri celestiali, paladini della luce e della giustizia.",
    velocita: 9,
    competenze: [],
    resistenze: ["Necrotico", "Radiante"],
    abilitaInnate: ["Luce", "Guarigione innata"],
    linguaggi: ["Comune", "Celestiale"],
    sottospecie: [
      Specie(
        nome: "Protettore",
        descrizione: "Ispirano e proteggono, con ali di luce e poteri curativi.",
        velocita: 9,
        competenze: [],
        resistenze: [],
        abilitaInnate: ["Forma angelica"],
        linguaggi: [],
      ),
      Specie(
        nome: "Flagellatore",
        descrizione: "Punisce con fuoco sacro e ira divina.",
        velocita: 9,
        competenze: [],
        resistenze: [],
        abilitaInnate: ["Fuoco radiante"],
        linguaggi: [],
      ),
      Specie(
        nome: "Caduto",
        descrizione: "Ex paladini ora legati a poteri oscuri, pur mantenendo abilità sacre.",
        velocita: 9,
        competenze: [],
        resistenze: [],
        abilitaInnate: ["Aura terrificante"],
        linguaggi: [],
      ),
    ],
  ),
//Eladrin e sottospecie stagionali
  Specie(
    nome: "Eladrin",
    descrizione: "Elfi dei piani fatati, mutevoli come le stagioni.",
    velocita: 9,
    competenze: [],
    resistenze: [],
    abilitaInnate: ["Passo fatato"],
    linguaggi: ["Comune", "Elfico"],
    sottospecie: [
      Specie(
        nome: "Primavera",
        descrizione: "Empatici e gentili, portano gioia e soccorso.",
        velocita: 9,
        competenze: [],
        resistenze: [],
        abilitaInnate: ["Fascino fatato"],
        linguaggi: [],
      ),
      Specie(
        nome: "Estate",
        descrizione: "Impulsivi e ardenti, scatenano ira solare.",
        velocita: 9,
        competenze: [],
        resistenze: [],
        abilitaInnate: ["Danno da fuoco con il passo fatato"],
        linguaggi: [],
      ),
      Specie(
        nome: "Autunno",
        descrizione: "Accoglienti e pacifici, inducono calma e riflessione.",
        velocita: 9,
        competenze: [],
        resistenze: [],
        abilitaInnate: ["Discorso calmante"],
        linguaggi: [],
      ),
      Specie(
        nome: "Inverno",
        descrizione: "Freddi e risoluti, incutono terrore con un solo sguardo.",
        velocita: 9,
        competenze: [],
        resistenze: [],
        abilitaInnate: ["Sguardo gelido"],
        linguaggi: [],
      ),
    ],
  ),
  //Locathan
  Specie(
    nome: "Locathah",
    descrizione: "Popolo anfibio tenace, abituato a sopravvivere nella durezza degli abissi.",
    velocita: 9,
    competenze: ["Atletica", "Percezione"],
    resistenze: [],
    abilitaInnate: ["Nuoto 9m", "Respirare sott'acqua"],
    linguaggi: ["Comune", "Aquan"],
  ),
  //Loxodon
  Specie(
    nome: "Loxodon",
    descrizione: "Pachidermi antropomorfi, calmi e forti, con una cultura spirituale profonda.",
    velocita: 9,
    competenze: ["Intuizione", "Religione"],
    resistenze: [],
    abilitaInnate: ["Proboscide", "Difesa naturale"],
    linguaggi: ["Comune", "Loxodon"],
  ),
];
final List<String> specieCoreConsentite = [
  "Umano",
  "Elfo",
  "Nano",
  "Halfling",
  "Dragonide",
  "Gnomo",
  "Tiefling",
  "Mezzelfo",
  "Mezzorco"
];

final List<Specie> specieCoreList = specieList
    .where((specie) => specieCoreConsentite.contains(specie.nome))
    .toList();
