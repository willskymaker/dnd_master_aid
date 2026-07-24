import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../providers/settings_provider.dart';
import '../widgets/mobile/mobile_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MobileScaffold(
      title: 'Impostazioni',
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            'Alcune funzioni sono pensate per velocizzare il gioco, ma '
            'possono far somigliare Master Aid a un videogioco più che a un '
            'gdr. Il Master può disattivarle per tenere il tavolo più fedele '
            'alle regole classiche.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          SwitchListTile(
            title: const Text('Costruzione PG casuale'),
            subtitle: const Text(
              'Mostra i pulsanti "casuale" nella creazione guidata del '
              'personaggio (specie, classe, livello, caratteristiche, '
              'abilità, background, equipaggiamento).',
            ),
            value: settings.randomizzazionePgAttiva,
            activeThumbColor: AppColors.primary,
            onChanged: settings.setRandomizzazionePg,
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Barra vita mostri (Vista Giocatori)'),
            subtitle: const Text(
              'Permette di mostrare ai giocatori una fascia di salute dei '
              'mostri nel Tracker Combattimento, invece di gestire i PF '
              'solo a voce.',
            ),
            value: settings.barraSaluteMostriAttiva,
            activeThumbColor: AppColors.primary,
            onChanged: settings.setBarraSaluteMostri,
          ),
        ],
      ),
    );
  }
}
