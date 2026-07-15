import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../services/saved_npc_service.dart';
import '../utils/npc_generator.dart';
import '../widgets/mobile/mobile_scaffold.dart';

/// Elenco dei PNG salvati dal Master, da riusare in sessioni future della
/// stessa campagna (es. come committente ricorrente di una side quest).
class SavedNpcsScreen extends StatefulWidget {
  const SavedNpcsScreen({super.key});

  @override
  State<SavedNpcsScreen> createState() => _SavedNpcsScreenState();
}

class _SavedNpcsScreenState extends State<SavedNpcsScreen> {
  List<Png> _png = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carica();
  }

  Future<void> _carica() async {
    final png = await SavedNpcService.caricaTutti();
    if (!mounted) return;
    setState(() {
      _png = png;
      _loading = false;
    });
  }

  Future<void> _elimina(Png png) async {
    await SavedNpcService.elimina(png.id);
    if (!mounted) return;
    setState(() => _png.removeWhere((p) => p.id == png.id));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${png.nome} eliminato')));
  }

  void _mostraDettagli(Png png) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(png.nome, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.md),
                  _sezione('Aspetto', png.aspetto),
                  _sezione('Personalità', png.personalita),
                  _sezione('Occupazione', png.occupazione),
                  _sezione('Gancio di trama', png.ganceTrama),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
    );
  }

  Widget _sezione(String titolo, String testo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titolo,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(testo),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MobileScaffold(
      title: 'PNG salvati',
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _png.isEmpty
              ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    'Nessun PNG salvato. Generane uno e salvalo per '
                    'ritrovarlo qui nelle prossime sessioni della campagna.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: _png.length,
                itemBuilder: (context, index) {
                  final png = _png[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ListTile(
                      title: Text(png.nome),
                      subtitle: Text(
                        png.occupazione,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _mostraDettagli(png),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _elimina(png),
                        tooltip: 'Elimina',
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
