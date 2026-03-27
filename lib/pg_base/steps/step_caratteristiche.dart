import 'package:flutter/material.dart';
import '../../factory_pg_base.dart';
import '../../data/db_classi.dart';
import '../utils/pf_helper.dart';
import '../utils/asi_helper.dart';
import '../../core/logger.dart';
import '../../core/exceptions.dart';

final List<int> standardArray = [15, 14, 13, 12, 10, 8];
final List<String> caratteristiche = ['FOR', 'DES', 'COS', 'INT', 'SAG', 'CAR'];

const Map<String, String> _nomiCompleti = {
  'FOR': 'Forza',
  'DES': 'Destrezza',
  'COS': 'Costituzione',
  'INT': 'Intelligenza',
  'SAG': 'Saggezza',
  'CAR': 'Carisma',
};

class StepCaratteristicheScreen extends StatefulWidget {
  final PGBaseFactory factory;

  const StepCaratteristicheScreen({super.key, required this.factory});

  @override
  State<StepCaratteristicheScreen> createState() => _StepCaratteristicheScreenState();
}

class _StepCaratteristicheScreenState extends State<StepCaratteristicheScreen> {
  late Map<String, int> baseStats;
  late final List<String> prioritarie;
  late int puntiDisponibili;

  @override
  void initState() {
    super.initState();

    final classe = classiList.firstWhere(
      (c) => c.nome == widget.factory.build().classe,
      orElse: () => classiList.first,
    );

    const Map<String, List<String>> suggeritePerClasse = {
      "Barbaro": ["FOR", "COS"],
      "Bardo": ["CAR", "DES"],
      "Chierico": ["SAG", "COS"],
      "Druido": ["SAG", "INT"],
      "Guerriero": ["FOR", "COS"],
      "Ladro": ["DES", "INT"],
      "Mago": ["INT", "DES"],
      "Monaco": ["DES", "SAG"],
      "Paladino": ["FOR", "CAR"],
      "Ranger": ["DES", "SAG"],
      "Stregone": ["CAR", "COS"],
      "Warlock": ["CAR", "SAG"]
    };

    prioritarie = suggeritePerClasse[classe.nome] ?? [];

    final int puntiBase = standardArray.reduce((a, b) => a + b);
    final int minCaratteristica = 8 * caratteristiche.length;
    puntiDisponibili = calcolaASI(livello: widget.factory.livello) * 2 + (puntiBase - minCaratteristica);

    baseStats = {for (var stat in caratteristiche) stat: 8};
  }

  int get _puntiSpesi =>
      baseStats.values.reduce((a, b) => a + b) - (8 * caratteristiche.length);

  int get _puntiRimanenti => puntiDisponibili - _puntiSpesi;

  int _modificatore(int valore) => ((valore - 10) / 2).floor();

  void _conferma() {
    try {
      if (!_validaCaratteristiche()) return;

      final mod = <String, int>{
        for (var e in baseStats.entries) e.key: _modificatore(e.value)
      };

      final pf = calcolaPuntiFerita(
        livello: widget.factory.livello,
        dadoVita: widget.factory.dadoVita,
        modCostituzione: mod['COS']!,
      );

      if (pf <= 0) {
        throw ValidationException(
            "I punti vita non possono essere zero o negativi", "Caratteristiche");
      }

      widget.factory.setCaratteristiche(baseStats);
      widget.factory.setPuntiVita(pf);

      AppLogger.info("Caratteristiche assegnate: $baseStats");
      AppLogger.debug("Modificatori calcolati: $mod");
      AppLogger.debug("PF: $pf");

      Navigator.pop(context, true);
    } catch (e) {
      AppLogger.error("Errore nella conferma caratteristiche", e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Errore: $e"), backgroundColor: Colors.red),
      );
    }
  }

  bool _validaCaratteristiche() {
    for (var entry in baseStats.entries) {
      if (entry.value < 3 || entry.value > 20) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "${_nomiCompleti[entry.key]} deve essere tra 3 e 20 (attuale: ${entry.value})"),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }

    if (_puntiRimanenti < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Hai usato $_puntiSpesi punti su $puntiDisponibili disponibili"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  void _saltaStep() {
    final defaultStats = {for (var c in caratteristiche) c: 10};
    widget.factory.setCaratteristiche(defaultStats);
    widget.factory.setPuntiVita(
      calcolaPuntiFerita(
        livello: widget.factory.livello,
        dadoVita: widget.factory.dadoVita,
        modCostituzione: 0,
      ),
    );
    AppLogger.debug("Caratteristiche default: $defaultStats");
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final rimanenti = _puntiRimanenti;
    final coloreRimanenti =
        rimanenti < 0 ? Colors.red : (rimanenti == 0 ? Colors.green : Colors.orange);

    // Calcola PF preview
    final modCos = _modificatore(baseStats['COS']!);
    final pfPreview = calcolaPuntiFerita(
      livello: widget.factory.livello,
      dadoVita: widget.factory.dadoVita,
      modCostituzione: modCos,
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Caratteristiche")),
      body: Column(
        children: [
          // Riquadro punti rimanenti + PF preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: coloreRimanenti.withValues(alpha: 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      '$rimanenti',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: coloreRimanenti,
                      ),
                    ),
                    Text('punti rimanenti',
                        style: TextStyle(fontSize: 12, color: coloreRimanenti)),
                  ],
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                Column(
                  children: [
                    Text(
                      '$pfPreview',
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B4513)),
                    ),
                    const Text('PF stimati',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          // Lista caratteristiche
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: caratteristiche.map((stat) {
                final valore = baseStats[stat]!;
                final mod = _modificatore(valore);
                final modStr = mod >= 0 ? '+$mod' : '$mod';
                final evidenziata = prioritarie.contains(stat);
                final puoAumentare = rimanenti > 0 && valore < 20;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: evidenziata
                      ? const Color(0xFF8B4513).withValues(alpha: 0.08)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: evidenziata
                        ? const BorderSide(
                            color: Color(0xFF8B4513), width: 1.5)
                        : BorderSide.none,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        // Nome
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(stat,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Color(0xFF8B4513))),
                                  if (evidenziata) ...[
                                    const SizedBox(width: 6),
                                    const Icon(Icons.star,
                                        size: 14, color: Color(0xFF8B4513)),
                                  ]
                                ],
                              ),
                              Text(_nomiCompleti[stat] ?? '',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                        // Bottone -
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          color: valore > 8 ? Colors.red.shade400 : Colors.grey,
                          onPressed: valore > 8
                              ? () => setState(
                                  () => baseStats[stat] = valore - 1)
                              : null,
                        ),
                        // Valore + modificatore
                        SizedBox(
                          width: 64,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('$valore',
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold)),
                              Text(modStr,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: mod >= 0
                                          ? Colors.green.shade700
                                          : Colors.red.shade700)),
                            ],
                          ),
                        ),
                        // Bottone +
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          color: puoAumentare
                              ? Colors.green.shade600
                              : Colors.grey,
                          onPressed: puoAumentare
                              ? () => setState(
                                  () => baseStats[stat] = valore + 1)
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Bottoni
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _conferma,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B4513),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Conferma Punteggi',
                        style: TextStyle(fontSize: 16)),
                  ),
                ),
                TextButton(
                  onPressed: _saltaStep,
                  child: const Text('Salta Step'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

int calcolaASI({required int livello}) => (livello / 4).floor();

