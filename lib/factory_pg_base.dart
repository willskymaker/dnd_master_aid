import 'package:uuid/uuid.dart';

class PGBase {
  final String id;
  final DateTime dataSalvataggio;
  final String nome;
  final String specie;
  final String classe;
  final int livello;
  final String background;
  final String allineamento;
  final List<String> competenze;
  final Map<String, int> caratteristiche;
  final Map<String, int> modificatori;
  final bool caratteristicheImpostate;
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
  final List<String> equipaggiamento;

  PGBase({
    String? id,
    DateTime? dataSalvataggio,
    required this.nome,
    required this.specie,
    required this.classe,
    required this.livello,
    required this.background,
    required this.allineamento,
    required this.competenze,
    required this.caratteristiche,
    required this.modificatori,
    required this.caratteristicheImpostate,
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
    required this.equipaggiamento,
  })  : id = id ?? const Uuid().v4(),
        dataSalvataggio = dataSalvataggio ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'dataSalvataggio': dataSalvataggio.toIso8601String(),
        'nome': nome,
        'specie': specie,
        'classe': classe,
        'livello': livello,
        'background': background,
        'allineamento': allineamento,
        'competenze': competenze,
        'caratteristiche': caratteristiche,
        'modificatori': modificatori,
        'caratteristicheImpostate': caratteristicheImpostate,
        'velocita': velocita,
        'linguaggi': linguaggi,
        'capacitaSpeciali': capacitaSpeciali,
        'dadoVita': dadoVita,
        'puntiVita': puntiVita,
        'tiriSalvezza': tiriSalvezza,
        'competenzeArmi': competenzeArmi,
        'competenzeArmature': competenzeArmature,
        'competenzeStrumenti': competenzeStrumenti,
        'abilitaClasse': abilitaClasse,
        'equipaggiamento': equipaggiamento,
      };

  factory PGBase.fromJson(Map<String, dynamic> json) => PGBase(
        id: json['id'] as String?,
        dataSalvataggio: json['dataSalvataggio'] != null
            ? DateTime.parse(json['dataSalvataggio'] as String)
            : null,
        nome: json['nome'] as String? ?? '',
        specie: json['specie'] as String? ?? '',
        classe: json['classe'] as String? ?? '',
        livello: json['livello'] as int? ?? 1,
        background: json['background'] as String? ?? '',
        allineamento: json['allineamento'] as String? ?? '',
        competenze: List<String>.from(json['competenze'] ?? []),
        caratteristiche: Map<String, int>.from(
            (json['caratteristiche'] as Map?)?.map(
                  (k, v) => MapEntry(k as String, (v as num).toInt()),
                ) ??
                {}),
        modificatori: Map<String, int>.from(
            (json['modificatori'] as Map?)?.map(
                  (k, v) => MapEntry(k as String, (v as num).toInt()),
                ) ??
                {}),
        caratteristicheImpostate:
            json['caratteristicheImpostate'] as bool? ?? false,
        velocita: json['velocita'] as int? ?? 0,
        linguaggi: List<String>.from(json['linguaggi'] ?? []),
        capacitaSpeciali: List<String>.from(json['capacitaSpeciali'] ?? []),
        dadoVita: json['dadoVita'] as int? ?? 8,
        puntiVita: json['puntiVita'] as int? ?? 0,
        tiriSalvezza: List<String>.from(json['tiriSalvezza'] ?? []),
        competenzeArmi: List<String>.from(json['competenzeArmi'] ?? []),
        competenzeArmature: List<String>.from(json['competenzeArmature'] ?? []),
        competenzeStrumenti:
            List<String>.from(json['competenzeStrumenti'] ?? []),
        abilitaClasse: List<String>.from(json['abilitaClasse'] ?? []),
        equipaggiamento: List<String>.from(json['equipaggiamento'] ?? []),
      );

  @override
  String toString() {
    return 'PGBase(nome: $nome, specie: $specie, classe: $classe, livello: $livello, background: $background, allineamento: $allineamento, '
        'modificatori: $modificatori, velocità: $velocita, linguaggi: $linguaggi, capacità: $capacitaSpeciali, '
        'HP: $puntiVita (d${dadoVita}), TS: $tiriSalvezza, armi: $competenzeArmi, armature: $competenzeArmature, strumenti: $competenzeStrumenti, '
        'abilita: $abilitaClasse, equipaggiamento: ${equipaggiamento.isNotEmpty ? equipaggiamento.join(', ') : 'Nessun equipaggiamento'})';
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
  final List<String> _equipaggiamento = [];

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
  void setCompetenzeStrumenti(List<String> lista) =>
      _competenzeStrumenti = lista;
  void setAbilitaClasse(List<String> lista) => _abilitaClasse = lista;
  void setVelocita(int velocita) => _velocita = velocita;
  void addCompetenza(String competenza) => _competenze.add(competenza);
  void addLinguaggi(List<String> lingue) =>
      _linguaggi.addAll(lingue.where((l) => !_linguaggi.contains(l)));
  void addTrattiSpecie(List<String> tratti) => _capacitaSpeciali.addAll(tratti);

  void setCaratteristiche(Map<String, int> valori) {
    _caratteristiche = valori;
    _caratteristicheImpostate = true;
    _modificatori.clear();
    valori.forEach((key, val) {
      _modificatori[key] = ((val - 10) / 2).floor();
    });
  }

  bool get caratteristicheImpostate => _caratteristicheImpostate;

  void addEquipaggiamento(List<String> oggetti) {
    _equipaggiamento.clear();
    _equipaggiamento.addAll(oggetti);
  }

  void setCaratteristicheImpostate(bool value) {
    _caratteristicheImpostate = value;
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
      caratteristicheImpostate: _caratteristicheImpostate,
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
      equipaggiamento: List.from(_equipaggiamento),
    );
  }
}
