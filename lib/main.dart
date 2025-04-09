import 'package:flutter/material.dart';

// === IMPORTAZIONI ===
import 'pg_base/main_pg_base.dart';          // PG Base Wizard
import 'screens/coming_soon.dart';           // Schermata per funzionalità disattivate
import 'screens/dice_roller.dart';           // Modulo dadi
import 'screens/name_generator.dart';        // Generatore nomi (standalone)
import 'package:dnd_master_aid/factory_pg_base.dart';

void main() {
  runApp(const DnDMasterAidApp());
}

class DnDMasterAidApp extends StatelessWidget {
  const DnDMasterAidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DnD MasterAid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final funzioni = const [
    {
      'id': 'dadi',
      'nome': 'Tira Dadi',
      'icona': '🎲',
      'descr': 'Lancia dadi classici',
      'attivo': true
    },
    {
      'id': 'nomi',
      'nome': 'Generatore Nomi',
      'icona': '🧙',
      'descr': 'Crea nomi fantasy',
      'attivo': true
    },
    {
      'id': 'pgBase',
      'nome': 'Crea PG Base',
      'icona': '🧑‍🎓',
      'descr': 'Generatore guidato di personaggio',
      'attivo': true
    },
    {
      'id': 'pgPro',
      'nome': 'PG Avanzato',
      'icona': '🧠',
      'descr': 'Tutte le opzioni avanzate',
      'attivo': false
    },
    {
      'id': 'mob',
      'nome': 'Generatore Mob',
      'icona': '👹',
      'descr': 'Crea mostri e creature',
      'attivo': false
    },
    {
      'id': 'npc',
      'nome': 'Generatore NPC',
      'icona': '🧑‍🌾',
      'descr': 'Crea PNG con personalità',
      'attivo': false
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DnD MasterAid')),
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
                    Text(funzione['icona'] as String, style: const TextStyle(fontSize: 36)),
                    const SizedBox(height: 12),
                    Text(funzione['nome'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(funzione['descr'] as String, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
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
    late final Widget page;

    switch (id) {
      case 'pgBase':
        page = const PGBaseWizard(); // ✅ Usa il nuovo flusso guidato
        break;
      case 'dadi':
        page = const DiceRollerScreen(); // 🎲 Modulo dadi
        break;
      case 'nomi':
       page = NameGeneratorScreen(factory: PGBaseFactory());

        break;
      default:
        page = const ComingSoonScreen(); // 🕒 Placeholder
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
