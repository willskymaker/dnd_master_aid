import 'package:flutter/material.dart';
import 'dart:math';

class DiceRollerScreen extends StatefulWidget {
  @override
  _DiceRollerScreenState createState() => _DiceRollerScreenState();
}

class _DiceRollerScreenState extends State<DiceRollerScreen> {
  int _risultato = 0;
  final _random = Random();

  void _lanciaDado(int facce) {
    setState(() {
      _risultato = _random.nextInt(facce) + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tira Dadi")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text("Risultato: $_risultato", style: TextStyle(fontSize: 32)),
            SizedBox(height: 20),
            Wrap(
              spacing: 10,
              children: [4, 6, 8, 10, 12, 20, 100].map((facce) {
                return ElevatedButton(
                  onPressed: () => _lanciaDado(facce),
                  child: Text("d$facce"),
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}

