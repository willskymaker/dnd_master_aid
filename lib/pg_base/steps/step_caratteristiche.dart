import 'package:flutter/material.dart';
import '../../factory_pg_base.dart';
import '../../data/db_classi.dart';

final List<int> standardArray = [15, 14, 13, 12, 10, 8];
final List<String> caratteristiche = ['FOR', 'DES', 'COS', 'INT', 'SAG', 'CAR'];

class StepCaratteristicheScreen extends StatefulWidget {
  final PGBaseFactory factory;

  const StepCaratteristicheScreen({super.key, required this.factory});

  @override
  State<StepCaratteristicheScreen> createState() => _StepCaratteristicheScreenState();
}

class _StepCaratteristicheScreenState extends State<StepCaratteristicheScreen> {
  final Map<String, int?> assegnate = {};
  List<int> disponibili = List.from(standardArray);

  late final List<String> prioritarie;

  @override
  void initState() {
    super.initState();

    // Recupera la classe scelta per evidenziare le caratteristiche principali
    final classe = classiList.firstWhere(
      (c) => c.nome == widget.factory.build().classe,
      orElse: () => classiList.first,
    );

    // In assenza di campo dedicato, assegniamo in modo euristico (in futuro da db)
    final Map<String, List<String>> suggeritePerClasse = {
      "Barbaro": ["FOR", "COS"],
      "Ladro": ["DES", "INT"],
      "Mago": ["INT", "SAG"],
      "Chierico": ["SAG", "CAR"],
      "Paladino": ["FOR", "CAR"],
      "Ranger": ["DES", "SAG"],
      "Guerriero": ["FOR", "DES"],
      "Bardo": ["CAR", "DES"],
      "Monaco": ["DES", "SAG"],
      "Druido": ["SAG", "INT"],
      "Stregone": ["CAR", "COS"],
      "Warlock": ["CAR", "SAG"],
    };

    prioritarie = suggeritePerClasse[classe.nome] ?? [];
  }

  void _conferma() {
    if (assegnate.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Assegna tutti i punteggi alle caratteristiche.")),
      );
      return;
    }

    widget.factory.setCaratteristiche(Map.fromEntries(
      assegnate.entries.map((e) => MapEntry(e.key, e.value!)),
    ));

    Navigator.pop(context);
  }

  void _saltaStep() {
    widget.factory.setCaratteristiche({
      for (var c in caratteristiche) c: 10,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Step: Caratteristiche")),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
                  trailing: DropdownButton<int>(
                    hint: const Text("Scegli"),
                    value: assegnate[stat],
                    items: standardArray
                        .where((val) => !assegnate.values.contains(val) || assegnate[stat] == val)
                        .map((val) => DropdownMenuItem(value: val, child: Text("$val")))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        assegnate[stat] = val;
                      });
                    },
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _conferma,
              child: const Text("Conferma Punteggi"),
            ),
            TextButton(
              onPressed: _saltaStep,
              child: const Text("Salta Step"),
            )
          ],
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
