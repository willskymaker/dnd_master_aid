import 'package:flutter/material.dart';
import 'screens/pg_base.dart';
import 'screens/coming_soon.dart';
import 'screens/dice_roller.dart';
import 'screens/name_generator.dart';

void main() {
  runApp(DnDMasterAidApp());
}

class DnDMasterAidApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DnD MasterAid',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  final funzioni = [
    {'id': 'dadi', 'nome': 'Tira Dadi', 'icona': '🎲', 'descr': 'Lancia dadi classici', 'attivo': true},
    {'id': 'nomi', 'nome': 'Generatore Nomi', 'icona': '🧙', 'descr': 'Crea nomi fantasy', 'attivo': true},
    {'id': 'pgBase', 'nome': 'Crea PG Base', 'icona': '🧑‍🎓', 'descr': 'Generatore guidato di personaggio', 'attivo': true},
    {'id': 'pgPro', 'nome': 'PG Avanzato', 'icona': '🧠', 'descr': 'Tutte le opzioni avanzate', 'attivo': false},
    {'id': 'mob', 'nome': 'Generatore Mob', 'icona': '👹', 'descr': 'Crea mostri e creature', 'attivo': false},
    {'id': 'npc', 'nome': 'Generatore NPC', 'icona': '🧑‍🌾', 'descr': 'Crea PNG con personalità', 'attivo': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('DnD MasterAid')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 0.9,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: funzioni.map((funzione) {
            final attivo = funzione['attivo'] as bool;
            return GestureDetector(
              onTap: attivo
                  ? () => _navigateTo(context, funzione['id'] as String)
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  color: attivo ? Colors.deepPurple.shade100 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepPurple),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(funzione['icona'] as String, style: TextStyle(fontSize: 36)),
                    SizedBox(height: 12),
                    Text(funzione['nome'] as String, style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(funzione['descr'] as String, textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, String id) {
    Widget page;
    switch (id) {
      case 'pgBase':
        page = PgBaseScreen();
        break;
      case 'dadi':
        page = DiceRollerScreen();
        break;
      case 'nomi':
        page = NameGeneratorScreen();
        break;
      default:
        page = ComingSoonScreen();
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}

