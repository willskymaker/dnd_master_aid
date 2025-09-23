import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// === IMPORTAZIONI ===
import 'pg_base/main_pg_base.dart';          // PG Base Wizard
import 'screens/coming_soon.dart';           // Schermata per funzionalità disattivate
import 'screens/dice_roller.dart';           // Modulo dadi
import 'screens/name_generator.dart';        // Generatore nomi (standalone)
import 'package:dnd_master_aid/factory_pg_base.dart';
import 'providers/character_provider.dart';
import 'widgets/mobile/mobile_scaffold.dart';
import 'widgets/mobile/mobile_card.dart';
import 'pages/database_browser_page.dart';

void main() {
  runApp(const DnDMasterAidApp());
}

class DnDMasterAidApp extends StatelessWidget {
  const DnDMasterAidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CharacterProvider()),
      ],
      child: MaterialApp(
        title: 'DnD MasterAid',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.brown,
          primaryColor: const Color(0xFF8B4513),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF8B4513),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF8B4513),
            foregroundColor: Colors.white,
          ),
          cardTheme: CardThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: const HomePage(),
      ),
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
      'id': 'database',
      'nome': 'Database D&D',
      'icona': '📚',
      'descr': 'Sfoglia tutte le opzioni',
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
    // Determina se siamo su mobile
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return MobileScaffold(
      title: 'D&D Master Aid',
      showBackButton: false,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isMobile ? _buildMobileLayout() : _buildTabletLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return ListView.builder(
      itemCount: funzioni.length,
      itemBuilder: (context, index) {
        final funzione = funzioni[index];
        final attivo = funzione['attivo'] as bool;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: MobileCard(
            onTap: attivo ? () => _navigateTo(context, funzione['id'] as String) : null,
            backgroundColor: attivo ? Colors.white : Colors.grey.shade200,
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: attivo ? const Color(0xFF8B4513).withOpacity(0.1) : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      funzione['icona'] as String,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        funzione['nome'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        funzione['descr'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (attivo)
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF8B4513),
                    size: 16,
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Presto',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabletLayout() {
    return Builder(
      builder: (context) => GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: funzioni.map((funzione) {
          final attivo = funzione['attivo'] as bool;
          return MobileCard(
            onTap: attivo ? () => _navigateTo(context, funzione['id'] as String) : null,
          backgroundColor: attivo ? Colors.white : Colors.grey.shade200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: attivo ? const Color(0xFF8B4513).withOpacity(0.1) : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Center(
                  child: Text(
                    funzione['icona'] as String,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                funzione['nome'] as String,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                funzione['descr'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              if (!attivo) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Presto',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    ),);
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
      case 'database':
        page = const DatabaseBrowserPage(); // 📚 Database D&D
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
