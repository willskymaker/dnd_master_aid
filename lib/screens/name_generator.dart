import 'package:flutter/material.dart';
import 'dart:math';

class NameGeneratorScreen extends StatefulWidget {
  @override
  _NameGeneratorScreenState createState() => _NameGeneratorScreenState();
}

class _NameGeneratorScreenState extends State<NameGeneratorScreen> {
  final _random = Random();
  final _prefissi = ["El", "Fa", "Al", "Thar", "Mor", "Gla", "Ka", "Thal", "Zan", "Dan", "Den", "Gul", "Gor", "An", "Der", "Bel"];
  final _suffissi = ["dor", "ion", "mir", "rien", "dil", "gar", "gon", "ril", "eth", "las", "ent", "gil", "fil"];
  final _cognomi = ["Ombrafuoco", "Cuorepuro", "Ventoargenteo", "Dentedrago", "Manoferma", "Cuoreardente", "Pietralama", "Lunargento", "Denteombra", "Ferroduro" "Ambrato", "Mordiroccia"];

  String _nomeGenerato = "";

  void _generaNome() {
    final nome = _prefissi[_random.nextInt(_prefissi.length)] +
        _suffissi[_random.nextInt(_suffissi.length)];
    final cognome = _cognomi[_random.nextInt(_cognomi.length)];

    setState(() {
      _nomeGenerato = "$nome $cognome";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Generatore di Nomi")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(_nomeGenerato.isEmpty ? "Premi per generare" : _nomeGenerato,
                style: TextStyle(fontSize: 24), textAlign: TextAlign.center),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generaNome,
              child: Text("Genera Nome"),
            )
          ],
        ),
      ),
    );
  }
}


