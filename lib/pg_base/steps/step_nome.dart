import 'package:flutter/material.dart';
import '../../factory_pg_base.dart';
import '../../screens/name_generator.dart';

/// Widget per lo step 1: scelta del nome
class StepNomeScreen extends StatefulWidget {
  final PGBaseFactory factory;

  const StepNomeScreen({super.key, required this.factory});

  @override
  State<StepNomeScreen> createState() => _StepNomeScreenState();
}

class _StepNomeScreenState extends State<StepNomeScreen> {
  final TextEditingController _controller = TextEditingController();

  void _vaiAlGeneratore() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NameGeneratorScreen(factory: widget.factory),
      ),
    );

    // Ricarica il nome se è stato modificato nella factory
    setState(() {
      _controller.text = widget.factory.build().nome;
    });
  }

  void _confermaNome() {
    final nome = _controller.text.trim();
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inserisci o genera un nome.")),
      );
      return;
    }

    widget.factory.setNome(nome);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Step 1: Nome del Personaggio")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Inserisci il nome",
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _vaiAlGeneratore,
              icon: const Icon(Icons.casino),
              label: const Text("Genera Nome Automaticamente"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _confermaNome,
              child: const Text("Conferma Nome"),
            )
          ],
        ),
      ),
    );
  }
}
/// Funzione helper per lanciare lo step dal flusso principale
Future<void> vaiAStepNome(BuildContext context, PGBaseFactory factory) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => StepNomeScreen(factory: factory),
    ),
  );
}