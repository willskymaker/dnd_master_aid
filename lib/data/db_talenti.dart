// lib/data/db_talenti.dart

class Talento {
  final String nome;
  final String descrizione;
  final List<String> prerequisiti;
  final bool iniziale;
  final int livelloMinimo;

  Talento({
    required this.nome,
    required this.descrizione,
    required this.prerequisiti,
    required this.iniziale,
    required this.livelloMinimo,
  });
}

final List<Talento> talentiList = [
  Talento(
    nome: "Allerta",
    descrizione: "+5 all’iniziativa, non puoi essere sorpreso se cosciente, le creature invisibili non ottengono vantaggio su di te.",
    prerequisiti: [],
    iniziale: false,
    livelloMinimo: 4,
  ),
  Talento(
    nome: "Accurato",
    descrizione: "Quando tiri con vantaggio, puoi ritirare uno dei due dadi una volta.",
    prerequisiti: [],
    iniziale: true,
    livelloMinimo: 1,
  ),
  Talento(
    nome: "Incantatore da Guerra",
    descrizione: "Vantaggio ai TS di Costituzione per mantenere concentrazione, lanciare incantesimi come AdO, puoi lanciare con una mano occupata.",
    prerequisiti: ["Capacità di lanciare incantesimi"],
    iniziale: false,
    livelloMinimo: 4,
  ),
  Talento(
    nome: "Maestro delle Armi Possenti",
    descrizione: "Quando ottieni 20 naturale o uccidi una creatura puoi fare un attacco bonus. -5 all’attacco per +10 ai danni opzionalmente.",
    prerequisiti: ["Competenza con armi da guerra"],
    iniziale: false,
    livelloMinimo: 4,
  ),
  Talento(
    nome: "Maestro delle Armature Pesanti",
    descrizione: "Ignori svantaggio alla Furtività e ottieni +1 alla CA con armatura pesante.",
    prerequisiti: ["Competenza con armature pesanti"],
    iniziale: false,
    livelloMinimo: 4,
  ),
  Talento(
    nome: "Combattente Versatile",
    descrizione: "Quando impugni due armi puoi aggiungere il bonus di caratteristica al secondo attacco. Puoi estrarre due armi come azione gratuita.",
    prerequisiti: [],
    iniziale: true,
    livelloMinimo: 1,
  ),
  Talento(
    nome: "Mente Acuta",
    descrizione: "+1 a Intelligenza, puoi ricordare tutto ciò che hai visto o sentito negli ultimi 30 giorni. Vantaggio su Intelligenza per individuare inganni.",
    prerequisiti: [],
    iniziale: true,
    livelloMinimo: 1,
  ),
  Talento(
    nome: "Robusto",
    descrizione: "I tuoi PF aumentano di 1 per livello. Raddoppi il recupero minimo dei DV quando ti curi.",
    prerequisiti: [],
    iniziale: true,
    livelloMinimo: 1,
  ),
  Talento(
    nome: "Tiratore Scelto",
    descrizione: "Ignori copertura mezza e trequarti. Nessun svantaggio a distanza ravvicinata. -5 all’attacco per +10 ai danni.",
    prerequisiti: ["Competenza con armi da tiro"],
    iniziale: false,
    livelloMinimo: 4,
  ),
  Talento(
    nome: "Resiliente",
    descrizione: "+1 a una caratteristica e competenza nei tiri salvezza della stessa.",
    prerequisiti: [],
    iniziale: true,
    livelloMinimo: 1,
  ),
  Talento(
    nome: "Abile",
    descrizione: "Ottieni competenza in tre abilità o strumenti a tua scelta.",
    prerequisiti: [],
    iniziale: true,
    livelloMinimo: 1,
  ),
   Talento(
    nome: "Esperto con le Armature Medie",
    descrizione: "Quando indossi un’armatura media, puoi aggiungere l’intero modificatore di Destrezza alla CA (massimo +3).",
    prerequisiti: ["Competenza con armature medie"],
    iniziale: false,
    livelloMinimo: 4,
  ),
  Talento(
    nome: "Maestro delle Armi da Mischia Leggere",
    descrizione: "Puoi attaccare con due armi leggere anche se non sono leggere. Inoltre puoi effettuare un attacco con entrambe le armi con l’azione Attacco.",
    prerequisiti: [],
    iniziale: true,
    livelloMinimo: 1,
  ),
  Talento(
    nome: "Tolleranza al Dolore",
    descrizione: "Vantaggio ai tiri salvezza su Costituzione contro condizioni debilitanti. +1 a Costituzione.",
    prerequisiti: [],
    iniziale: true,
    livelloMinimo: 1,
  ),
  Talento(
    nome: "Maestro dell’Iniziativa",
    descrizione: "Puoi agire due volte nel primo round se superi due prove di iniziativa con vantaggio.",
    prerequisiti: ["Destrezza 13+"],
    iniziale: false,
    livelloMinimo: 4,
  ),
  Talento(
    nome: "Tenace",
    descrizione: "Se scendi a 0 PF, puoi rimanere con 1 PF una volta al giorno. Inoltre, +1 a Costituzione.",
    prerequisiti: [],
    iniziale: true,
    livelloMinimo: 1,
  ),
  Talento(
    nome: "Maestro delle Armi da Lancio",
    descrizione: "Ignori svantaggio agli attacchi a distanza ravvicinata. Puoi recuperare le armi da lancio usate.",
    prerequisiti: [],
    iniziale: true,
    livelloMinimo: 1,
  ),
  Talento(
    nome: "Attaccabrighe",
    descrizione: "Ottieni competenza negli attacchi senz’armi. Puoi afferrare come bonus action dopo un attacco.",
    prerequisiti: [],
    iniziale: true,
    livelloMinimo: 1,
  ),
  Talento(
    nome: "Sentinella",
    descrizione: "Quando colpisci con un AdO, la velocità del bersaglio diventa 0. I nemici che ti ignorano provocano AdO anche se Disengage.",
    prerequisiti: [],
    iniziale: false,
    livelloMinimo: 4,
  ),
  Talento(
    nome: "Mente Sveglia",
    descrizione: "+1 a Intelligenza. Puoi leggere e scrivere ogni linguaggio, memorizzare perfettamente ciò che leggi o ascolti.",
    prerequisiti: [],
    iniziale: true,
    livelloMinimo: 1,
  ),
  Talento(
    nome: "Maestro delle Armi da Asta",
    descrizione: "AdO quando una creatura entra nel tuo raggio. Attacco bonus con l’estremità dell’arma (d4).",
    prerequisiti: ["Competenza con armi da guerra"],
    iniziale: false,
    livelloMinimo: 4,
  ),
  Talento(
    nome: "Maestro delle Armi Fini",
    descrizione: "Puoi usare la caratteristica più alta tra Forza e Destrezza per gli attacchi e danni con armi Finesse.",
    prerequisiti: ["Competenza con armi Finesse"],
    iniziale: true,
    livelloMinimo: 1,
  ),
  Talento(
    nome: "Maestro degli Scudi",
    descrizione: "Puoi usare un attacco bonus per tentare di spingere un nemico con lo scudo. Bonus +2 ai TS contro effetti che colpiscono solo te.",
    prerequisiti: ["Competenza con scudi"],
    iniziale: false,
    livelloMinimo: 4,
  ),
  Talento(
    nome: "Mente di Ferro",
    descrizione: "+1 a Saggezza. Vantaggio ai TS contro incantesimi che influenzano la mente.",
    prerequisiti: [],
    iniziale: true,
    livelloMinimo: 1,
  ),
  Talento(
    nome: "Combattente da Tana",
    descrizione: "Se sei sdraiato, non subisci svantaggio agli attacchi a distanza. Quando una creatura ti manca, puoi muoverti di 1,5m gratuitamente.",
    prerequisiti: [],
    iniziale: false,
    livelloMinimo: 4,
  ),
  Talento(
    nome: "Specialista Magico",
    descrizione: "Scegli una lista di incantesimi. Ottieni due trucchetti e un incantesimo di 1° livello (lanciabile una volta al giorno).",
    prerequisiti: ["Capacità di lanciare incantesimi"],
    iniziale: false,
    livelloMinimo: 4,
  ),
];
