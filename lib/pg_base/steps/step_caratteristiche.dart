import 'package:flutter/material.dart';
import '../../factory_pg_base.dart';
import '../../data/db_classi.dart';
import '../utils/pf_helper.dart';
import '../utils/asi_helper.dart';
import '../../core/logger.dart';
import '../../core/exceptions.dart';

final List<int> standardArray = [15, 14, 13, 12, 10, 8];
final List<String> caratteristiche = ['FOR', 'DES', 'COS', 'INT', 'SAG', 'CAR'];

class StepCaratteristicheScreen extends StatefulWidget {
  final PGBaseFactory factory;

  const StepCaratteristicheScreen({super.key, required this.factory});

  @override
  State<StepCaratteristicheScreen> createState() => _StepCaratteristicheScreenState();
}

class _StepCaratteristicheScreenState extends State<StepCaratteristicheScreen> {
  late Map<String, int> baseStats;
  late final List<String> prioritarie;
  late int asiDisponibili;

  @override
  void initState() {
    super.initState();

    final classe = classiList.firstWhere(
      (c) => c.nome == widget.factory.build().classe,
      orElse: () => classiList.first,
    );

    final Map<String, List<String>> suggeritePerClasse = {
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

    // Si parte dalla standard array per determinare i punti base da assegnare (27)
    final int puntiBase = standardArray.reduce((a, b) => a + b);
    final int minCaratteristica = 8 * caratteristiche.length;
    asiDisponibili = calcolaASI(livello: widget.factory.livello) * 2 + (puntiBase - minCaratteristica);

    baseStats = {
      for (var stat in caratteristiche) stat: 8,
    };
  }

  void _conferma() {
    try {
      // Validazione caratteristiche
      if (!_validaCaratteristiche()) return;

      final mod = <String, int>{};
      baseStats.forEach((key, val) {
        mod[key] = ((val - 10) / 2).floor();
      });

      final pf = calcolaPuntiVita(
        livello: widget.factory.livello,
        dadoVita: widget.factory.dadoVita,
        modificatoreCostituzione: mod['COS']!,
      );

      if (pf <= 0) {
        throw ValidationException("I punti vita non possono essere zero o negativi", "Caratteristiche");
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
        SnackBar(
          content: Text("Errore: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _validaCaratteristiche() {
    // Verifica che tutte le caratteristiche siano nel range valido (3-20)
    for (var entry in baseStats.entries) {
      if (entry.value < 3 || entry.value > 20) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${entry.key} deve essere tra 3 e 20 (attuale: ${entry.value})"),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }

    // Verifica che il totale non superi i punti disponibili
    final totaleUsato = baseStats.values.reduce((a, b) => a + b) - (8 * caratteristiche.length);
    if (totaleUsato > asiDisponibili) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Hai usato $totaleUsato punti su $asiDisponibili disponibili"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  void _saltaStep() {
    final defaultStats = {
      for (var c in caratteristiche) c: 10,
    };
    widget.factory.setCaratteristiche(defaultStats);
    widget.factory.setPuntiVita(
      calcolaPuntiVita(
        livello: widget.factory.livello,
        dadoVita: widget.factory.dadoVita,
        modificatoreCostituzione: 0,
      ),
    );

    AppLogger.debug("Caratteristiche default: $defaultStats");
    Navigator.pop(context, true);
  }

  int calcolaPuntiVita({
    required int livello,
    required int dadoVita,
    required int modificatoreCostituzione,
  }) {
    return livello * (dadoVita + modificatoreCostituzione);
  }

  int calcolaASI({required int livello}) {
    return (livello / 4).floor();
  }

  @override
  Widget build(BuildContext context) {
    final spesi = baseStats.values.reduce((a, b) => a + b) - (8 * caratteristiche.length);

    return Scaffold(
      appBar: AppBar(title: const Text("Step: Caratteristiche")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text("Assegna i punteggi alle caratteristiche", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              ...caratteristiche.map((stat) {
                final evidenziata = prioritarie.contains(stat);
                return Card(
                  color: evidenziata ? Colors.yellow.shade100 : null,
                  child: ListTile(
                    title: Text(stat),
                    subtitle: Text("Valore attuale: ${baseStats[stat]}", style: const TextStyle(fontSize: 16)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (baseStats[stat]! > 8) baseStats[stat] = baseStats[stat]! - 1;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            if (spesi < asiDisponibili && baseStats[stat]! < 20) {
                              setState(() {
                                baseStats[stat] = baseStats[stat]! + 1;
                              });
                            }
                          },
                        )
                      ],
                    ),
                  ),
                );
              }).toList(),
              Text("Punti bonus rimanenti: ${asiDisponibili - spesi}"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _conferma,
                child: const Text("Conferma Punteggi"),
              ),
            TextButton(
              onPressed: () {
                widget.factory.setCaratteristicheImpostate(false); // Imposta a false
                Navigator.pop(context, true); // Procedi allo step successivo
              },
              child: const Text("Salta Step"),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Funzione helper
Future<void> vaiAStepCaratteristiche(BuildContext context, PGBaseFactory factory) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => StepCaratteristicheScreen(factory: factory),
    ),
  );
}