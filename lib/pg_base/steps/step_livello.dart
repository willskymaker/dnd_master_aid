import 'package:flutter/material.dart';
import '../../factory_pg_base.dart';

class StepLivelloScreen extends StatefulWidget {
  final PGBaseFactory factory;

  const StepLivelloScreen({super.key, required this.factory});

  @override
  State<StepLivelloScreen> createState() => _StepLivelloScreenState();
}

class _StepLivelloScreenState extends State<StepLivelloScreen> {
  int? livelloSelezionato;

  void _conferma() {
    if (livelloSelezionato == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Seleziona un livello prima di continuare.")),
      );
      return;
    }

    widget.factory.setLivello(livelloSelezionato!);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Step: Seleziona il Livello")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text("Scegli il livello iniziale del personaggio", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            DropdownButton<int>(
              hint: const Text("Livello"),
              value: livelloSelezionato,
              onChanged: (val) {
                setState(() {
                  livelloSelezionato = val;
                });
              },
              items: List.generate(
                20,
                (index) => DropdownMenuItem(
                  value: index + 1,
                  child: Text("Livello ${index + 1}"),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _conferma,
              child: const Text("Conferma Livello"),
            )
          ],
        ),
      ),
    );
  }
}

/// Funzione helper per il wizard
Future<void> vaiAStepLivello(BuildContext context, PGBaseFactory factory) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => StepLivelloScreen(factory: factory),
    ),
  );
}
