import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../data/db_incantesimi.dart';
import '../repositories/json_data_repository.dart';
import '../widgets/mobile/mobile_scaffold.dart';
import '../widgets/spell_card.dart';

/// Genera card riassuntive per gli incantesimi rilevanti di un PG o di un
/// mostro/PNG: si cerca l'incantesimo per nome e lo si aggiunge al mazzo di
/// card da consultare rapidamente durante la sessione.
class SpellCardsScreen extends StatefulWidget {
  final List<String> nomiIniziali;

  const SpellCardsScreen({super.key, this.nomiIniziali = const []});

  @override
  State<SpellCardsScreen> createState() => _SpellCardsScreenState();
}

class _SpellCardsScreenState extends State<SpellCardsScreen> {
  final _searchController = TextEditingController();
  List<Incantesimo> _risultati = [];
  final List<Incantesimo> _selezionati = [];
  bool _caricamentoIniziale = false;

  @override
  void initState() {
    super.initState();
    if (widget.nomiIniziali.isNotEmpty) _caricaIniziali();
  }

  Future<void> _caricaIniziali() async {
    setState(() => _caricamentoIniziale = true);
    final tutti = await JsonDataRepository.loadSpells();
    if (!mounted) return;
    setState(() {
      for (final nome in widget.nomiIniziali) {
        final trovato = tutti.firstWhere(
          (s) => s.nome.toLowerCase() == nome.toLowerCase(),
          orElse:
              () => Incantesimo(
                nome: '',
                livello: 0,
                scuola: '',
                classi: const [],
                descrizione: '',
                raggio: '',
                durata: '',
                tempoLancio: '',
                componenti: const [],
              ),
        );
        if (trovato.nome.isNotEmpty) _selezionati.add(trovato);
      }
      _caricamentoIniziale = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cerca(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _risultati = []);
      return;
    }
    final risultati = await JsonDataRepository.searchSpells(query: query);
    if (!mounted) return;
    setState(() => _risultati = risultati.take(20).toList());
  }

  void _aggiungi(Incantesimo incantesimo) {
    setState(() {
      if (!_selezionati.any((s) => s.nome == incantesimo.nome)) {
        _selezionati.add(incantesimo);
      }
      _risultati = [];
      _searchController.clear();
    });
  }

  void _rimuovi(Incantesimo incantesimo) {
    setState(() => _selezionati.removeWhere((s) => s.nome == incantesimo.nome));
  }

  @override
  Widget build(BuildContext context) {
    return MobileScaffold(
      title: 'Card Incantesimi',
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Cerca incantesimo per nome...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _cerca,
            ),
            if (_risultati.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 220),
                margin: const EdgeInsets.only(top: AppSpacing.sm),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _risultati.length,
                  itemBuilder: (context, index) {
                    final s = _risultati[index];
                    return ListTile(
                      dense: true,
                      title: Text(s.nome),
                      subtitle: Text(
                        s.eTrucchetto
                            ? 'Trucchetto · ${s.scuola}'
                            : 'Livello ${s.livello} · ${s.scuola}',
                      ),
                      onTap: () => _aggiungi(s),
                    );
                  },
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child:
                  _caricamentoIniziale
                      ? const Center(child: CircularProgressIndicator())
                      : _selezionati.isEmpty
                      ? Center(
                        child: Text(
                          'Nessuna card. Cerca un incantesimo per aggiungerlo\nal mazzo da consultare durante la sessione.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _selezionati.length,
                        itemBuilder: (context, index) {
                          final s = _selezionati[index];
                          return SpellCard(
                            incantesimo: s,
                            onRemove: () => _rimuovi(s),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
