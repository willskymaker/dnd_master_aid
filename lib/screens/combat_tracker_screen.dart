import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../factory_pg_base.dart';
import '../providers/saved_characters_provider.dart';
import '../repositories/json_data_repository.dart';
import '../widgets/mobile/mobile_scaffold.dart';

/// Combattente in una sessione di combattimento (solo in memoria, non
/// persistito: la scheda viva del PG resta la fonte di verita' per i PF).
class _Combattente {
  final String id;
  final String nome;
  final bool isPg;
  final int iniziativa;
  final int pfMax;
  int pfCorrenti;

  _Combattente({
    required this.nome,
    required this.iniziativa,
    required this.pfMax,
    int? pfCorrenti,
    this.isPg = false,
  }) : id = '${DateTime.now().microsecondsSinceEpoch}_$nome',
       pfCorrenti = pfCorrenti ?? pfMax;
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
                                SizedBox(
                                  width: 32,
                                  child: Text(
                                    '${c.iniziativa}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Expanded(
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
