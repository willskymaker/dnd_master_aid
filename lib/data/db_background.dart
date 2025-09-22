// lib/data/db_background.dart

class Background {
  final String nome;
  final String descrizione;
  final List<String> competenzeAbilita;
  final List<String> competenzeStrumenti;
  final List<String> linguaggi;
  final String equipaggiamento;
  final String tratto;
  final String ideali;
  final String legami;
  final String difetti;

  Background({
    required this.nome,
    required this.descrizione,
    required this.competenzeAbilita,
    required this.competenzeStrumenti,
    required this.linguaggi,
    required this.equipaggiamento,
    required this.tratto,
    required this.ideali,
    required this.legami,
    required this.difetti,
  });
}

final List<Background> backgroundList = [
  Background(
    nome: "Eroe Popolare",
    descrizione: "Sei cresciuto tra la gente comune, ma il tuo destino ti ha portato a un cammino eroico.",
    competenzeAbilita: ["Atletica", "Addestrare Animali"],
    competenzeStrumenti: ["Strumenti da artigiano (a scelta)", "Veicolo terrestre (a scelta)"],
    linguaggi: [],
    equipaggiamento: "Uno attrezzo da artigiano a scelta, una pala, una padella di ferro, vestiti da viandante e 10 monete d’oro.",
    tratto: "Sono sempre pronto ad aiutare chi ha bisogno, anche a mie spese.",
    ideali: "Rispetto. I popoli meritano rispetto e protezione, non dominio (Buono).",
    legami: "Proverò a proteggere la mia gente da ogni minaccia.",
    difetti: "Mi fido troppo facilmente degli altri."
  ),
  Background(
    nome: "Criminale",
    descrizione: "Hai una storia di vita ai margini della legge. Sei esperto in furti, truffe e sopravvivenza urbana.",
    competenzeAbilita: ["Furtività", "Inganno"],
    competenzeStrumenti: ["Attrezzi da ladro", "Gioco d’azzardo (a scelta)"],
    linguaggi: [],
    equipaggiamento: "Un attrezzo da ladro, un mantello scuro con cappuccio, una spada corta, un set di abiti comuni e 15 monete d’oro.",
    tratto: "Ho una rete di contatti criminali che mi aiuta a ottenere informazioni e risorse.",
    ideali: "Libertà. Le catene sono fatte per essere spezzate (Caotico).",
    legami: "Qualcuno mi ha tradito, e non riposerò finché non lo vedrò pagare.",
    difetti: "Non riesco a resistere a una borsa ben piena o a un affare rischioso."
  ),
  Background(
    nome: "Saggio",
    descrizione: "Hai passato anni a studiare le leggi del mondo, che siano arcane, divine o naturali.",
    competenzeAbilita: ["Arcano", "Storia"],
    competenzeStrumenti: [],
    linguaggi: ["A scelta", "A scelta"],
    equipaggiamento: "Un flacone d’inchiostro, una penna, un piccolo coltello, una lettera di un collega scomparso, abiti comuni e 10 monete d’oro.",
    tratto: "Cito sempre fatti e dettagli anche fuori contesto.",
    ideali: "Conoscenza. La via per il potere passa attraverso la comprensione (Neutrale).",
    legami: "Ho giurato di completare l’opera di un mentore o maestro perduto.",
    difetti: "Perdo di vista la realtà quando mi immergo nei miei studi."
  ),
  Background(
    nome: "Soldato",
    descrizione: "Hai servito in un esercito, una milizia o come mercenario. Sei abituato alla disciplina e alla guerra.",
    competenzeAbilita: ["Atletica", "Intimidazione"],
    competenzeStrumenti: ["Gioco d’azzardo (a scelta)", "Veicolo terrestre"],
    linguaggi: [],
    equipaggiamento: "Un trofeo di guerra, uniforme, set di dadi o carte, abiti comuni, 10 monete d’oro.",
    tratto: "Seguo gli ordini, anche se non sono d’accordo.",
    ideali: "Disciplina. L’ordine e la struttura rendono la società più forte (Legale).",
    legami: "Un compagno d’armi salvò la mia vita; farò qualunque cosa per lui/lei.",
    difetti: "Penso che la soluzione ai problemi sia la forza."
  ),
  Background(
    nome: "Nobile",
    descrizione: "Sei cresciuto in una famiglia aristocratica, con privilegi e obblighi.",
    competenzeAbilita: ["Storia", "Persuasione"],
    competenzeStrumenti: ["Gioco d’azzardo (a scelta)"],
    linguaggi: ["A scelta"],
    equipaggiamento: "Un anello con sigillo, lettere di nobiltà, vestiti eleganti e una borsa con 25 monete d’oro.",
    tratto: "Mi comporto come se fossi sempre il più importante nella stanza.",
    ideali: "Nobiltà. L'obbligo della nobiltà è proteggere chi sta sotto di noi (Buono).",
    legami: "Un mio servitore è rimasto fedele anche nei momenti più bui. Gli devo la vita.",
    difetti: "Guardo dall’alto in basso chi non è nobile come me."
  ),
  Background(
    nome: "Artigiano Gildato",
    descrizione: "Hai imparato un mestiere e ne sei diventato un membro riconosciuto all’interno di una gilda.",
    competenzeAbilita: ["Intuizione", "Persuasione"],
    competenzeStrumenti: ["Strumenti da artigiano (a scelta)"],
    linguaggi: ["A scelta"],
    equipaggiamento: "Uno strumento da artigiano, una lettera di raccomandazione della tua gilda, abiti da viaggio, 15 monete d’oro.",
    tratto: "Mi sento sempre parte della mia gilda, anche a chilometri di distanza.",
    ideali: "Lavoro. Il duro lavoro è la base di ogni impresa di successo (Legale).",
    legami: "La mia gilda è tutto: la proteggerò a ogni costo.",
    difetti: "Tendo a sottovalutare coloro che non hanno un mestiere vero e proprio."
  ),
  Background(
    nome: "Eremita",
    descrizione: "Hai vissuto per anni in isolamento, esplorando il tuo io interiore o scoprendo verità profonde.",
    competenzeAbilita: ["Medicina", "Religione"],
    competenzeStrumenti: ["Kit da erborista"],
    linguaggi: ["A scelta"],
    equipaggiamento: "Un diario pieno di scoperte, una coperta invernale, un bastone, vestiti comuni, 5 monete d’oro.",
    tratto: "Mi esprimo in modo enigmatico o spirituale.",
    ideali: "Autoconoscenza. Se conosci te stesso, nulla può farti paura (Neutrale).",
    legami: "La mia solitudine mi ha portato a scoprire un segreto pericoloso.",
    difetti: "Fatico a relazionarmi con le persone comuni."
  ),
  Background(
    nome: "Intrattenitore",
    descrizione: "Hai vissuto intrattenendo il pubblico con talento e carisma.",
    competenzeAbilita: ["Acrobazia", "Intrattenere"],
    competenzeStrumenti: ["Strumento musicale (a scelta)", "Kit per travestimenti"],
    linguaggi: [],
    equipaggiamento: "Uno strumento musicale, oggetto ricordo del pubblico, costumi scenici, 15 monete d’oro.",
    tratto: "Dove vado io, il sorriso è garantito.",
    ideali: "Creatività. L’arte eleva l’anima (Caotico).",
    legami: "Tornerò da chi mi ha fatto da mentore nel mio primo spettacolo.",
    difetti: "Non riesco a stare lontano dai riflettori, anche quando dovrei."
  ),
  Background(
    nome: "Accolito",
    descrizione: "Hai servito una divinità o un tempio, vivendo sotto regole religiose e studiando testi sacri.",
    competenzeAbilita: ["Intuizione", "Religione"],
    competenzeStrumenti: [],
    linguaggi: ["A scelta", "A scelta"],
    equipaggiamento: "Un simbolo sacro, un libro o preghiere, abiti comuni, 15 monete d’oro.",
    tratto: "Credo fermamente nella mia fede e la pratico ovunque.",
    ideali: "Tradizione. Le antiche usanze mantengono la società stabile (Legale).",
    legami: "Il mio tempio è la mia casa e farò di tutto per proteggerlo.",
    difetti: "Giudico severamente chi non condivide la mia fede."
  ),
  Background(
    nome: "Marinaio",
    descrizione: "Hai passato la tua vita a bordo di navi, affrontando tempeste, pirati e il vasto mare.",
    competenzeAbilita: ["Atletica", "Percezione"],
    competenzeStrumenti: ["Veicoli acquatici", "Strumento musicale (a scelta)"],
    linguaggi: [],
    equipaggiamento: "Un arpione, una corda da 15 metri, un talismano marinaresco, abiti comuni, 10 monete d’oro.",
    tratto: "Mi sento a casa solo in mare aperto.",
    ideali: "Libertà. Il mare è libertà, e la libertà è tutto (Caotico).",
    legami: "Devo la mia vita al capitano che mi ha salvato anni fa.",
    difetti: "Bevo troppo e non so dire di no a una scommessa."
  ),
  Background(
    nome: "Vagabondo",
    descrizione: "Sei cresciuto per strada, imparando a sopravvivere tra i vicoli e le ombre della città.",
    competenzeAbilita: ["Furtività", "Acrobazia"],
    competenzeStrumenti: ["Strumento musicale (a scelta)", "Gioco d’azzardo (a scelta)"],
    linguaggi: [],
    equipaggiamento: "Un coltellino, una mappa di un tesoro immaginario, abiti comuni, 10 monete d’oro.",
    tratto: "So come muovermi inosservato anche nei luoghi più pericolosi.",
    ideali: "Autonomia. Nessuno mi comanda (Caotico).",
    legami: "Una banda di strada è la mia vera famiglia.",
    difetti: "Diffido di tutti, anche dei miei compagni."
  ),
  Background(
    nome: "Forestiero",
    descrizione: "Vivi a contatto con la natura e hai poco a che fare con la civiltà.",
    competenzeAbilita: ["Sopravvivenza", "Percezione"],
    competenzeStrumenti: ["Strumenti da intagliatore (a scelta)"],
    linguaggi: ["A scelta"],
    equipaggiamento: "Un trofeo di caccia, una trappola, vestiti da viandante, 10 monete d’oro.",
    tratto: "Mi sento più a mio agio tra gli alberi che tra le persone.",
    ideali: "Equilibrio. Tutte le cose devono trovare il proprio equilibrio (Neutrale).",
    legami: "Proteggo la mia terra con la stessa ferocia con cui proteggo me stesso.",
    difetti: "Fatico a fidarmi di chi non rispetta la natura."
  ),
  Background(
    nome: "Spia",
    descrizione: "Hai operato nell'ombra, raccogliendo segreti e muovendoti tra bugie e doppigiochi.",
    competenzeAbilita: ["Furtività", "Inganno"],
    competenzeStrumenti: ["Attrezzi da ladro", "Kit da travestimento"],
    linguaggi: [],
    equipaggiamento: "Un set di abiti scuri, un diario cifrato, attrezzi da ladro, 15 monete d’oro.",
    tratto: "Mi fido solo di chi può mantenere un segreto.",
    ideali: "Sopravvivenza. La verità è un lusso, la sopravvivenza è necessità (Neutrale).",
    legami: "Ho un contatto segreto che ancora mi passa informazioni utili.",
    difetti: "Mi è difficile essere onesto, anche con chi amo."
  ),
  Background(
    nome: "Pirata",
    descrizione: "Hai solcato i mari depredando navi o vivendo da canaglia in mare aperto.",
    competenzeAbilita: ["Atletica", "Intimidazione"],
    competenzeStrumenti: ["Veicoli acquatici", "Gioco d’azzardo (a scelta)"],
    linguaggi: [],
    equipaggiamento: "Un uncino, una bandana logora, un sacchetto con 15 monete d’oro.",
    tratto: "Il codice del mare è l'unico che rispetto.",
    ideali: "Caos. Solo chi è pronto a rischiare merita di comandare (Caotico).",
    legami: "Un vecchio compagno di ciurma mi ha giurato vendetta.",
    difetti: "Il mio passato da pirata torna sempre a tormentarmi."
  ),
  Background(
    nome: "Disertore",
    descrizione: "Hai abbandonato l’esercito, per scelta o necessità, portandoti dietro segreti e cicatrici.",
    competenzeAbilita: ["Furtività", "Sopravvivenza"],
    competenzeStrumenti: ["Veicoli terrestri"],
    linguaggi: [],
    equipaggiamento: "Una lettera non spedita a un familiare, un mantello militare strappato, 10 monete d’oro.",
    tratto: "Evito sempre lo scontro diretto, se possibile.",
    ideali: "Redenzione. Posso ancora fare del bene nonostante il mio passato (Buono).",
    legami: "Un vecchio ufficiale è sulle mie tracce.",
    difetti: "La paura mi guida più spesso del coraggio."
  ),
];
