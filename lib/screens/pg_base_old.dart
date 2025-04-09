// Parte 1 del file pg_base.dart - header e step 1

import 'package:flutter/material.dart';
import '../utils/pdf_generator.dart';

class PgBaseScreen extends StatefulWidget {
  @override
  _PgBaseScreenState createState() => _PgBaseScreenState();
  
}

class _PgBaseScreenState extends State<PgBaseScreen> {
  int _step = 1;
  String? _nome, _specie, _classe, _background, _armaturaSelezionata;
  int _livello = 1, _puntiDisponibili = 27, _bonusCompetenza = 2;
  List<String> _armiSelezionate = [], _competenzeSelezionate = [];

  final Map<String, int> _caratteristiche = {
    'FOR': 8, 'DES': 8, 'COS': 8, 'INT': 8, 'SAG': 8, 'CAR': 8
  };

  final List<String> _armiDisponibili = ["Spada corta", "Ascia", "Pugnale", "Mazza", "Arco corto"];
  final List<String> _armatureDisponibili = ["Nessuna", "Armatura di cuoio", "Cotta di maglia", "Scudo"];

  final Map<String, Map<String, dynamic>> _datiArmature = {
    "Nessuna": {"caBase": 10, "bonusDes": true},
    "Armatura di cuoio": {"caBase": 11, "bonusDes": true},
    "Cotta di maglia": {"caBase": 16, "bonusDes": false},
    "Scudo": {"caBonus": 2},
  };

  final Map<String, List<Map<String, String>>> _competenzePerClasse = {
    "Guerriero": [
      {"nome": "Atletica", "stat": "FOR"},
      {"nome": "Intimidazione", "stat": "CAR"},
      {"nome": "Percezione", "stat": "SAG"},
      {"nome": "Sopravvivenza", "stat": "SAG"}
    ],
    "Ladro": [
      {"nome": "Furtività", "stat": "DES"},
      {"nome": "Acrobazia", "stat": "DES"},
      {"nome": "Percezione", "stat": "SAG"},
      {"nome": "Rapidità di mano", "stat": "DES"}
    ],
    "Mago": [
      {"nome": "Arcano", "stat": "INT"},
      {"nome": "Indagare", "stat": "INT"},
      {"nome": "Storia", "stat": "INT"},
      {"nome": "Religione", "stat": "INT"}
    ],
    "Chierico": [
      {"nome": "Intuizione", "stat": "SAG"},
      {"nome": "Medicina", "stat": "SAG"},
      {"nome": "Religione", "stat": "INT"},
      {"nome": "Persuasione", "stat": "CAR"}
    ],
    "Barbaro": [
      {"nome": "Atletica", "stat": "FOR"},
      {"nome": "Sopravvivenza", "stat": "SAG"},
      {"nome": "Intimidazione", "stat": "CAR"},
      {"nome": "Percezione", "stat": "SAG"}
    ],
  };

  final Map<String, int> _numeroCompetenzePerClasse = {
    "Guerriero": 2, "Ladro": 4, "Mago": 2, "Chierico": 2, "Barbaro": 2
  };

  @override
  void initState() {
    super.initState();
    _bonusCompetenza = _calcolaBonusCompetenza(_livello);
  }

  int _calcolaBonusCompetenza(int livello) {
    return 2 + ((livello - 1) ~/ 4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Crea Personaggio")),
      body: _buildStep(),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      case 4:
        return _buildStep4();
      default:
        return Center(child: Text("Errore: Step sconosciuto"));
    }
  }

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Nome del personaggio:"),
          TextField(onChanged: (val) => _nome = val),
          SizedBox(height: 12),
          Text("Specie:"),
          DropdownButton<String>(
            value: _specie,
            hint: Text("Scegli la specie"),
            onChanged: (val) => setState(() => _specie = val),
            items: ["Umano", "Elfo", "Nano"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          ),
          SizedBox(height: 12),
          Text("Classe:"),
          DropdownButton<String>(
            value: _classe,
            hint: Text("Scegli la classe"),
            onChanged: (val) => setState(() => _classe = val),
            items: ["Guerriero", "Ladro", "Mago", "Chierico", "Barbaro"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          ),
          SizedBox(height: 12),
          Text("Background:"),
          DropdownButton<String>(
            value: _background,
            hint: Text("Scegli un background"),
            onChanged: (val) => setState(() => _background = val),
            items: ["Avventuriero", "Studioso", "Nomade"].map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
          ),
          SizedBox(height: 12),
          Text("Livello:"),
          DropdownButton<int>(
            value: _livello,
            onChanged: (val) => setState(() {
              _livello = val ?? 1;
              _bonusCompetenza = _calcolaBonusCompetenza(_livello);
            }),
            items: List.generate(20, (i) => i + 1).map((lvl) => DropdownMenuItem(value: lvl, child: Text("$lvl"))).toList(),
          ),
          SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: (_nome != null && _specie != null && _classe != null && _background != null)
                  ? () => setState(() => _step = 2)
                  : null,
              child: Text("Avanti"),
            ),
          )
        ],
      ),
    );
  }
}
// Parte 2: Step 2 (caratteristiche e competenze), Step 3 (armi e armatura)

Widget _buildStep2() {
  final puntiRestanti = _puntiDisponibili - _calcolaTotalePunti();
  final competenzeDisponibili = _competenzePerClasse[_classe] ?? [];
  final maxCompetenze = _numeroCompetenzePerClasse[_classe] ?? 2;

  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Assegna le caratteristiche:", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text("Punti restanti: $puntiRestanti"),
        ..._caratteristiche.keys.map((stat) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("$stat: ${_caratteristiche[stat]} (mod: ${_calcolaMod(stat)})"),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () => setState(() => _caratteristiche[stat] = (_caratteristiche[stat]! - 1).clamp(8, 15)),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: (puntiRestanti > 0 && _caratteristiche[stat]! < 15)
                    ? () => setState(() => _caratteristiche[stat] = (_caratteristiche[stat]! + 1).clamp(8, 15))
                    : null,
                )
              ],
            )
          ],
        )),
        Divider(),
        Text("Competenze disponibili (${_competenzeSelezionate.length}/$maxCompetenze):", style: TextStyle(fontWeight: FontWeight.bold)),
        ...competenzeDisponibili.map((comp) => CheckboxListTile(
          title: Text("${comp['nome']} (${comp['stat']})"),
          value: _competenzeSelezionate.contains(comp['nome']),
          onChanged: (val) => setState(() {
            if (val == true && !_competenzeSelezionate.contains(comp['nome']) && _competenzeSelezionate.length < maxCompetenze) {
              _competenzeSelezionate.add(comp['nome']!);
            } else {
              _competenzeSelezionate.remove(comp['nome']);
            }
          })
        )),
        SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: (puntiRestanti == 0 && _competenzeSelezionate.length == maxCompetenze)
              ? () => setState(() => _step = 3)
              : null,
            child: Text("Avanti"),
          ),
        )
      ],
    ),
  );
}

Widget _buildStep3() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Scegli 2 armi:"),
        ..._armiDisponibili.map((arma) => CheckboxListTile(
          title: Text(arma),
          value: _armiSelezionate.contains(arma),
          onChanged: (val) => setState(() {
            if (val == true && !_armiSelezionate.contains(arma) && _armiSelezionate.length < 2) {
              _armiSelezionate.add(arma);
            } else {
              _armiSelezionate.remove(arma);
            }
          })
        )),
        Divider(),
        Text("Scegli un'armatura:"),
        ..._armatureDisponibili.map((arm) => RadioListTile<String>(
          title: Text(arm),
          value: arm,
          groupValue: _armaturaSelezionata,
          onChanged: (val) => setState(() => _armaturaSelezionata = val),
        )),
        SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: (_armiSelezionate.length == 2 && _armaturaSelezionata != null)
              ? () => setState(() => _step = 4)
              : null,
            child: Text("Visualizza personaggio"),
          ),
        )
      ],
    ),
  );
}

int _calcolaTotalePunti() {
  return _caratteristiche.values.fold(0, (totale, val) {
    if (val <= 13) return totale + (val - 8);
    return totale + 5 + (val - 13) * 2;
  });
}
// Parte 3: Step 4 (riepilogo) + metodi ausiliari e getter finale

Widget _buildStep4() {
  final ca = _calcolaCA();
  final hp = _calcolaHP();

  return SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("\u2705 Personaggio completato!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Divider(),
        Text("Nome: $_nome"),
        Text("Specie: $_specie"),
        Text("Classe: $_classe"),
        Text("Background: $_background"),
        Text("Livello: $_livello"),
        Text("Bonus Competenza: $_bonusCompetenza"),
        Text("HP: $hp"),
        Text("CA: $ca"),
        Text("\nCaratteristiche:"),
        ..._caratteristiche.entries.map((e) => Text("${e.key}: ${e.value} (mod: ${_calcolaMod(e.key)})")),
        Text("\nCompetenze: ${_competenzeSelezionate.join(', ')}"),
        Text("Armi: ${_armiSelezionate.join(', ')}"),
        Text("Armatura: $_armaturaSelezionata"),
        SizedBox(height: 24),
        Center(
          child: ElevatedButton.icon(
            onPressed: () async => await generaSchedaPersonaggioPDF(schedaPG),
            icon: Icon(Icons.picture_as_pdf),
            label: Text("Esporta in PDF"),
          ),
        ),
      ],
    ),
  );
}

int _calcolaCA() {
  int ca = 10 + _calcolaMod('DES');
  final armatura = _datiArmature[_armaturaSelezionata];
  if (armatura != null) {
    if (armatura["caBase"] != null) {
      ca = armatura["caBase"] as int;
      if (armatura["bonusDes"] == true) ca += _calcolaMod('DES');
    }
    if (armatura["caBonus"] != null) ca += armatura["caBonus"] as int;
  }
  return ca;
}

int _calcolaHP() {
  final base = {"Barbaro": 12, "Guerriero": 10, "Chierico": 8, "Ladro": 8, "Mago": 6};
  return (base[_classe] ?? 8) + _calcolaMod('COS');
}

int _calcolaMod(String stat) => ((_caratteristiche[stat] ?? 10) - 10) ~/ 2;

Map<String, dynamic> get schedaPG => {
  'nome': _nome,
  'specie': _specie,
  'classe': _classe,
  'background': _background,
  'livello': _livello,
  'bonusCompetenza': _bonusCompetenza,
  'caratteristiche': _caratteristiche,
  'competenze': _competenzeSelezionate,
  'armi': _armiSelezionate,
  'armatura': _armaturaSelezionata,
  'ca': _calcolaCA(),
  'hp': _calcolaHP(),
};
// pg_base.dart completo - con tutte le variabili e metodi definiti

import 'package:flutter/material.dart';
import '../../utils/pdf_generator.dart';

class PgBaseScreen extends StatefulWidget {
  @override
  _PgBaseScreenState createState() => _PgBaseScreenState();
}

class _PgBaseScreenState extends State<PgBaseScreen> {
  String? _nome;
  String? _specie;
  String? _classe;
  String? _background;
  int _livello = 1;
  int _bonusCompetenza = 2;
  int _step = 1;
  int _puntiDisponibili = 27;

  final Map<String, int> _caratteristiche = {
    'FOR': 8,
    'DES': 8,
    'COS': 8,
    'INT': 8,
    'SAG': 8,
    'CAR': 8,
  };

  final List<String> _competenzeSelezionate = [];
  final List<String> _armiSelezionate = [];
  String? _armaturaSelezionata;

  final Map<String, List<String>> _competenzePerClasse = {
    'Guerriero': ['Atletica', 'Intimidire', 'Percezione'],
    'Mago': ['Arcano', 'Indagare', 'Storia'],
  };

  final Map<String, int> _numeroCompetenzePerClasse = {
    'Guerriero': 2,
    'Mago': 2,
  };

  final List<String> _armiDisponibili = ['Spada', 'Arco', 'Bacchetta'];

  final Map<String, Map<String, dynamic>> _datiArmature = {
    'Cuoi': {'caBase': 11, 'bonusDes': true},
    'Maglia': {'caBase': 16, 'bonusDes': false},
  };

  final List<String> _armatureDisponibili = ['Cuoi', 'Maglia'];

  @override
  void initState() {
    super.initState();
    _puntiDisponibili = 27 + ((_livello - 1) ~/ 4) * 2;
    _bonusCompetenza = _calcolaBonusCompetenza(_livello);
  }

  int _calcolaBonusCompetenza(int livello) => 2 + ((livello - 1) ~/ 4);

  int _calcolaTotalePunti() => _caratteristiche.values.fold(0, (totale, val) {
    if (val < 14) return totale + (val - 8);
    if (val == 14) return totale + 7;
    if (val == 15) return totale + 9;
    return totale;
  });

  int _calcolaMod(String stat) => ((_caratteristiche[stat] ?? 10) - 10) ~/ 2;

  int _calcolaHP() {
    final base = {'Guerriero': 10, 'Mago': 6};
    return (base[_classe] ?? 8) + _calcolaMod('COS');
  }

  int _calcolaCA() {
    int ca = 10 + _calcolaMod('DES');
    final armatura = _datiArmature[_armaturaSelezionata];
    if (armatura != null) {
      if (armatura["caBase"] != null) {
        ca = armatura["caBase"] as int;
        if (armatura["bonusDes"] == true) ca += _calcolaMod('DES');
      }
    }
    return ca;
  }

  Map<String, dynamic> get schedaPG => {
    'nome': _nome,
    'specie': _specie,
    'classe': _classe,
    'background': _background,
    'livello': _livello,
    'bonusCompetenza': _bonusCompetenza,
    'caratteristiche': _caratteristiche,
    'competenze': _competenzeSelezionate,
    'armi': _armiSelezionate,
    'armatura': _armaturaSelezionata,
    'ca': _calcolaCA(),
    'hp': _calcolaHP(),
  };

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      case 4:
        return _buildStep4();
      default:
        return Center(child: Text("Errore: step non valido"));
    }
  }

  
}
