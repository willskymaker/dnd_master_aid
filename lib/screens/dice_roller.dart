import 'package:flutter/material.dart';
import 'dart:math';

class DiceRollerScreen extends StatefulWidget {
  const DiceRollerScreen({super.key});  // ✅ Costruttore const aggiunto

  @override
  State<DiceRollerScreen> createState() => _DiceRollerScreenState();
}

class _DiceRollerScreenState extends State<DiceRollerScreen> {
  final Random _random = Random();
  int _numeroDadi = 1;
  int _facceDado = 6;
  List<int> _risultati = [];

  void _lanciaDadi() {
    setState(() {
      _risultati = List.generate(
        _numeroDadi,
        (_) => _random.nextInt(_facceDado) + 1,
      );
    });
  }

  int get _somma => _risultati.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tira Dadi")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text("Numero di dadi:"),
                const SizedBox(width: 10),
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
                const Text("Tipo di dado:"),
                const SizedBox(width: 10),
                DropdownButton<int>(
                  value: _facceDado,
                  onChanged: (val) => setState(() => _facceDado = val!),
                  items: [4, 6, 8, 10, 12, 20, 100]
                      .map((f) => DropdownMenuItem(value: f, child: Text("d$f")))
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _lanciaDadi,
              child: Text("Lancia $_numeroDadi d$_facceDado"),
            ),
            const SizedBox(height: 16),
            if (_risultati.isNotEmpty) ...[
              Text("Risultati: ${_risultati.join(", ")}",
                  style: const TextStyle(fontSize: 18)),
              Text("Somma: $_somma",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
            ]
          ],
        ),
      ),
    );
  }
}
