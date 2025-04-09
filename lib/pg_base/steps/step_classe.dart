import 'package:flutter/material.dart';
import '../../factory_pg_base.dart';

// Lista semplificata per il PG base
final List<String> classiCore = [
  "Barbaro", "Bardo", "Chierico", "Druido",
  "Guerriero", "Ladro", "Mago", "Monaco",
  "Paladino", "Ranger", "Stregone", "Warlock"
];

class StepClasseScreen extends StatelessWidget {
  final PGBaseFactory factory;

  const StepClasseScreen({super.key, required this.factory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Step 3: Scegli la Classe")),
      body: ListView.builder(
        itemCount: classiCore.length,
        itemBuilder: (context, index) {
          final classe = classiCore[index];

          return Card(
            child: ListTile(
              title: Text(classe),
              onTap: () {
                factory.setClasse(classe);
                Navigator.pop(context);
              },
            ),
          );
        },
      ),
    );
  }
}

/// Funzione helper per il wizard
Future<void> vaiAStepClasse(BuildContext context, PGBaseFactory factory) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => StepClasseScreen(factory: factory),
    ),
  );
}
