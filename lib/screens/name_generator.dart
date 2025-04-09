import 'package:flutter/material.dart';
import '../factory_pg_base.dart';
import 'dart:math'; // ✅ IMPORTA Random

class NameGeneratorScreen extends StatefulWidget {
  final PGBaseFactory factory;

  const NameGeneratorScreen({super.key, required this.factory});

  @override
  State<NameGeneratorScreen> createState() => _NameGeneratorScreenState();
}

class _NameGeneratorScreenState extends State<NameGeneratorScreen> {
  final _random = Random();
  final _prefissi = ["El", "Fa", "Al", "Thar", "Mor", "Gla", "Ka", "Thal", "Zan", "Dan", "Den", "Gul", "Gor", "An", "Der", "Bel"];
  final _suffissi = ["dor", "ion", "mir", "rien", "dil", "gar", "gon", "ril", "eth", "las", "ent", "gil", "fil"];
  final _cognomi = ["Ombrafuoco", "Cuorepuro", "Ventoargenteo", "Dentedrago", "Manoferma", "Cuoreardente", "Pietralama", "Lunargento", "Denteombra", "Ferroduro", "Ambrato", "Mordiroccia"];

  String _nomeGenerato = "";

  void _generaNome() {
    final nome = _prefissi[_random.nextInt(_prefissi.length)] +
        _suffissi[_random.nextInt(_suffissi.length)];
    final cognome = _cognomi[_random.nextInt(_cognomi.length)];

    final nomeCompleto = "$nome $cognome";
    widget.factory.setNome(nomeCompleto); // ✅ salva direttamente nella factory

    setState(() {
      _nomeGenerato = nomeCompleto;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Generatore di Nomi")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              _nomeGenerato.isEmpty ? "Premi per generare" : _nomeGenerato,
              style: const TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generaNome,
              child: const Text("Genera Nome"),
            )
          ],
        ),
      ),
    );
  }
}
