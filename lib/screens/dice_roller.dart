import 'package:flutter/material.dart';
import 'dart:math';

class DiceRollerScreen extends StatefulWidget {
  @override
  _DiceRollerScreenState createState() => _DiceRollerScreenState();
}

class _DiceRollerScreenState extends State<DiceRollerScreen> {
  final _random = Random();
  int _numeroDadi = 1;
  int _facceDado = 6;
  List<int> _risultati = [];

  void _lanciaDadi() {
    setState(() {
      _risultati = List.generate(_numeroDadi, (_) => _random.nextInt(_facceDado) + 1);
    });
  }

  int get _somma => _risultati.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tira Dadi")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("Numero di dadi:"),
                SizedBox(width: 10),
                DropdownButton<int>(
                  value: _numeroDadi,
                  onChanged: (val) => setState(() => _numeroDadi = val!),
                  items: List.generate(20, (i) => i + 1)
                      .map((v) => DropdownMenuItem(value: v, child: Text("$v")))
                      .toList(),
                ),
              ],
            ),
            Row(
              children: [
                Text("Tipo di dado:"),
                SizedBox(width: 10),
                DropdownButton<int>(
                  value: _facceDado,
                  onChanged: (val) => setState(() => _facceDado = val!),
                  items: [4, 6, 8, 10, 12, 20, 100]
                      .map((f) => DropdownMenuItem(value: f, child: Text("d$f")))
                      .toList(),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _lanciaDadi,
              child: Text("Lancia $_numeroDadi d$_facceDado"),
            ),
            SizedBox(height: 16),
            if (_risultati.isNotEmpty) ...[
              Text("Risultati: ${_risultati.join(", ")}", style: TextStyle(fontSize: 18)),
              Text("Somma: $_somma", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ]
          ],
        ),
      ),
    );
  }
}
