// lib/screens/scheda_output_screen.dart

import 'package:flutter/material.dart';

class SchedaOutputScreen extends StatelessWidget {
  final Map<String, dynamic> schedaPG;

  const SchedaOutputScreen({super.key, required this.schedaPG});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scheda Personaggio")),
      body: Center(
        child: InteractiveViewer(
          child: SizedBox(
            width: 1000,
            height: 1414,
            child: Stack(
              children: [
                Image.asset(
                  'lib/assets/images/scheda_pg_base.png',
                  fit: BoxFit.cover,
                  width: 1000,
                  height: 1414,
                ),
                // Nome del personaggio
                Positioned(
                  left: 200,
                  top: 85,
                  child: Text(
                    schedaPG['nome'] ?? '-',
                    style: _style(),
                  ),
                ),
                // Classe
                Positioned(
                  left: 200,
                  top: 110,
                  child: Text(
                    schedaPG['classe'] ?? '-',
                    style: _style(),
                  ),
                ),
                // Specie
                Positioned(
                  left: 500,
                  top: 110,
                  child: Text(
                    schedaPG['specie'] ?? '-',
                    style: _style(),
                  ),
                ),
                // Livello
                Positioned(
                  left: 200,
                  top: 135,
                  child: Text(
                    schedaPG['livello'].toString(),
                    style: _style(),
                  ),
                ),
                // Caratteristiche (FOR, DES, COS, INT, SAG, CAR)
                for (var i = 0; i < 6; i++)
                  Positioned(
                    left: 120,
                    top: 230 + i * 70,
                    child: Text(
                      schedaPG['caratteristiche'].entries.elementAt(i).value.toString(),
                      style: _style(fontSize: 18),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _style({double fontSize = 14}) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );
  }
}

