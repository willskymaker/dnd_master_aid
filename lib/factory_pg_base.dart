class PGBase {
  final String nome;
  final String specie;
  final String classe;
  final String background;
  final String allineamento;
  final List<String> competenze;
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
    required this.background,
    required this.allineamento,
    required this.competenze,
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
    return 'PGBase(nome: $nome, specie: $specie, classe: $classe, background: $background, allineamento: $allineamento, '
        'modificatori: $modificatori, velocità: $velocita, linguaggi: $linguaggi, capacità: $capacitaSpeciali, '
        'HP: $puntiVita (d${
            dadoVita
        }), TS: $tiriSalvezza, armi: $competenzeArmi, armature: $competenzeArmature, strumenti: $competenzeStrumenti, abilità: $abilitaClasse)';
  }
}

class PGBaseFactory {
  String _nome = '';
  String _specie = '';
  String _classe = '';
  String _background = '';
  String _allineamento = '';
  int _dadoVita = 0;
  int _puntiVita = 0;
  List<String> _tiriSalvezza = [];
  List<String> _competenzeArmi = [];
  List<String> _competenzeArmature = [];
  List<String> _competenzeStrumenti = [];
  List<String> _abilitaClasse = [];


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

  // Set base
  void setNome(String nome) => _nome = nome;
  void setSpecie(String specie) => _specie = specie;
  void setClasse(String classe) => _classe = classe;
  void setBackground(String background) => _background = background;
  void setAllineamento(String allineamento) => _allineamento = allineamento;
  void setDadoVita(int dado) {
    _dadoVita = dado;
  }
  void setPuntiVita(int hp) {
    _puntiVita = hp;
  }
  void setTiriSalvezza(List<String> lista) {
    _tiriSalvezza = lista;
  }
  void setCompetenzeArmi(List<String> lista) {
    _competenzeArmi = lista;
  }
  void setCompetenzeArmature(List<String> lista) {
    _competenzeArmature = lista;
  }
  void setCompetenzeStrumenti(List<String> lista) {
    _competenzeStrumenti = lista;
  }
  void setAbilitaClasse(List<String> lista) {
    _abilitaClasse = lista;
  }
  int getModificatore(String caratteristica) {
    final valore = _modificatori[caratteristica] ?? 10;
    return ((valore - 10) / 2).floor();
  }


  // Tratti e caratteristiche
  void addCompetenza(String competenza) => _competenze.add(competenza);

  void addBonusCaratteristiche(Map<String, int> bonus) {
    bonus.forEach((caratteristica, valore) {
      _modificatori.update(caratteristica, (v) => v + valore, ifAbsent: () => valore);
    });
  }

  void setVelocita(int velocita) {
    _velocita = velocita;
  }

  void addLinguaggi(List<String> lingue) {
    _linguaggi.addAll(lingue.where((l) => !_linguaggi.contains(l)));
  }

  void addTrattiSpecie(List<String> tratti) {
    _capacitaSpeciali.addAll(tratti);
  }

  PGBase build() {
    return PGBase(
      nome: _nome,
      specie: _specie,
      classe: _classe,
      background: _background,
      allineamento: _allineamento,
      competenze: List.from(_competenze),
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
