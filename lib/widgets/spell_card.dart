import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../data/db_incantesimi.dart';

/// Card riassuntiva di un incantesimo, pensata per essere consultata
/// rapidamente dal Master durante la sessione di gioco.
class SpellCard extends StatelessWidget {
  final Incantesimo incantesimo;
  final VoidCallback? onRemove;

  const SpellCard({super.key, required this.incantesimo, this.onRemove});

  @override
  Widget build(BuildContext context) {
    final i = incantesimo;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    i.nome,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onRemove != null)
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.close),
                    color: Colors.grey,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            Text(
              i.eTrucchetto
                  ? 'Trucchetto · ${i.scuola}'
                  : 'Livello ${i.livello} · ${i.scuola}',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: 4,
              children: [
                _Dettaglio('Tempo di lancio', i.tempoLancio),
                _Dettaglio('Raggio', i.raggio),
                _Dettaglio('Componenti', i.componenti.join(', ')),
                _Dettaglio('Durata', i.durata),
              ],
            ),
            if (i.classi.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Classi: ${i.classi.join(', ')}',
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Text(i.descrizione),
          ],
        ),
      ),
    );
  }
}

class _Dettaglio extends StatelessWidget {
  final String label;
  final String valore;

  const _Dettaglio(this.label, this.valore);

  @override
  Widget build(BuildContext context) {
    if (valore.isEmpty) return const SizedBox.shrink();
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style.copyWith(fontSize: 12),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: valore),
        ],
      ),
    );
  }
}
