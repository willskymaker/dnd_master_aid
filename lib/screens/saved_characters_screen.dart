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
      BuildContext context, SavedCharactersProvider provider, PGBase pg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF8B4513).withOpacity(0.15),
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
              Text('${pg.classe} ${pg.specie.isNotEmpty ? "· ${pg.specie}" : ""} · Livello ${pg.livello}'),
              const SizedBox(height: 2),
              Text(
                'HP: ${pg.puntiVita}  •  Velocità: ${pg.velocita}m',
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
      case 'barbaro': return '⚔️';
      case 'bardo': return '🎵';
      case 'chierico': return '✝️';
      case 'druido': return '🌿';
      case 'guerriero': return '🛡️';
      case 'ladro': return '🗡️';
      case 'mago': return '🔮';
      case 'monaco': return '👊';
      case 'paladino': return '⚜️';
      case 'ranger': return '🏹';
      case 'stregone': return '✨';
      case 'warlock': return '👁️';
      default: return '🧙';
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
      builder: (_, controller) => Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          controller: controller,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              pg.nome.isNotEmpty ? pg.nome : 'Personaggio',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${pg.classe} · ${pg.specie} · Livello ${pg.livello}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const Divider(height: 24),
            _riga('Punti Vita', '${pg.puntiVita} (d${pg.dadoVita})'),
            _riga('Velocità', '${pg.velocita} m'),
            if (pg.background.isNotEmpty) _riga('Background', pg.background),
            if (pg.allineamento.isNotEmpty) _riga('Allineamento', pg.allineamento),
            if (pg.linguaggi.isNotEmpty) _riga('Linguaggi', pg.linguaggi.join(', ')),
            const Divider(height: 24),
            const Text('Caratteristiche', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
              const Text('Equipaggiamento', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              ...pg.equipaggiamento.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $e'),
                  )),
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
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
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
      children: stats.map((s) {
        final val = pg.caratteristiche[s] ?? 0;
        final mod = pg.modificatori[s] ?? 0;
        final segno = mod >= 0 ? '+' : '';
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF8B4513).withOpacity(0.4)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(s, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF8B4513))),
              Text('$val', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('$segno$mod', style: const TextStyle(fontSize: 13)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
