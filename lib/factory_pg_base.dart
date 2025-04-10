class PGBase {
  final String nome;
  final String specie;
  final String classe;
  final int livello;
  final String background;
  final String allineamento;
  final List<String> competenze;
  final Map<String, int> caratteristiche;
  final Map<String, int> modificatori;
  final int velocita;
  final List<String> linguaggi;
  final List<String> capacitaSpeciali;
  final int dadoVita;
  final int puntiVita;
  final List<String> tiriSalvezza;
  final List<String> competenzeArmi;
  final List<String> competenzeArmature;
  final List<String> competenzeStrumenti;
  final List<String> abilitaClasse;

  PGBase({
    required this.nome,
    required this.specie,
    required this.classe,
    required this.livello,
    required this.background,
    required this.allineamento,
    required this.competenze,
    required this.caratteristiche,
    required this.modificatori,
    required this.velocita,
    required this.linguaggi,
    required this.capacitaSpeciali,
    required this.dadoVita,
    required this.puntiVita,
    required this.tiriSalvezza,
    required this.competenzeArmi,
    required this.competenzeArmature,
    required this.competenzeStrumenti,
    required this.abilitaClasse,
  });

  @override
  String toString() {
    return 'PGBase(nome: $nome, specie: $specie, classe: $classe, livello: $livello, background: $background, allineamento: $allineamento, '
        'modificatori: $modificatori, velocità: $velocita, linguaggi: $linguaggi, capacità: $capacitaSpeciali, '
        'HP: $puntiVita (d${dadoVita}), TS: $tiriSalvezza, armi: $competenzeArmi, armature: $competenzeArmature, strumenti: $competenzeStrumenti, abilita: $abilitaClasse)';
  }
}

class PGBaseFactory {
  String _nome = '';
  String _specie = '';
  String _classe = '';
  int _livello = 1;
  String _background = '';
  String _allineamento = '';
  int _dadoVita = 8;
  int _puntiVita = 0;
  List<String> _tiriSalvezza = [];
  List<String> _competenzeArmi = [];
  List<String> _competenzeArmature = [];
  List<String> _competenzeStrumenti = [];
  List<String> _abilitaClasse = [];
  Map<String, int> _caratteristiche = {
    'FOR': 8,
    'DES': 8,
    'COS': 8,
    'INT': 8,
    'SAG': 8,
    'CAR': 8,
  };
  bool _caratteristicheImpostate = false;
  final List<String> _competenze = [];
  final Map<String, int> _modificatori = {
    'FOR': 0,
    'DES': 0,
    'COS': 0,
    'INT': 0,
    'SAG': 0,
    'CAR': 0,
  };
  int _velocita = 0;
  final List<String> _linguaggi = [];
  final List<String> _capacitaSpeciali = [];
  int get livello => _livello;
  int get dadoVita => _dadoVita;

  // Set base
  void setNome(String nome) => _nome = nome;
  void setSpecie(String specie) => _specie = specie;
  void setClasse(String classe) => _classe = classe;
  void setBackground(String background) => _background = background;
  void setAllineamento(String allineamento) => _allineamento = allineamento;
  void setLivello(int livello) => _livello = livello;
  void setDadoVita(int dado) => _dadoVita = dado;
  void setPuntiVita(int hp) => _puntiVita = hp;
  void setTiriSalvezza(List<String> lista) => _tiriSalvezza = lista;
  void setCompetenzeArmi(List<String> lista) => _competenzeArmi = lista;
  void setCompetenzeArmature(List<String> lista) => _competenzeArmature = lista;
  void setCompetenzeStrumenti(List<String> lista) => _competenzeStrumenti = lista;
  void setAbilitaClasse(List<String> lista) => _abilitaClasse = lista;
  void setVelocita(int velocita) => _velocita = velocita;
  void addCompetenza(String competenza) => _competenze.add(competenza);
  void addLinguaggi(List<String> lingue) => _linguaggi.addAll(lingue.where((l) => !_linguaggi.contains(l)));
  void addTrattiSpecie(List<String> tratti) => _capacitaSpeciali.addAll(tratti);
  bool get caratteristicheImpostate => _caratteristicheImpostate;
  void setCaratteristiche(Map<String, int> valori) {
    _caratteristiche = valori;
    _caratteristicheImpostate = true;
    _modificatori.clear();
    valori.forEach((key, val) {
      _modificatori[key] = ((val - 10) / 2).floor();
    });
  }
  PGBase build() {
    return PGBase(
      nome: _nome,
      specie: _specie,
      classe: _classe,
      livello: _livello,
      background: _background,
      allineamento: _allineamento,
      competenze: List.from(_competenze),
      caratteristiche: Map.from(_caratteristiche),
      modificatori: Map.from(_modificatori),
      velocita: _velocita,
      linguaggi: List.from(_linguaggi),
      capacitaSpeciali: List.from(_capacitaSpeciali),
      dadoVita: _dadoVita,
      puntiVita: _puntiVita,
      tiriSalvezza: List.from(_tiriSalvezza),
      competenzeArmi: List.from(_competenzeArmi),
      competenzeArmature: List.from(_competenzeArmature),
      competenzeStrumenti: List.from(_competenzeStrumenti),
      abilitaClasse: List.from(_abilitaClasse),
    );
  }
}
