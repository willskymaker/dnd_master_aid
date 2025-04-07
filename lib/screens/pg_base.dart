// lib/screens/pg_base.dart

import 'package:flutter/material.dart';
import '../utils/pdf_generator.dart';

class PgBaseScreen extends StatefulWidget {
  @override
  _PgBaseScreenState createState() => _PgBaseScreenState();
}

class _PgBaseScreenState extends State<PgBaseScreen> {
  int _step = 1;
  String? _nome, _specie, _classe, _armaturaSelezionata;
  int _livello = 1, _puntiDisponibili = 27, _bonusCompetenza = 2;
  List<String> _armiSelezionate = [], _competenzeSelezionate = [];

  final Map<String, int> _caratteristiche = {
    'FOR': 8, 'DES': 8, 'COS': 8, 'INT': 8, 'SAG': 8, 'CAR': 8
  };

  final List<String> _specieList = ["Umano", "Elfo", "Nano", "Halfling", "Dragonide"];
  final List<String> _classeList = ["Guerriero", "Ladro", "Mago", "Chierico", "Barbaro"];
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
      {"nome": "Atletica", "stat": "FOR"}, {"nome": "Intimidazione", "stat": "CAR"},
      {"nome": "Percezione", "stat": "SAG"}, {"nome": "Sopravvivenza", "stat": "SAG"}
    ],
    "Ladro": [
      {"nome": "Furtività", "stat": "DES"}, {"nome": "Acrobazia", "stat": "DES"},
      {"nome": "Percezione", "stat": "SAG"}, {"nome": "Rapidità di mano", "stat": "DES"}
    ],
    "Mago": [
      {"nome": "Arcano", "stat": "INT"}, {"nome": "Indagare", "stat": "INT"},
      {"nome": "Storia", "stat": "INT"}, {"nome": "Religione", "stat": "INT"}
    ],
    "Chierico": [
      {"nome": "Intuizione", "stat": "SAG"}, {"nome": "Medicina", "stat": "SAG"},
      {"nome": "Religione", "stat": "INT"}, {"nome": "Persuasione", "stat": "CAR"}
    ],
    "Barbaro": [
      {"nome": "Atletica", "stat": "FOR"}, {"nome": "Sopravvivenza", "stat": "SAG"},
      {"nome": "Intimidazione", "stat": "CAR"}, {"nome": "Percezione", "stat": "SAG"}
    ],
  };

  final Map<String, int> _numeroCompetenzePerClasse = {
    "Guerriero": 2, "Ladro": 4, "Mago": 2, "Chierico": 2, "Barbaro": 2
  };

  @override
  void initState() {
    super.initState();
    _aggiornaDatiLivello();
  }

  void _aggiornaDatiLivello() {
    _puntiDisponibili = 27 + ((_livello - 1) ~/ 4) * 2;
    _bonusCompetenza = [2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6][_livello - 1];
  }

  int _calcolaTotalePunti() {
    return _caratteristiche.values.fold(0, (totale, val) => totale + (val <= 13 ? val - 8 : 5 + (val - 13) * 2));
  }

  int _calcolaMod(String stat) => ((_caratteristiche[stat] ?? 10) - 10) ~/ 2;

  int _calcolaHP() {
    final base = {"Barbaro": 12, "Guerriero": 10, "Chierico": 8, "Ladro": 8, "Mago": 6};
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
      if (armatura["caBonus"] != null) ca += armatura["caBonus"] as int;
    }
    return ca;
  }

  void _calcolaStatisticheFinali() {
    final hp = _calcolaHP();
    final ca = _calcolaCA();
    print("✅ Statistiche finali:");
    print("HP: $hp");
    print("CA: $ca");
    print("Armi: $_armiSelezionate");
    print("Competenze: $_competenzeSelezionate");
  }

  Map<String, dynamic> get schedaPG => {
    'nome': _nome, 'specie': _specie, 'classe': _classe, 'livello': _livello,
    'bonusCompetenza': _bonusCompetenza, 'caratteristiche': _caratteristiche,
    'competenze': _competenzeSelezionate, 'armi': _armiSelezionate,
    'armatura': _armaturaSelezionata, 'ca': _calcolaCA(), 'hp': _calcolaHP(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crea PG Base')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildStep(),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 1: return _buildStep1();
      case 2: return _buildStep2();
      case 3: return _buildStep3();
      default: return Center(child: Text('✅ Personaggio creato!'));
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Nome del personaggio:"),
        TextField(onChanged: (val) => _nome = val, decoration: InputDecoration(hintText: "Es. Elrand")),
        SizedBox(height: 16),
        Text("Specie:"),
        DropdownButton<String>(
          value: _specie,
          hint: Text("Scegli la specie"),
          onChanged: (val) => setState(() => _specie = val),
          items: _specieList.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
        ),
        SizedBox(height: 16),
        Text("Classe:"),
        DropdownButton<String>(
          value: _classe,
          hint: Text("Scegli la classe"),
          onChanged: (val) => setState(() => _classe = val),
          items: _classeList.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
        ),
        SizedBox(height: 16),
        Text("Livello:"),
        DropdownButton<int>(
          value: _livello,
          onChanged: (val) => setState(() => _livello = val ?? 1),
          items: List.generate(20, (i) => i + 1).map((lvl) => DropdownMenuItem(value: lvl, child: Text("$lvl"))).toList(),
        ),
        SizedBox(height: 8),
        Text("Bonus competenza: $_bonusCompetenza"),
        Spacer(),
        ElevatedButton(
          onPressed: (_nome != null && _specie != null && _classe != null) ? () => setState(() => _step = 2) : null,
          child: Text("Avanti"),
        )
      ],
    );
  }

  Widget _buildStep2() {
    final puntiRestanti = _puntiDisponibili - _calcolaTotalePunti();
    final competenzeDisponibili = _competenzePerClasse[_classe] ?? [];
    final maxCompetenze = _numeroCompetenzePerClasse[_classe] ?? 2;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Assegna i punteggi delle caratteristiche (point buy semplificato):"),
            Text("Punti disponibili: $puntiRestanti", style: TextStyle(fontWeight: FontWeight.bold)),
            ..._caratteristiche.keys.map((stat) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("$stat: ${_caratteristiche[stat]} (mod: ${_calcolaMod(stat)})", style: TextStyle(fontSize: 16)),
                Row(children: [
                  IconButton(icon: Icon(Icons.remove), onPressed: () => setState(() => _caratteristiche[stat] = (_caratteristiche[stat]! - 1).clamp(8, 20))),
                  IconButton(icon: Icon(Icons.add),
                    onPressed: (puntiRestanti > 0 && _caratteristiche[stat]! < 20)
                      ? () => setState(() => _caratteristiche[stat] = (_caratteristiche[stat]! + 1).clamp(8, 20))
                      : null,
                  )
                ])
              ],
            )),
            Divider(),
            Text("Seleziona fino a $maxCompetenze competenze:"),
            ...competenzeDisponibili.map((comp) => CheckboxListTile(
              title: Text("${comp['nome']} (${comp['stat']})"),
              value: _competenzeSelezionate.contains(comp['nome']),
              onChanged: (val) => setState(() {
                if (val == true && _competenzeSelezionate.length < maxCompetenze) {
                  _competenzeSelezionate.add(comp['nome']!);
                } else if (val == false) {
                  _competenzeSelezionate.remove(comp['nome']);
                }
              })
            )),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: (puntiRestanti == 0 && _competenzeSelezionate.length == maxCompetenze)
                  ? () => setState(() => _step = 3) : null,
                child: Text("Avanti"),
              ),
            )
          ],
        ),
      ),
    );
  }

 Widget _buildStep3() {
  return SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Seleziona due armi:"),
          ..._armiDisponibili.map((arma) => CheckboxListTile(
            title: Text(arma),
            value: _armiSelezionate.contains(arma),
            onChanged: (val) => setState(() {
              if (val == true && _armiSelezionate.length < 2) {
                _armiSelezionate.add(arma);
              } else if (val == false) {
                _armiSelezionate.remove(arma);
              }
            })
          )),
          Divider(),
          Text("Seleziona un'armatura:"),
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
                  ? () {
                      setState(() => _step = 4);
                    }
                  : null,
              child: Text("Crea Personaggio"),
            ),
          ),
          SizedBox(height: 12),
          Center(
            child: ElevatedButton.icon(
              onPressed: () async => await generaSchedaPersonaggioPDF(schedaPG),
              icon: Icon(Icons.picture_as_pdf),
              label: Text("Esporta in PDF"),
            ),
          ),
        ],
      ),
    ),
  );
}

}
