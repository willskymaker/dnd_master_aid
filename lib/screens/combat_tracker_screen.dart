import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../data/db_slot_incantesimi.dart';
import '../factory_pg_base.dart';
import '../providers/saved_characters_provider.dart';
import '../repositories/json_data_repository.dart';
import '../utils/encounter_generator.dart';
import '../utils/loot_generator.dart';
import '../widgets/mobile/mobile_scaffold.dart';

/// Combattente in una sessione di combattimento (solo in memoria, non
/// persistito: la scheda viva del PG resta la fonte di verita' per PF e
/// slot incantesimo - qui si tracciano solo i consumi durante il fight).
class _Combattente {
  final String id;
  String nome;
  final bool isPg;
  int iniziativa;
  int pfMax;
  int pfCorrenti;
  final String? classe;
  final int? livello;
  final Map<String, int> slotUsati;

  _Combattente({
    required this.nome,
    required this.iniziativa,
    required this.pfMax,
    int? pfCorrenti,
    this.isPg = false,
    this.classe,
    this.livello,
    Map<String, int>? slotUsati,
  }) : id = '${DateTime.now().microsecondsSinceEpoch}_$nome',
       pfCorrenti = pfCorrenti ?? pfMax,
       slotUsati = slotUsati ?? {};

  /// Slot totali per livello incantesimo, in base a classe/livello (vuoto
  /// se non e' una classe incantatrice o non trovata in tabella).
  List<int> get slotTotaliPerLivello {
    if (classe == null || livello == null) return const [];
    for (final s in slotIncantesimiList) {
      if (s.classe == classe) return s.slotPerLivello[livello] ?? const [];
    }
    return const [];
  }

  bool get eIncantatore => slotTotaliPerLivello.any((n) => n > 0);
}

class CombatTrackerScreen extends StatefulWidget {
  const CombatTrackerScreen({super.key});

  @override
  State<CombatTrackerScreen> createState() => _CombatTrackerScreenState();
}

class _CombatTrackerScreenState extends State<CombatTrackerScreen> {
  final List<_Combattente> _combattenti = [];
  int _turnoIndex = 0;
  int _round = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavedCharactersProvider>().loadAll();
    });
  }

  List<_Combattente> get _ordinati =>
      [..._combattenti]..sort((a, b) => b.iniziativa.compareTo(a.iniziativa));

  void _aggiungiCombattente(_Combattente c) {
    setState(() => _combattenti.add(c));
  }

  void _rimuovi(_Combattente c) {
    setState(() {
      _combattenti.removeWhere((x) => x.id == c.id);
      if (_turnoIndex >= _combattenti.length) _turnoIndex = 0;
    });
  }

  void _modificaPf(_Combattente c, int delta) {
    setState(() => c.pfCorrenti = (c.pfCorrenti + delta).clamp(0, c.pfMax));
  }

  Future<void> _modificaCombattente(_Combattente c) async {
    final nomeController = TextEditingController(text: c.nome);
    final iniziativaController = TextEditingController(text: '${c.iniziativa}');
    final pfMaxController = TextEditingController(text: '${c.pfMax}');
    final pfCorrentiController = TextEditingController(text: '${c.pfCorrenti}');

    final confermato = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Modifica combattente'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nomeController,
                    decoration: const InputDecoration(labelText: 'Nome'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: iniziativaController,
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Iniziativa (tiro + mod. Destrezza)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: pfMaxController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'PF massimi'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: pfCorrentiController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'PF correnti'),
                  ),
                ],
              ),
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

    if (confermato == true) {
      setState(() {
        final nome = nomeController.text.trim();
        if (nome.isNotEmpty) c.nome = nome;
        c.iniziativa = int.tryParse(iniziativaController.text) ?? c.iniziativa;
        c.pfMax = int.tryParse(pfMaxController.text) ?? c.pfMax;
        c.pfCorrenti = (int.tryParse(pfCorrentiController.text) ?? c.pfCorrenti)
            .clamp(0, c.pfMax);
      });
    }
  }

  void _modificaSlot(_Combattente c, int livelloIncantesimo, int delta) {
    final totali = c.slotTotaliPerLivello;
    final totale =
        livelloIncantesimo - 1 < totali.length
            ? totali[livelloIncantesimo - 1]
            : 0;
    final usatiCorrenti = c.slotUsati['$livelloIncantesimo'] ?? 0;
    final nuovoValore = (usatiCorrenti + delta).clamp(0, totale);
    setState(() => c.slotUsati['$livelloIncantesimo'] = nuovoValore);
  }

  Future<void> _mostraSlotIncantesimo(_Combattente c) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final totali = c.slotTotaliPerLivello;
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Slot incantesimo di ${c.nome}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < totali.length; i++)
                    if (totali[i] > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 80,
                              child: Text('Livello ${i + 1}'),
                            ),
                            IconButton(
                              onPressed: () {
                                _modificaSlot(c, i + 1, -1);
                                setSheetState(() {});
                              },
                              icon: const Icon(Icons.add_circle_outline),
                              color: Colors.green.shade700,
                            ),
                            SizedBox(
                              width: 56,
                              child: Text(
                                '${totali[i] - (c.slotUsati['${i + 1}'] ?? 0)} / ${totali[i]}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _modificaSlot(c, i + 1, 1);
                                setSheetState(() {});
                              },
                              icon: const Icon(Icons.remove_circle_outline),
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _prossimoTurno() {
    if (_combattenti.isEmpty) return;
    setState(() {
      _turnoIndex++;
      if (_turnoIndex >= _combattenti.length) {
        _turnoIndex = 0;
        _round++;
      }
    });
  }

  void _nuovoCombattimento() {
    setState(() {
      _combattenti.clear();
      _turnoIndex = 0;
      _round = 1;
    });
  }

  Future<void> _mostraAggiungiCombattente() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => _AggiungiCombattenteSheet(onAggiungi: _aggiungiCombattente),
    );
  }

  Future<void> _mostraGeneraIncontro() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => _GeneraIncontroSheet(
            onGenerato: (incontro) {
              final random = Random();
              for (final gruppo in incontro.gruppi) {
                final mostro = gruppo.mostro;
                final abilityScores = mostro['ability_scores'] as Map?;
                final destrezza =
                    (abilityScores?['dexterity'] as num?)?.toInt() ?? 10;
                final mod = ((destrezza - 10) / 2).floor();
                final pf = (mostro['hit_points'] as num?)?.toInt() ?? 10;
                final nome =
                    mostro['italian_name'] ?? mostro['name'] ?? 'Mostro';
                for (var i = 0; i < gruppo.quantita; i++) {
                  _aggiungiCombattente(
                    _Combattente(
                      nome: gruppo.quantita > 1 ? '$nome ${i + 1}' : nome,
                      iniziativa: random.nextInt(20) + 1 + mod,
                      pfMax: pf,
                    ),
                  );
                }
              }
            },
          ),
    );
  }

  Future<void> _mostraGeneraBottino() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _GeneraBottinoSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordinati = _ordinati;
    final inCorso = ordinati.isNotEmpty;
    final turnoCorrente =
        inCorso ? ordinati[_turnoIndex % ordinati.length] : null;

    return MobileScaffold(
      title: 'Tracker Combattimento',
      actions: [
        IconButton(
          onPressed: _mostraGeneraIncontro,
          icon: const Icon(Icons.auto_awesome),
          tooltip: 'Genera incontro',
        ),
        IconButton(
          onPressed: _mostraGeneraBottino,
          icon: const Icon(Icons.diamond_outlined),
          tooltip: 'Genera bottino',
        ),
        IconButton(
          onPressed: _combattenti.isEmpty ? null : _nuovoCombattimento,
          icon: const Icon(Icons.refresh),
          tooltip: 'Nuovo combattimento',
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostraAggiungiCombattente,
        icon: const Icon(Icons.add),
        label: const Text('Aggiungi'),
      ),
      body: Column(
        children: [
          if (inCorso)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              color: AppColors.primary.withValues(alpha: 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Round $_round',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  ElevatedButton.icon(
                    onPressed: _prossimoTurno,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.skip_next),
                    label: const Text('Prossimo turno'),
                  ),
                ],
              ),
            ),
          Expanded(
            child:
                ordinati.isEmpty
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Text(
                          'Nessun combattente. Tocca "Aggiungi" per iniziare un combattimento.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                        80,
                      ),
                      itemCount: ordinati.length,
                      itemBuilder: (context, index) {
                        final c = ordinati[index];
                        final attivo = identical(c, turnoCorrente);
                        return Card(
                          color:
                              attivo
                                  ? AppColors.primary.withValues(alpha: 0.12)
                                  : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            side:
                                attivo
                                    ? const BorderSide(
                                      color: AppColors.primary,
                                      width: 2,
                                    )
                                    : BorderSide.none,
                          ),
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () => _modificaCombattente(c),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.sm,
                                  ),
                                  child: SizedBox(
                                    width: 32,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${c.iniziativa}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Icon(
                                          Icons.edit,
                                          size: 10,
                                          color: Colors.grey[400],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _modificaCombattente(c),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c.nome,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${c.isPg ? "PG" : "Mostro"} · PF ${c.pfCorrenti}/${c.pfMax}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (c.eIncantatore)
                                  IconButton(
                                    onPressed: () => _mostraSlotIncantesimo(c),
                                    icon: const Icon(Icons.auto_fix_high),
                                    color: AppColors.primary,
                                    tooltip: 'Slot incantesimo',
                                  ),
                                IconButton(
                                  onPressed: () => _modificaPf(c, -1),
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: Colors.red,
                                ),
                                IconButton(
                                  onPressed: () => _modificaPf(c, 1),
                                  icon: const Icon(Icons.add_circle_outline),
                                  color: Colors.green,
                                ),
                                IconButton(
                                  onPressed: () => _rimuovi(c),
                                  icon: const Icon(Icons.close),
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

enum _ModalitaAggiunta { pg, mostro, manuale }

class _AggiungiCombattenteSheet extends StatefulWidget {
  final void Function(_Combattente) onAggiungi;

  const _AggiungiCombattenteSheet({required this.onAggiungi});

  @override
  State<_AggiungiCombattenteSheet> createState() =>
      _AggiungiCombattenteSheetState();
}

class _AggiungiCombattenteSheetState extends State<_AggiungiCombattenteSheet> {
  _ModalitaAggiunta _modalita = _ModalitaAggiunta.pg;
  final _nomeController = TextEditingController();
  final _pfController = TextEditingController();
  final _iniziativaController = TextEditingController();
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _risultatiMostri = [];
  final _random = Random();

  @override
  void dispose() {
    _nomeController.dispose();
    _pfController.dispose();
    _iniziativaController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cercaMostri(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _risultatiMostri = []);
      return;
    }
    final risultati = await JsonDataRepository.searchMonsters(query: query);
    if (!mounted) return;
    setState(() => _risultatiMostri = risultati.take(20).toList());
  }

  void _aggiungiPg(PGBase pg) {
    final mod = pg.modificatori['DES'] ?? 0;
    final iniziativa = _random.nextInt(20) + 1 + mod;
    widget.onAggiungi(
      _Combattente(
        nome: pg.nome.isNotEmpty ? pg.nome : 'Personaggio',
        iniziativa: iniziativa,
        pfMax: pg.puntiVita,
        pfCorrenti: pg.puntiVitaCorrenti,
        isPg: true,
        classe: pg.classe,
        livello: pg.livello,
        slotUsati: Map<String, int>.from(pg.slotIncantesimoUsati),
      ),
    );
    Navigator.pop(context);
  }

  void _aggiungiMostro(Map<String, dynamic> mostro) {
    final abilityScores = mostro['ability_scores'] as Map?;
    final destrezza = (abilityScores?['dexterity'] as num?)?.toInt() ?? 10;
    final mod = ((destrezza - 10) / 2).floor();
    final iniziativa = _random.nextInt(20) + 1 + mod;
    final pf = (mostro['hit_points'] as num?)?.toInt() ?? 10;
    widget.onAggiungi(
      _Combattente(
        nome: mostro['italian_name'] ?? mostro['name'] ?? 'Mostro',
        iniziativa: iniziativa,
        pfMax: pf,
      ),
    );
    Navigator.pop(context);
  }

  void _aggiungiManuale() {
    final nome = _nomeController.text.trim();
    if (nome.isEmpty) return;
    final pf = int.tryParse(_pfController.text) ?? 1;
    final iniziativa =
        int.tryParse(_iniziativaController.text) ?? (_random.nextInt(20) + 1);
    widget.onAggiungi(
      _Combattente(nome: nome, iniziativa: iniziativa, pfMax: pf),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder:
          (_, scrollController) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aggiungi combattente',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SegmentedButton<_ModalitaAggiunta>(
                  segments: const [
                    ButtonSegment(
                      value: _ModalitaAggiunta.pg,
                      label: Text('PG salvato'),
                    ),
                    ButtonSegment(
                      value: _ModalitaAggiunta.mostro,
                      label: Text('Mostro'),
                    ),
                    ButtonSegment(
                      value: _ModalitaAggiunta.manuale,
                      label: Text('Manuale'),
                    ),
                  ],
                  selected: {_modalita},
                  onSelectionChanged:
                      (sel) => setState(() => _modalita = sel.first),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: switch (_modalita) {
                    _ModalitaAggiunta.pg => _buildListaPg(scrollController),
                    _ModalitaAggiunta.mostro => _buildRicercaMostri(
                      scrollController,
                    ),
                    _ModalitaAggiunta.manuale => _buildFormManuale(),
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildListaPg(ScrollController scrollController) {
    return Consumer<SavedCharactersProvider>(
      builder: (context, provider, _) {
        if (provider.characters.isEmpty) {
          return const Center(child: Text('Nessun personaggio salvato'));
        }
        return ListView.builder(
          controller: scrollController,
          itemCount: provider.characters.length,
          itemBuilder: (context, index) {
            final pg = provider.characters[index];
            return ListTile(
              title: Text(pg.nome.isNotEmpty ? pg.nome : 'Senza nome'),
              subtitle: Text(
                '${pg.classe} · Livello ${pg.livello} · PF ${pg.puntiVitaCorrenti}/${pg.puntiVita}',
              ),
              onTap: () => _aggiungiPg(pg),
            );
          },
        );
      },
    );
  }

  Widget _buildRicercaMostri(ScrollController scrollController) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Cerca mostro...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: _cercaMostri,
        ),
        const SizedBox(height: 8),
        Expanded(
          child:
              _risultatiMostri.isEmpty
                  ? const Center(child: Text('Cerca un mostro per nome'))
                  : ListView.builder(
                    controller: scrollController,
                    itemCount: _risultatiMostri.length,
                    itemBuilder: (context, index) {
                      final m = _risultatiMostri[index];
                      return ListTile(
                        title: Text(m['italian_name'] ?? m['name'] ?? '?'),
                        subtitle: Text(
                          'GS ${m['challenge_rating'] ?? '?'} · PF ${m['hit_points'] ?? '?'}',
                        ),
                        onTap: () => _aggiungiMostro(m),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildFormManuale() {
    return Column(
      children: [
        TextField(
          controller: _nomeController,
          decoration: const InputDecoration(labelText: 'Nome'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _pfController,
          decoration: const InputDecoration(labelText: 'PF massimi'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _iniziativaController,
          decoration: const InputDecoration(
            labelText: 'Iniziativa (vuoto = casuale)',
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _aggiungiManuale,
            child: const Text('Aggiungi'),
          ),
        ),
      ],
    );
  }
}

/// Genera un incontro casuale bilanciato per il party indicato e lo
/// restituisce tramite [onGenerato], da usare per popolare il combattimento.
class _GeneraIncontroSheet extends StatefulWidget {
  final void Function(IncontroGenerato) onGenerato;

  const _GeneraIncontroSheet({required this.onGenerato});

  @override
  State<_GeneraIncontroSheet> createState() => _GeneraIncontroSheetState();
}

class _GeneraIncontroSheetState extends State<_GeneraIncontroSheet> {
  int _numeroGiocatori = 4;
  int _livelloMedio = 1;
  DifficoltaIncontro _difficolta = DifficoltaIncontro.media;
  bool _generando = false;
  IncontroGenerato? _risultato;

  static const _nomiDifficolta = {
    DifficoltaIncontro.facile: 'Facile',
    DifficoltaIncontro.media: 'Media',
    DifficoltaIncontro.difficile: 'Difficile',
    DifficoltaIncontro.mortale: 'Mortale',
  };

  Future<void> _genera() async {
    setState(() => _generando = true);
    final mostri = await JsonDataRepository.loadMonsters();
    final incontro = generaIncontro(
      mostriDisponibili: mostri,
      numeroGiocatori: _numeroGiocatori,
      livelloMedio: _livelloMedio,
      difficolta: _difficolta,
    );
    if (!mounted) return;
    setState(() {
      _risultato = incontro;
      _generando = false;
    });
  }

  void _conferma() {
    final risultato = _risultato;
    if (risultato == null || risultato.vuoto) return;
    widget.onGenerato(risultato);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
            'Genera incontro',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Giocatori'),
                    Slider(
                      value: _numeroGiocatori.toDouble(),
                      min: 1,
                      max: 8,
                      divisions: 7,
                      label: '$_numeroGiocatori',
                      onChanged:
                          (v) => setState(() => _numeroGiocatori = v.round()),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Livello medio party'),
                    Slider(
                      value: _livelloMedio.toDouble(),
                      min: 1,
                      max: 20,
                      divisions: 19,
                      label: '$_livelloMedio',
                      onChanged:
                          (v) => setState(() => _livelloMedio = v.round()),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children:
                DifficoltaIncontro.values.map((d) {
                  return ChoiceChip(
                    label: Text(_nomiDifficolta[d]!),
                    selected: _difficolta == d,
                    onSelected: (_) => setState(() => _difficolta = d),
                  );
                }).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _generando ? null : _genera,
              child:
                  _generando
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text('Genera'),
            ),
          ),
          if (_risultato != null) ...[
            const SizedBox(height: 16),
            if (_risultato!.vuoto)
              const Text('Nessun mostro adatto trovato, riprova.')
            else ...[
              for (final gruppo in _risultato!.gruppi)
                Text(
                  '${gruppo.quantita}x ${gruppo.mostro['italian_name'] ?? gruppo.mostro['name']} (${gruppo.xpTotale} XP)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 4),
              Text(
                'Soglia richiesta: ${_risultato!.sogliaRichiesta} XP adeguato',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _conferma,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B4513),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Aggiungi al combattimento'),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// Genera un bottino casuale (monete + oggetti magici) per il tier scelto,
/// pescando dal catalogo oggetti magici (assets/data/magic_items.json).
class _GeneraBottinoSheet extends StatefulWidget {
  const _GeneraBottinoSheet();

  @override
  State<_GeneraBottinoSheet> createState() => _GeneraBottinoSheetState();
}

class _GeneraBottinoSheetState extends State<_GeneraBottinoSheet> {
  TierBottino _tier = TierBottino.basso;
  bool _generando = false;
  Bottino? _risultato;

  Future<void> _genera() async {
    setState(() => _generando = true);
    final oggetti = await JsonDataRepository.loadMagicItems();
    final bottino = generaBottino(tier: _tier, oggettiDisponibili: oggetti);
    if (!mounted) return;
    setState(() {
      _risultato = bottino;
      _generando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final risultato = _risultato;
    return SingleChildScrollView(
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
            'Genera bottino',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                TierBottino.values.map((t) {
                  return ChoiceChip(
                    label: Text(nomeTier(t)),
                    selected: _tier == t,
                    onSelected: (_) => setState(() => _tier = t),
                  );
                }).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _generando ? null : _genera,
              child:
                  _generando
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text('Genera'),
            ),
          ),
          if (risultato != null) ...[
            const SizedBox(height: 16),
            const Text('Monete', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              [
                if (risultato.platino > 0) '${risultato.platino} mp',
                if (risultato.oro > 0) '${risultato.oro} mo',
                if (risultato.argento > 0) '${risultato.argento} ma',
                if (risultato.rame > 0) '${risultato.rame} mr',
              ].join(', '),
            ),
            if (risultato.oggettiMagici.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Oggetti magici',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              for (final oggetto in risultato.oggettiMagici)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${oggetto['italian_name'] ?? oggetto['name']} (${oggetto['rarity']})',
                  ),
                ),
            ],
          ],
        ],
      ),
    );
  }
}
