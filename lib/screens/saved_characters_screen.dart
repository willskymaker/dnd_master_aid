import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../factory_pg_base.dart';
import '../providers/saved_characters_provider.dart';
import '../widgets/mobile/mobile_scaffold.dart';

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

class _SchedaBottomSheet extends StatelessWidget {
  final PGBase pg;

  const _SchedaBottomSheet({required this.pg});

  @override
  Widget build(BuildContext context) {
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
                Text(
                  pg.nome.isNotEmpty ? pg.nome : 'Personaggio',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${pg.classe} · ${pg.specie} · Livello ${pg.livello}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
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
                  'Caratteristiche',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                const SizedBox(height: 32),
              ],
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
            final val = pg.caratteristiche[s] ?? 0;
            final mod = pg.modificatori[s] ?? 0;
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

/// Condizioni ufficiali di D&D 5e con una sintesi del loro effetto
/// meccanico, mostrata come tooltip al tocco lungo sul chip.
const Map<String, String> _condizioniD20 = {
  'Accecato':
      'Fallisce automaticamente le prove che richiedono la vista. I tiri per '
      'colpire contro di lui hanno vantaggio, i suoi hanno svantaggio.',
  'Affascinato':
      'Non può attaccare chi lo affascina né bersagliarlo con effetti '
      'dannosi. Chi lo affascina ha vantaggio nelle interazioni sociali.',
  'Assordato': 'Fallisce automaticamente le prove che richiedono l\'udito.',
  'Afferrato':
      'Velocità 0, non beneficia di bonus alla velocità. Finisce se chi '
      'afferra viene incapacitato o allontanato.',
  'Impaurito':
      'Svantaggio a prove e attacchi finché la fonte della paura è in '
      'vista; non può avvicinarsi volontariamente ad essa.',
  'Incapacitato': 'Non può compiere azioni né reazioni.',
  'Invisibile':
      'Impossibile da vedere senza mezzi speciali. I suoi attacchi hanno '
      'vantaggio, quelli contro di lui svantaggio.',
  'Paralizzato':
      'Incapacitato, non può muoversi né parlare. Fallisce automaticamente '
      'i TS su Forza e Destrezza. Gli attacchi contro di lui hanno '
      'vantaggio e sono critici se da 1,5 metri o meno.',
  'Pietrificato':
      'Trasformato in sostanza inanimata, incapacitato, non consapevole. '
      'Resistenza a tutti i danni.',
  'Avvelenato':
      'Svantaggio ai tiri per colpire e alle prove di caratteristica.',
  'Prono':
      'Svantaggio ai tiri per colpire. Gli attacchi in mischia contro di '
      'lui hanno vantaggio, quelli a distanza svantaggio.',
  'Trattenuto':
      'Velocità 0. Svantaggio ai tiri per colpire e ai TS su Destrezza. '
      'Gli attacchi contro di lui hanno vantaggio.',
  'Stordito':
      'Incapacitato, non può muoversi, parla a stento. Fallisce '
      'automaticamente i TS su Forza e Destrezza. Gli attacchi contro di '
      'lui hanno vantaggio.',
  'Esausto':
      'Livelli cumulativi di penalità (svantaggio a prove, velocità '
      'dimezzata, PF massimi ridotti, fino alla morte al livello 6).',
  'Incosciente':
      'Incapacitato, non consapevole, cade prono e lascia cadere ciò che '
      'tiene in mano. Fallisce automaticamente i TS su Forza e Destrezza. '
      'Gli attacchi contro di lui hanno vantaggio e sono critici se da 1,5 '
      'metri o meno.',
};

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
          _condizioniD20.entries.map((entry) {
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
