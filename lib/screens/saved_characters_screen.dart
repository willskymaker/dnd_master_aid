import 'dart:math';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../data/db_condizioni.dart';
import '../data/db_slot_incantesimi.dart';
import '../data/db_talenti.dart';
import '../factory_pg_base.dart';
import '../pg_base/utils/asi_helper.dart';
import '../pg_base/utils/pf_helper.dart';
import '../providers/saved_characters_provider.dart';
import '../utils/character_share.dart';
import '../widgets/mobile/mobile_scaffold.dart';
import 'spell_cards_screen.dart';

class SavedCharactersScreen extends StatefulWidget {
  const SavedCharactersScreen({super.key});

  @override
  State<SavedCharactersScreen> createState() => _SavedCharactersScreenState();
}

class _SavedCharactersScreenState extends State<SavedCharactersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavedCharactersProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MobileScaffold(
      title: 'I Miei Personaggi',
      actions: [
        IconButton(
          onPressed: () => _mostraImportaScheda(context),
          icon: const Icon(Icons.file_download_outlined),
          tooltip: 'Importa scheda',
        ),
      ],
      body: Consumer<SavedCharactersProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text(provider.errorMessage!),
                  TextButton(
                    onPressed: provider.loadAll,
                    child: const Text('Riprova'),
                  ),
                ],
              ),
            );
          }

          if (provider.characters.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🧝', style: TextStyle(fontSize: 64)),
                  SizedBox(height: 16),
                  Text(
                    'Nessun personaggio salvato',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Crea un PG Base e salvalo al termine',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.characters.length,
            itemBuilder: (context, index) {
              final pg = provider.characters[index];
              return _CharacterCard(
                pg: pg,
                onDelete: () => _confermaEliminazione(context, provider, pg),
                onTap: () => _apriScheda(context, pg),
              );
            },
          );
        },
      ),
    );
  }

  void _mostraImportaScheda(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _ImportaSchedaSheet(),
    );
  }

  void _apriScheda(BuildContext context, PGBase pg) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SchedaBottomSheet(pg: pg),
    );
  }

  void _confermaEliminazione(
    BuildContext context,
    SavedCharactersProvider provider,
    PGBase pg,
  ) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Elimina personaggio'),
            content: Text('Sei sicuro di voler eliminare ${pg.nome}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annulla'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await provider.delete(pg.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${pg.nome} eliminato')),
                      );
                    }
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Errore durante l\'eliminazione'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Elimina'),
              ),
            ],
          ),
    );
  }
}

/// Incolla il codice ricevuto (es. da WhatsApp) e importa il personaggio
/// tra "I Miei Personaggi". Vedi lib/utils/character_share.dart per il
/// formato del codice.
class _ImportaSchedaSheet extends StatefulWidget {
  const _ImportaSchedaSheet();

  @override
  State<_ImportaSchedaSheet> createState() => _ImportaSchedaSheetState();
}

class _ImportaSchedaSheetState extends State<_ImportaSchedaSheet> {
  final _controller = TextEditingController();
  String? _errore;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _importa() async {
    setState(() => _errore = null);
    try {
      final pg = importaPersonaggio(_controller.text);
      await context.read<SavedCharactersProvider>().save(pg);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${pg.nome.isNotEmpty ? pg.nome : "Personaggio"} importato',
          ),
        ),
      );
    } on FormatException catch (e) {
      setState(() => _errore = e.message);
    } catch (_) {
      setState(() => _errore = 'Codice non valido.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Importa scheda',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Incolla qui il codice ricevuto dal giocatore (es. via WhatsApp).',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'DNDMA1:...',
              border: const OutlineInputBorder(),
              errorText: _errore,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _importa,
              icon: const Icon(Icons.check),
              label: const Text('Importa'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  final PGBase pg;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _CharacterCard({
    required this.pg,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(pg.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF8B4513).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                _classeEmoji(pg.classe),
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          title: Text(
            pg.nome.isNotEmpty ? pg.nome : 'Senza nome',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${pg.classe} ${pg.specie.isNotEmpty ? "· ${pg.specie}" : ""} · Livello ${pg.livello}',
              ),
              const SizedBox(height: 2),
              Text(
                'PF: ${pg.puntiVitaCorrenti}/${pg.puntiVita}  •  Velocità: ${pg.velocita}m',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right, color: Color(0xFF8B4513)),
          onTap: onTap,
        ),
      ),
    );
  }

  String _classeEmoji(String classe) {
    switch (classe.toLowerCase()) {
      case 'barbaro':
        return '⚔️';
      case 'bardo':
        return '🎵';
      case 'chierico':
        return '✝️';
      case 'druido':
        return '🌿';
      case 'guerriero':
        return '🛡️';
      case 'ladro':
        return '🗡️';
      case 'mago':
        return '🔮';
      case 'monaco':
        return '👊';
      case 'paladino':
        return '⚜️';
      case 'ranger':
        return '🏹';
      case 'stregone':
        return '✨';
      case 'warlock':
        return '👁️';
      default:
        return '🧙';
    }
  }
}

class _SchedaBottomSheet extends StatefulWidget {
  final PGBase pg;

  const _SchedaBottomSheet({required this.pg});

  @override
  State<_SchedaBottomSheet> createState() => _SchedaBottomSheetState();
}

class _SchedaBottomSheetState extends State<_SchedaBottomSheet> {
  late PGBase _pg;

  @override
  void initState() {
    super.initState();
    _pg = widget.pg;
  }

  @override
  Widget build(BuildContext context) {
    final pg = _pg;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder:
          (_, controller) => Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              controller: controller,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        pg.nome.isNotEmpty ? pg.nome : 'Personaggio',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _condividi,
                      icon: const Icon(Icons.share),
                      tooltip: 'Condividi personaggio',
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${pg.classe} · ${pg.specie} · Livello ${pg.livello}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ),
                    if (pg.livello > 1)
                      IconButton(
                        onPressed: _scendiDiLivello,
                        icon: const Icon(Icons.arrow_downward, size: 18),
                        tooltip: 'Scendi di livello',
                      ),
                    if (pg.livello < 20)
                      IconButton(
                        onPressed: _saliDiLivello,
                        icon: const Icon(Icons.arrow_upward, size: 18),
                        tooltip: 'Sali di livello',
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                _ProprietarioSection(pg: pg),
                const Divider(height: 24),
                _PfSection(pg: pg),
                const SizedBox(height: 8),
                _riga('Dado Vita', 'd${pg.dadoVita}'),
                _riga('Velocità', '${pg.velocita} m'),
                if (pg.background.isNotEmpty)
                  _riga('Background', pg.background),
                if (pg.allineamento.isNotEmpty)
                  _riga('Allineamento', pg.allineamento),
                if (pg.linguaggi.isNotEmpty)
                  _riga('Linguaggi', pg.linguaggi.join(', ')),
                const Divider(height: 24),
                const Text(
                  'Denaro',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _DenaroSection(pg: pg),
                const Divider(height: 24),
                const Text(
                  'Inventario',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _InventarioSection(pg: pg),
                const Divider(height: 24),
                const Text(
                  'Condizioni',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tocco lungo su una condizione per vederne l\'effetto',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                _CondizioniSection(pg: pg),
                const Divider(height: 24),
                const Text(
                  'Bonus/Malus temporanei',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _ModificatoriSection(pg: pg),
                if (slotIncantesimiList.any((s) => s.classe == pg.classe)) ...[
                  const Divider(height: 24),
                  const Text(
                    'Slot Incantesimo',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _IncantesimiSection(pg: pg),
                ],
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Caratteristiche',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      onPressed: _correggiCaratteristiche,
                      icon: const Icon(Icons.edit, size: 18),
                      tooltip: 'Correggi caratteristiche',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _grigliaCaratteristiche(),
                if (pg.abilitaClasse.isNotEmpty) ...[
                  const Divider(height: 24),
                  _riga('Abilità', pg.abilitaClasse.join(', ')),
                ],
                if (pg.competenze.isNotEmpty)
                  _riga('Competenze', pg.competenze.join(', ')),
                if (pg.capacitaSpeciali.isNotEmpty)
                  _riga('Abilità Innate', pg.capacitaSpeciali.join(', ')),
                if (pg.talenti.isNotEmpty)
                  _riga('Talenti', pg.talenti.join(', ')),
                if (pg.equipaggiamento.isNotEmpty) ...[
                  const Divider(height: 24),
                  const Text(
                    'Equipaggiamento',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ...pg.equipaggiamento.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $e'),
                    ),
                  ),
                ],
                const Divider(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _eliminaPersonaggio(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Elimina personaggio'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  Future<void> _eliminaPersonaggio(BuildContext context) async {
    final confermato = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Elimina personaggio'),
            content: Text(
              'Sei sicuro di voler eliminare ${_pg.nome.isNotEmpty ? _pg.nome : "questo personaggio"}? '
              'L\'operazione non è reversibile.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annulla'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Elimina'),
              ),
            ],
          ),
    );
    if (confermato != true) return;
    if (!context.mounted) return;

    final nome = _pg.nome;
    await context.read<SavedCharactersProvider>().delete(_pg.id);
    if (!context.mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${nome.isNotEmpty ? nome : "Personaggio"} eliminato'),
      ),
    );
  }

  /// Condivide il personaggio tramite il pannello di condivisione nativo
  /// del sistema operativo (WhatsApp, email, ecc.). Su web condivide solo
  /// il codice testuale (niente concetto di file "apri con" nel browser);
  /// su piattaforme native condivide un file .dnd, cosi' che un tap su di
  /// esso, una volta ricevuto, apra direttamente l'app (vedi il filtro in
  /// AndroidManifest.xml).
  Future<void> _condividi() async {
    final nome = _pg.nome.isNotEmpty ? _pg.nome : 'Senza nome';
    if (kIsWeb) {
      await SharePlus.instance.share(
        ShareParams(
          text: esportaPersonaggio(_pg),
          subject: 'Personaggio D&D: $nome',
        ),
      );
      return;
    }
    final file = await creaFileEsportazione(_pg);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: 'Personaggio D&D: $nome'),
    );
  }

  Future<void> _saliDiLivello() async {
    if (_pg.livello >= 20) return;
    final nuovoLivello = _pg.livello + 1;
    final asiPrima = calcolaASI(livello: _pg.livello, classe: _pg.classe);
    final asiDopo = calcolaASI(livello: nuovoLivello, classe: _pg.classe);

    var nuoveCaratteristiche = _pg.caratteristiche;
    var nuoviModificatori = _pg.modificatori;
    var nuoviTalenti = _pg.talenti;

    if (asiDopo > asiPrima) {
      final distribuzione = await _mostraDistribuzioneAsi();
      if (!mounted) return;
      if (distribuzione == null) return; // annullato dall'utente
      if (distribuzione.isNotEmpty) {
        nuoveCaratteristiche = {
          for (final e in _pg.caratteristiche.entries)
            e.key: e.value + (distribuzione[e.key] ?? 0),
        };
        nuoviModificatori = {
          for (final e in nuoveCaratteristiche.entries)
            e.key: ((e.value - 10) / 2).floor(),
        };
      } else {
        final talento = await _mostraSceltaTalento(nuovoLivello);
        if (!mounted) return;
        if (talento != null && talento.isNotEmpty) {
          nuoviTalenti = [..._pg.talenti, talento];
        }
      }
    }

    final modCos = nuoviModificatori['COS'] ?? 0;
    final nuovoPfMax = calcolaPuntiFerita(
      livello: nuovoLivello,
      dadoVita: _pg.dadoVita,
      modCostituzione: modCos,
    );
    final deltaPf = nuovoPfMax - _pg.puntiVita;

    final nuovoPg = _pg.copyWith(
      livello: nuovoLivello,
      puntiVita: nuovoPfMax,
      puntiVitaCorrenti: (_pg.puntiVitaCorrenti + deltaPf).clamp(0, nuovoPfMax),
      caratteristiche: nuoveCaratteristiche,
      modificatori: nuoviModificatori,
      talenti: nuoviTalenti,
    );

    await context.read<SavedCharactersProvider>().save(nuovoPg);
    if (!mounted) return;
    setState(() => _pg = nuovoPg);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Livello $nuovoLivello raggiunto!')));
  }

  /// Scende di un livello (per correggere un errore, es. un "Sali di
  /// livello" premuto per sbaglio). Ricalcola i PF massimi come per la
  /// salita. Se il livello lasciato prevedeva un ASI, chiede conferma e
  /// offre di rimuovere l'ultimo talento preso (le caratteristiche, se
  /// invece era stato scelto un aumento, vanno corrette a mano dalla
  /// griglia caratteristiche).
  /// Correzione manuale libera delle caratteristiche, senza vincoli di
  /// budget: utile per rimediare a un ASI assegnato per errore o a
  /// qualunque altra svista, dato che non teniamo uno storico di quali
  /// punti sono stati assegnati a quale livello.
  Future<void> _correggiCaratteristiche() async {
    final stats = ['FOR', 'DES', 'COS', 'INT', 'SAG', 'CAR'];
    final valori = Map<String, int>.from(_pg.caratteristiche);

    final confermato = await showDialog<bool>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('Correggi caratteristiche'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final s in stats)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              SizedBox(width: 48, child: Text(s)),
                              IconButton(
                                onPressed:
                                    (valori[s] ?? 10) > 3
                                        ? () => setDialogState(
                                          () => valori[s] = valori[s]! - 1,
                                        )
                                        : null,
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              SizedBox(
                                width: 32,
                                child: Text(
                                  '${valori[s] ?? 10}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed:
                                    (valori[s] ?? 10) < 20
                                        ? () => setDialogState(
                                          () => valori[s] = valori[s]! + 1,
                                        )
                                        : null,
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annulla'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Salva'),
                    ),
                  ],
                ),
          ),
    );
    if (confermato != true) return;
    if (!mounted) return;

    final nuoviModificatori = {
      for (final e in valori.entries) e.key: ((e.value - 10) / 2).floor(),
    };
    final nuovoPg = _pg.copyWith(
      caratteristiche: valori,
      modificatori: nuoviModificatori,
    );
    await context.read<SavedCharactersProvider>().save(nuovoPg);
    if (!mounted) return;
    setState(() => _pg = nuovoPg);
  }

  Future<void> _scendiDiLivello() async {
    if (_pg.livello <= 1) return;
    final nuovoLivello = _pg.livello - 1;
    final asiAttuale = calcolaASI(livello: _pg.livello, classe: _pg.classe);
    final asiNuovo = calcolaASI(livello: nuovoLivello, classe: _pg.classe);

    final confermato = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Scendi di livello'),
            content: Text(
              'Sei sicuro di voler tornare al livello $nuovoLivello? '
              'I PF massimi verranno ricalcolati.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annulla'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Conferma'),
              ),
            ],
          ),
    );
    if (confermato != true) return;
    if (!mounted) return;

    var nuoviTalenti = _pg.talenti;
    if (asiAttuale > asiNuovo && _pg.talenti.isNotEmpty) {
      final rimuovi = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Rimuovere anche il talento?'),
              content: Text(
                'Il livello ${_pg.livello} prevedeva un Aumento delle '
                'Caratteristiche o un talento. Vuoi rimuovere l\'ultimo '
                'talento preso ("${_pg.talenti.last}")? Se invece a quel '
                'livello avevi aumentato le caratteristiche, correggile a '
                'mano dalla griglia più sotto.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('No, lascialo'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Sì, rimuovilo'),
                ),
              ],
            ),
      );
      if (rimuovi == true) {
        nuoviTalenti = _pg.talenti.sublist(0, _pg.talenti.length - 1);
      }
    }

    if (!mounted) return;
    final modCos = _pg.modificatori['COS'] ?? 0;
    final nuovoPfMax = calcolaPuntiFerita(
      livello: nuovoLivello,
      dadoVita: _pg.dadoVita,
      modCostituzione: modCos,
    );
    final deltaPf = nuovoPfMax - _pg.puntiVita;

    final nuovoPg = _pg.copyWith(
      livello: nuovoLivello,
      puntiVita: nuovoPfMax,
      puntiVitaCorrenti: (_pg.puntiVitaCorrenti + deltaPf).clamp(0, nuovoPfMax),
      talenti: nuoviTalenti,
    );

    await context.read<SavedCharactersProvider>().save(nuovoPg);
    if (!mounted) return;
    setState(() => _pg = nuovoPg);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Sceso al livello $nuovoLivello')));
  }

  /// Mostra il dialog per distribuire i 2 punti dell'Aumento del Punteggio
  /// di Caratteristica. Ritorna null se l'utente annulla il level up,
  /// una mappa vuota se ha scelto un talento al posto dell'ASI, altrimenti
  /// la mappa dei punti assegnati per caratteristica.
  Future<Map<String, int>?> _mostraDistribuzioneAsi() {
    final stats = ['FOR', 'DES', 'COS', 'INT', 'SAG', 'CAR'];
    final assegnati = {for (final s in stats) s: 0};
    var puntiRimanenti = 2;

    return showDialog<Map<String, int>>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('Aumento Punteggio di Caratteristica'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hai $puntiRimanenti punti da distribuire (max +2 su '
                        'una caratteristica, fino a 20).',
                      ),
                      const SizedBox(height: 12),
                      for (final s in stats)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              SizedBox(width: 48, child: Text(s)),
                              SizedBox(
                                width: 32,
                                child: Text(
                                  '${(_pg.caratteristiche[s] ?? 10) + assegnati[s]!}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed:
                                    assegnati[s]! > 0
                                        ? () => setDialogState(() {
                                          assegnati[s] = assegnati[s]! - 1;
                                          puntiRimanenti++;
                                        })
                                        : null,
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              IconButton(
                                onPressed:
                                    (puntiRimanenti > 0 &&
                                            (_pg.caratteristiche[s] ?? 10) +
                                                    assegnati[s]! <
                                                20)
                                        ? () => setDialogState(() {
                                          assegnati[s] = assegnati[s]! + 1;
                                          puntiRimanenti--;
                                        })
                                        : null,
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, null),
                      child: const Text('Annulla'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, <String, int>{}),
                      child: const Text('Ho preso un talento'),
                    ),
                    FilledButton(
                      onPressed:
                          puntiRimanenti == 0
                              ? () => Navigator.pop(context, assegnati)
                              : null,
                      child: const Text('Conferma'),
                    ),
                  ],
                ),
          ),
    );
  }

  /// Mostra la scelta del talento preso al posto dell'ASI: selezionabile
  /// dall'elenco (filtrato per livello minimo) o scrivibile a mano per i
  /// talenti homebrew non presenti in db_talenti.dart. Ritorna null se
  /// l'utente chiude il foglio senza scegliere nulla.
  Future<String?> _mostraSceltaTalento(int nuovoLivello) {
    final disponibili =
        talentiList.where((t) => t.livelloMinimo <= nuovoLivello).toList()
          ..sort((a, b) => a.nome.compareTo(b.nome));
    final controller = TextEditingController();

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.4,
            expand: false,
            builder:
                (_, scrollController) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quale talento hai preso?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          labelText: 'Nome del talento (se non in elenco)',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (v) => Navigator.pop(context, v.trim()),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final testo = controller.text.trim();
                            if (testo.isNotEmpty) {
                              Navigator.pop(context, testo);
                            }
                          },
                          child: const Text('Usa questo nome'),
                        ),
                      ),
                      const Divider(height: 24),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: disponibili.length,
                          itemBuilder: (context, index) {
                            final t = disponibili[index];
                            return ListTile(
                              title: Text(t.nome),
                              subtitle: Text(
                                t.descrizione,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => Navigator.pop(context, t.nome),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _riga(String label, String valore) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Text(valore)),
      ],
    ),
  );

  Widget _grigliaCaratteristiche() {
    final stats = ['FOR', 'DES', 'COS', 'INT', 'SAG', 'CAR'];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children:
          stats.map((s) {
            final val = _pg.caratteristiche[s] ?? 0;
            final mod = _pg.modificatori[s] ?? 0;
            final segno = mod >= 0 ? '+' : '';
            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF8B4513).withValues(alpha: 0.4),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    s,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B4513),
                    ),
                  ),
                  Text(
                    '$val',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('$segno$mod', style: const TextStyle(fontSize: 13)),
                ],
              ),
            );
          }).toList(),
    );
  }
}

/// Campo libero per annotare a chi appartiene il personaggio: utile per il
/// Master quando importa le schede di piu' giocatori e deve distinguerle
/// a colpo d'occhio.
class _ProprietarioSection extends StatefulWidget {
  final PGBase pg;

  const _ProprietarioSection({required this.pg});

  @override
  State<_ProprietarioSection> createState() => _ProprietarioSectionState();
}

class _ProprietarioSectionState extends State<_ProprietarioSection> {
  late PGBase _pg;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _pg = widget.pg;
    _controller = TextEditingController(text: _pg.proprietario);
  }

  @override
  void didUpdateWidget(covariant _ProprietarioSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.pg, widget.pg)) {
      _pg = widget.pg;
      _controller.text = _pg.proprietario;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _salva() {
    final valore = _controller.text.trim();
    if (valore == _pg.proprietario) return;
    _pg = _pg.copyWith(proprietario: valore);
    context.read<SavedCharactersProvider>().save(_pg);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Di chi è questo personaggio',
              hintText: 'Es. Marco',
              isDense: true,
            ),
            onSubmitted: (_) => _salva(),
          ),
        ),
        IconButton(
          onPressed: _salva,
          icon: const Icon(Icons.check, size: 20),
          tooltip: 'Salva',
        ),
      ],
    );
  }
}

/// Tracker del denaro (rame/argento/oro/platino) di un personaggio salvato.
/// Ogni modifica viene persistita subito tramite [SavedCharactersProvider].
class _DenaroSection extends StatefulWidget {
  final PGBase pg;

  const _DenaroSection({required this.pg});

  @override
  State<_DenaroSection> createState() => _DenaroSectionState();
}

class _DenaroSectionState extends State<_DenaroSection> {
  late PGBase _pg;

  @override
  void initState() {
    super.initState();
    _pg = widget.pg;
  }

  @override
  void didUpdateWidget(covariant _DenaroSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.pg, widget.pg)) {
      setState(() => _pg = widget.pg);
    }
  }

  void _aggiorna(String moneta, int delta) {
    setState(() {
      switch (moneta) {
        case 'rame':
          _pg = _pg.copyWith(
            denaroRame: (_pg.denaroRame + delta).clamp(0, 1 << 30),
          );
          break;
        case 'argento':
          _pg = _pg.copyWith(
            denaroArgento: (_pg.denaroArgento + delta).clamp(0, 1 << 30),
          );
          break;
        case 'oro':
          _pg = _pg.copyWith(
            denaroOro: (_pg.denaroOro + delta).clamp(0, 1 << 30),
          );
          break;
        case 'platino':
          _pg = _pg.copyWith(
            denaroPlatino: (_pg.denaroPlatino + delta).clamp(0, 1 << 30),
          );
          break;
      }
    });
    context.read<SavedCharactersProvider>().save(_pg);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _contatore('Monete di rame (mr)', _pg.denaroRame, 'rame'),
        _contatore('Monete di argento (ma)', _pg.denaroArgento, 'argento'),
        _contatore('Monete d\'oro (mo)', _pg.denaroOro, 'oro'),
        _contatore('Monete di platino (mp)', _pg.denaroPlatino, 'platino'),
      ],
    );
  }

  Widget _contatore(String label, int valore, String moneta) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          IconButton(
            onPressed: valore > 0 ? () => _aggiorna(moneta, -1) : null,
            icon: const Icon(Icons.remove_circle_outline),
            color: const Color(0xFF8B4513),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '$valore',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          IconButton(
            onPressed: () => _aggiorna(moneta, 1),
            icon: const Icon(Icons.add_circle_outline),
            color: const Color(0xFF8B4513),
          ),
        ],
      ),
    );
  }
}

/// Tracker dei Punti Ferita (correnti/massimi/temporanei) di un personaggio
/// salvato. I danni consumano prima i PF temporanei, poi quelli correnti.
class _PfSection extends StatefulWidget {
  final PGBase pg;

  const _PfSection({required this.pg});

  @override
  State<_PfSection> createState() => _PfSectionState();
}

class _PfSectionState extends State<_PfSection> {
  late PGBase _pg;

  @override
  void initState() {
    super.initState();
    _pg = widget.pg;
  }

  @override
  void didUpdateWidget(covariant _PfSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.pg, widget.pg)) {
      setState(() => _pg = widget.pg);
    }
  }

  void _salva() => context.read<SavedCharactersProvider>().save(_pg);

  void _applicaDelta(int delta) {
    var corrente = _pg.puntiVitaCorrenti;
    var temp = _pg.puntiVitaTemporanei;

    if (delta < 0) {
      var danno = -delta;
      final assorbito = min(danno, temp);
      temp -= assorbito;
      danno -= assorbito;
      corrente = (corrente - danno).clamp(0, _pg.puntiVita);
    } else {
      corrente = (corrente + delta).clamp(0, _pg.puntiVita);
    }

    setState(() {
      _pg = _pg.copyWith(
        puntiVitaCorrenti: corrente,
        puntiVitaTemporanei: temp,
      );
    });
    _salva();
  }

  void _modificaTemp(int delta) {
    setState(() {
      _pg = _pg.copyWith(
        puntiVitaTemporanei: (_pg.puntiVitaTemporanei + delta).clamp(
          0,
          1 << 30,
        ),
      );
    });
    _salva();
  }

  @override
  Widget build(BuildContext context) {
    final max = _pg.puntiVita;
    final corrente = _pg.puntiVitaCorrenti;
    final temp = _pg.puntiVitaTemporanei;
    final ratio = max > 0 ? corrente / max : 0.0;
    final colore =
        corrente == 0
            ? Colors.red.shade900
            : ratio <= 0.25
            ? Colors.red
            : ratio <= 0.5
            ? Colors.orange
            : Colors.green.shade700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Punti Ferita',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$corrente / $max PF${temp > 0 ? ' (+$temp temp)' : ''}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: colore,
              ),
            ),
            if (corrente == 0)
              const Text(
                'MORENTE',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: max > 0 ? ratio.clamp(0, 1) : 0,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(colore),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _pfBtn('-5', () => _applicaDelta(-5), Colors.red),
            _pfBtn('-1', () => _applicaDelta(-1), Colors.red),
            _pfBtn('+1', () => _applicaDelta(1), Colors.green.shade700),
            _pfBtn('+5', () => _applicaDelta(5), Colors.green.shade700),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Expanded(child: Text('PF temporanei')),
            IconButton(
              onPressed: temp > 0 ? () => _modificaTemp(-1) : null,
              icon: const Icon(Icons.remove_circle_outline),
              color: const Color(0xFF8B4513),
            ),
            SizedBox(
              width: 32,
              child: Text(
                '$temp',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              onPressed: () => _modificaTemp(1),
              icon: const Icon(Icons.add_circle_outline),
              color: const Color(0xFF8B4513),
            ),
          ],
        ),
      ],
    );
  }

  Widget _pfBtn(String label, VoidCallback onTap, Color color) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    ),
  );
}

/// Inventario libero (oggetti/pozioni) di un personaggio salvato. "Usa" su
/// una pozione di cura tira 2d4+2 e applica la cura direttamente ai PF.
class _InventarioSection extends StatefulWidget {
  final PGBase pg;

  const _InventarioSection({required this.pg});

  @override
  State<_InventarioSection> createState() => _InventarioSectionState();
}

class _InventarioSectionState extends State<_InventarioSection> {
  late PGBase _pg;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pg = widget.pg;
  }

  @override
  void didUpdateWidget(covariant _InventarioSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.pg, widget.pg)) {
      setState(() => _pg = widget.pg);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _salva() => context.read<SavedCharactersProvider>().save(_pg);

  void _aggiungiOggetto() {
    final nome = _controller.text.trim();
    if (nome.isEmpty) return;

    final nuovo = List<InventoryItem>.from(_pg.inventario);
    final idx = nuovo.indexWhere(
      (i) => i.nome.toLowerCase() == nome.toLowerCase(),
    );
    if (idx >= 0) {
      nuovo[idx] = nuovo[idx].copyWith(quantita: nuovo[idx].quantita + 1);
    } else {
      nuovo.add(InventoryItem(nome: nome));
    }

    setState(() {
      _pg = _pg.copyWith(inventario: nuovo);
      _controller.clear();
    });
    _salva();
  }

  void _rimuoviUno(InventoryItem item) {
    final nuovo = List<InventoryItem>.from(_pg.inventario);
    final idx = nuovo.indexOf(item);
    if (idx < 0) return;

    if (item.quantita > 1) {
      nuovo[idx] = item.copyWith(quantita: item.quantita - 1);
    } else {
      nuovo.removeAt(idx);
    }

    setState(() => _pg = _pg.copyWith(inventario: nuovo));
    _salva();
  }

  bool _ePozioneDiCura(String nome) {
    final n = nome.toLowerCase();
    return n.contains('cura') || n.contains('guarigion');
  }

  void _usa(InventoryItem item) {
    if (_ePozioneDiCura(item.nome)) {
      final random = Random();
      final cura = random.nextInt(4) + 1 + random.nextInt(4) + 1 + 2; // 2d4+2
      final nuoviPf = (_pg.puntiVitaCorrenti + cura).clamp(0, _pg.puntiVita);
      setState(() => _pg = _pg.copyWith(puntiVitaCorrenti: nuoviPf));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${item.nome}: curati $cura PF')));
    }
    _rimuoviUno(item);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_pg.inventario.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Nessun oggetto',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ..._pg.inventario.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Expanded(child: Text('${item.nome} ×${item.quantita}')),
                TextButton(
                  onPressed: () => _usa(item),
                  child: const Text('Usa'),
                ),
                IconButton(
                  onPressed: () => _rimuoviUno(item),
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Aggiungi oggetto...',
                  isDense: true,
                ),
                onSubmitted: (_) => _aggiungiOggetto(),
              ),
            ),
            IconButton(
              onPressed: _aggiungiOggetto,
              icon: const Icon(Icons.add_circle),
              color: const Color(0xFF8B4513),
            ),
          ],
        ),
      ],
    );
  }
}

/// Toggle delle condizioni di stato attive su un personaggio salvato.
class _CondizioniSection extends StatefulWidget {
  final PGBase pg;

  const _CondizioniSection({required this.pg});

  @override
  State<_CondizioniSection> createState() => _CondizioniSectionState();
}

class _CondizioniSectionState extends State<_CondizioniSection> {
  late PGBase _pg;

  @override
  void initState() {
    super.initState();
    _pg = widget.pg;
  }

  @override
  void didUpdateWidget(covariant _CondizioniSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.pg, widget.pg)) {
      setState(() => _pg = widget.pg);
    }
  }

  void _toggle(String condizione, bool attiva) {
    final nuove = List<String>.from(_pg.condizioniAttive);
    if (attiva) {
      if (!nuove.contains(condizione)) nuove.add(condizione);
    } else {
      nuove.remove(condizione);
    }
    setState(() => _pg = _pg.copyWith(condizioniAttive: nuove));
    context.read<SavedCharactersProvider>().save(_pg);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          condizioniD20.entries.map((entry) {
            final attiva = _pg.condizioniAttive.contains(entry.key);
            return Tooltip(
              message: entry.value,
              triggerMode: TooltipTriggerMode.longPress,
              child: FilterChip(
                label: Text(entry.key),
                selected: attiva,
                onSelected: (val) => _toggle(entry.key, val),
                selectedColor: const Color(0xFF8B4513).withValues(alpha: 0.2),
                checkmarkColor: const Color(0xFF8B4513),
              ),
            );
          }).toList(),
    );
  }
}

/// Note libere per bonus/malus temporanei e vantaggio/svantaggio attivi
/// (es. "+2 attacco fino a fine turno", "svantaggio TS Destrezza 3 round").
class _ModificatoriSection extends StatefulWidget {
  final PGBase pg;

  const _ModificatoriSection({required this.pg});

  @override
  State<_ModificatoriSection> createState() => _ModificatoriSectionState();
}

class _ModificatoriSectionState extends State<_ModificatoriSection> {
  late PGBase _pg;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pg = widget.pg;
  }

  @override
  void didUpdateWidget(covariant _ModificatoriSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.pg, widget.pg)) {
      setState(() => _pg = widget.pg);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _salva() => context.read<SavedCharactersProvider>().save(_pg);

  void _aggiungi() {
    final testo = _controller.text.trim();
    if (testo.isEmpty) return;

    setState(() {
      _pg = _pg.copyWith(
        modificatoriAttivi: [..._pg.modificatoriAttivi, testo],
      );
      _controller.clear();
    });
    _salva();
  }

  void _rimuovi(int index) {
    final nuovi = List<String>.from(_pg.modificatoriAttivi)..removeAt(index);
    setState(() => _pg = _pg.copyWith(modificatoriAttivi: nuovi));
    _salva();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_pg.modificatoriAttivi.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Nessun modificatore attivo',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ..._pg.modificatoriAttivi.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Expanded(child: Text(entry.value)),
                IconButton(
                  onPressed: () => _rimuovi(entry.key),
                  icon: const Icon(Icons.close, size: 20),
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Es. +2 attacco fino a fine turno',
                  isDense: true,
                ),
                onSubmitted: (_) => _aggiungi(),
              ),
            ),
            IconButton(
              onPressed: _aggiungi,
              icon: const Icon(Icons.add_circle),
              color: const Color(0xFF8B4513),
            ),
          ],
        ),
      ],
    );
  }
}

/// Tracker degli slot incantesimo disponibili/usati per livello, in base a
/// classe e livello del personaggio (tabella in db_slot_incantesimi.dart).
class _IncantesimiSection extends StatefulWidget {
  final PGBase pg;

  const _IncantesimiSection({required this.pg});

  @override
  State<_IncantesimiSection> createState() => _IncantesimiSectionState();
}

class _IncantesimiSectionState extends State<_IncantesimiSection> {
  late PGBase _pg;

  @override
  void initState() {
    super.initState();
    _pg = widget.pg;
  }

  @override
  void didUpdateWidget(covariant _IncantesimiSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.pg, widget.pg)) {
      setState(() => _pg = widget.pg);
    }
  }

  void _salva() => context.read<SavedCharactersProvider>().save(_pg);

  List<int> get _slotTotaliPerLivello {
    SlotIncantesimi? tabella;
    for (final s in slotIncantesimiList) {
      if (s.classe == _pg.classe) {
        tabella = s;
        break;
      }
    }
    return tabella?.slotPerLivello[_pg.livello] ?? const [];
  }

  int _usati(int livelloIncantesimo) =>
      _pg.slotIncantesimoUsati['$livelloIncantesimo'] ?? 0;

  void _aggiorna(int livelloIncantesimo, int nuovoValore) {
    final nuovaMappa = Map<String, int>.from(_pg.slotIncantesimoUsati);
    nuovaMappa['$livelloIncantesimo'] = nuovoValore;
    setState(() => _pg = _pg.copyWith(slotIncantesimoUsati: nuovaMappa));
    _salva();
  }

  void _usaSlot(int livelloIncantesimo, int totale) {
    final usatiCorrenti = _usati(livelloIncantesimo);
    if (usatiCorrenti >= totale) return;
    _aggiorna(livelloIncantesimo, usatiCorrenti + 1);
  }

  void _recuperaSlot(int livelloIncantesimo) {
    final usatiCorrenti = _usati(livelloIncantesimo);
    if (usatiCorrenti <= 0) return;
    _aggiorna(livelloIncantesimo, usatiCorrenti - 1);
  }

  void _riposoLungo() {
    setState(() => _pg = _pg.copyWith(slotIncantesimoUsati: {}));
    _salva();
  }

  @override
  Widget build(BuildContext context) {
    final slotTotali = _slotTotaliPerLivello;
    if (slotTotali.isEmpty || slotTotali.every((n) => n == 0)) {
      return Text(
        'Nessuno slot incantesimo a questo livello.',
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < slotTotali.length; i++)
          if (slotTotali[i] > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  SizedBox(width: 90, child: Text('Livello ${i + 1}')),
                  IconButton(
                    onPressed: () => _recuperaSlot(i + 1),
                    icon: const Icon(Icons.add_circle_outline),
                    color: Colors.green.shade700,
                    tooltip: 'Recupera slot',
                  ),
                  SizedBox(
                    width: 56,
                    child: Text(
                      '${slotTotali[i] - _usati(i + 1)} / ${slotTotali[i]}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _usaSlot(i + 1, slotTotali[i]),
                    icon: const Icon(Icons.remove_circle_outline),
                    color: Colors.red,
                    tooltip: 'Usa slot',
                  ),
                ],
              ),
            ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _riposoLungo,
            icon: const Icon(Icons.bedtime),
            label: const Text('Riposo Lungo'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SpellCardsScreen()),
              );
            },
            icon: const Icon(Icons.auto_stories),
            label: const Text('Card incantesimi'),
          ),
        ),
      ],
    );
  }
}
