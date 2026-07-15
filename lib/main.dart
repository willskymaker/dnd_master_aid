import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

// === IMPORTAZIONI ===
import 'core/app_theme.dart';
import 'core/logger.dart';
import 'pg_base/main_pg_base.dart'; // PG Base Wizard
import 'screens/coming_soon.dart'; // Schermata per funzionalità disattivate
import 'screens/dice_roller.dart'; // Modulo dadi
import 'screens/name_generator.dart'; // Generatore nomi (standalone)
import 'screens/npc_generator_screen.dart'; // Generatore PNG completo
import 'screens/saved_characters_screen.dart'; // Lista personaggi salvati
import 'screens/combat_tracker_screen.dart'; // Tracker iniziativa/combattimento
import 'screens/settings_screen.dart'; // Impostazioni del Master
import 'screens/side_quest_generator_screen.dart'; // Generatore side quest
import 'factory_pg_base.dart';
import 'providers/character_provider.dart';
import 'providers/saved_characters_provider.dart';
import 'providers/settings_provider.dart';
import 'utils/character_share.dart';
import 'widgets/banner_ad_widget.dart';
import 'widgets/mobile/mobile_scaffold.dart';
import 'widgets/mobile/mobile_card.dart';
import 'pages/database_browser_page.dart';

void main() {
  if (adsSupportedPlatform) {
    WidgetsFlutterBinding.ensureInitialized();
    MobileAds.instance.initialize();
  }
  runApp(const DnDMasterAidApp());
}

class DnDMasterAidApp extends StatefulWidget {
  const DnDMasterAidApp({super.key});

  @override
  State<DnDMasterAidApp> createState() => _DnDMasterAidAppState();
}

class _DnDMasterAidAppState extends State<DnDMasterAidApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<List<SharedMediaFile>>? _intentSub;

  @override
  void initState() {
    super.initState();
    _avviaAscoltoCondivisione();
  }

  /// Ascolta i file .dnd ricevuti da altre app (es. aperti da WhatsApp) e
  /// li importa automaticamente tra "I Miei Personaggi". Il plugin non e'
  /// implementato su web/desktop: qualunque errore viene ignorato in modo
  /// da non bloccare l'avvio dell'app su quelle piattaforme.
  void _avviaAscoltoCondivisione() {
    if (kIsWeb) return;
    try {
      _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
        _gestisciFileCondivisi,
        onError: (e) => AppLogger.error('Errore stream file condivisi', e),
      );
      ReceiveSharingIntent.instance.getInitialMedia().then((value) {
        _gestisciFileCondivisi(value);
        ReceiveSharingIntent.instance.reset();
      });
    } catch (e) {
      AppLogger.error('Ricezione file condivisi non disponibile', e);
    }
  }

  Future<void> _gestisciFileCondivisi(List<SharedMediaFile> files) async {
    if (files.isEmpty) return;
    final file = files.firstWhere(
      (f) => f.path.endsWith(estensioneFileEsportazione),
      orElse: () => files.first,
    );

    final context = _navigatorKey.currentState?.context;
    if (context == null || !context.mounted) return;

    try {
      final pg = await importaPersonaggioDaFile(file.path);
      if (!context.mounted) return;
      await context.read<SavedCharactersProvider>().save(pg);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${pg.nome.isNotEmpty ? pg.nome : "Personaggio"} importato',
          ),
        ),
      );
    } catch (e) {
      AppLogger.error('Import da file condiviso fallito', e);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Il file ricevuto non è una scheda personaggio valida'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _intentSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CharacterProvider()),
        ChangeNotifierProvider(create: (_) => SavedCharactersProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..carica()),
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'Master Aid',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
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
      'attivo': true,
    },
    {
      'id': 'nomi',
      'nome': 'Generatore Nomi',
      'icona': '🧙',
      'descr': 'Crea nomi fantasy',
      'attivo': true,
    },
    {
      'id': 'pgBase',
      'nome': 'Crea PG Base',
      'icona': '🧑‍🎓',
      'descr': 'Generatore guidato di personaggio',
      'attivo': true,
    },
    {
      'id': 'database',
      'nome': 'Database D&D',
      'icona': '📚',
      'descr': 'Sfoglia tutte le opzioni',
      'attivo': true,
    },
    {
      'id': 'salvati',
      'nome': 'I Miei Personaggi',
      'icona': '📖',
      'descr': 'Scheda viva: PF, denaro, condizioni',
      'attivo': true,
    },
    {
      'id': 'combattimento',
      'nome': 'Tracker Combattimento',
      'icona': '⚔️',
      'descr': 'Iniziativa e PF per il Master',
      'attivo': true,
    },
    {
      'id': 'pngGenerator',
      'nome': 'Generatore PNG',
      'icona': '🎭',
      'descr': 'PNG usa e getta per l\'improvvisazione',
      'attivo': true,
    },
    {
      'id': 'sideQuest',
      'nome': 'Generatore Side Quest',
      'icona': '📜',
      'descr': 'Missioni secondarie pronte per l\'improvvisazione',
      'attivo': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Determina se siamo su mobile
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final attive = funzioni.where((f) => f['attivo'] as bool).toList();
    final inArrivo = funzioni.where((f) => !(f['attivo'] as bool)).toList();

    return MobileScaffold(
      title: 'Master Aid',
      showBackButton: false,
      leading: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Image.asset('assets/icon/icon.png'),
        ),
      ),
      actions: [
        IconButton(
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
          icon: const Icon(Icons.settings),
          tooltip: 'Impostazioni',
        ),
      ],
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child:
                  isMobile
                      ? _buildMobileLayout(context, attive, inArrivo)
                      : _buildTabletLayout(context, attive, inArrivo),
            ),
          ),
          const Center(child: BannerAdWidget()),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String label) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    ),
  );

  Widget _buildMobileLayout(
    BuildContext context,
    List<Map<String, Object>> attive,
    List<Map<String, Object>> inArrivo,
  ) {
    return ListView(
      children: [
        _sectionHeader(context, 'Funzioni disponibili'),
        for (final funzione in attive) _buildMobileCard(context, funzione),
        if (inArrivo.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _sectionHeader(context, 'In arrivo'),
          for (final funzione in inArrivo) _buildMobileCard(context, funzione),
        ],
      ],
    );
  }

  Widget _buildMobileCard(BuildContext context, Map<String, Object> funzione) {
    final attivo = funzione['attivo'] as bool;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: MobileCard(
        onTap:
            attivo
                ? () => _navigateTo(context, funzione['id'] as String)
                : null,
        backgroundColor: attivo ? Colors.white : AppColors.disabledBackground,
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color:
                    attivo
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  funzione['icona'] as String,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(funzione['nome'] as String, style: textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    funzione['descr'] as String,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (attivo)
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.primary,
                size: 16,
              )
            else
              _prestoBadge(context),
          ],
        ),
      ),
    );
  }

  Widget _prestoBadge(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
    decoration: BoxDecoration(
      color: AppColors.disabledText,
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
    child: Text('Presto', style: Theme.of(context).textTheme.labelSmall),
  );

  Widget _buildTabletLayout(
    BuildContext context,
    List<Map<String, Object>> attive,
    List<Map<String, Object>> inArrivo,
  ) {
    return ListView(
      children: [
        _sectionHeader(context, 'Funzioni disponibili'),
        _buildTabletGrid(context, attive),
        if (inArrivo.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _sectionHeader(context, 'In arrivo'),
          _buildTabletGrid(context, inArrivo),
        ],
      ],
    );
  }

  Widget _buildTabletGrid(
    BuildContext context,
    List<Map<String, Object>> lista,
  ) {
    final textTheme = Theme.of(context).textTheme;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 1.2,
      crossAxisSpacing: AppSpacing.lg,
      mainAxisSpacing: AppSpacing.lg,
      children:
          lista.map((funzione) {
            final attivo = funzione['attivo'] as bool;
            return MobileCard(
              onTap:
                  attivo
                      ? () => _navigateTo(context, funzione['id'] as String)
                      : null,
              backgroundColor:
                  attivo ? Colors.white : AppColors.disabledBackground,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color:
                          attivo
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        funzione['icona'] as String,
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    funzione['nome'] as String,
                    style: textTheme.titleSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    funzione['descr'] as String,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (!attivo) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _prestoBadge(context),
                  ],
                ],
              ),
            );
          }).toList(),
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
      case 'database':
        page = const DatabaseBrowserPage(); // 📚 Database D&D
        break;
      case 'salvati':
        page = const SavedCharactersScreen();
        break;
      case 'combattimento':
        page = const CombatTrackerScreen();
        break;
      case 'pngGenerator':
        page = const NpcGeneratorScreen();
        break;
      case 'sideQuest':
        page = const SideQuestGeneratorScreen();
        break;
      default:
        page = const ComingSoonScreen(); // 🕒 Placeholder
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}
