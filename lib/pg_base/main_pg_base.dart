import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../factory_pg_base.dart';
import 'steps/step_nome.dart';
import 'steps/step_specie.dart';
import 'steps/step_classe.dart';
import 'steps/step_livello.dart';
import 'steps/step_caratteristiche.dart';
import 'steps/step_abilita.dart';
import 'steps/step_equip.dart';
import 'steps/step_export.dart';
import '../core/logger.dart';
import '../providers/character_provider.dart';

const _stepsInfo = [
  {'icona': '✏️', 'nome': 'Nome', 'descr': 'Come si chiama il tuo personaggio?'},
  {'icona': '🧬', 'nome': 'Specie', 'descr': 'Elfo, Nano, Umano...'},
  {'icona': '⚔️', 'nome': 'Classe', 'descr': 'Guerriero, Mago, Ladro...'},
  {'icona': '⭐', 'nome': 'Livello', 'descr': 'Da 1 a 20'},
  {'icona': '💪', 'nome': 'Caratteristiche', 'descr': 'FOR, DES, COS, INT, SAG, CAR'},
  {'icona': '🎯', 'nome': 'Abilità', 'descr': 'Le competenze della tua classe'},
  {'icona': '🛡️', 'nome': 'Equipaggiamento', 'descr': 'Armi, armature e oggetti'},
  {'icona': '📜', 'nome': 'Scheda', 'descr': 'Salva o esporta il personaggio'},
];

class PGBaseWizard extends StatefulWidget {
  const PGBaseWizard({super.key});

  @override
  State<PGBaseWizard> createState() => _PGBaseWizardState();
}

class _PGBaseWizardState extends State<PGBaseWizard> {
  final PGBaseFactory factory = PGBaseFactory();
  bool _inCorso = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(title: const Text('Crea Personaggio')),
      body: Column(
        children: [
          // Banner errore dal provider
          Consumer<CharacterProvider>(
            builder: (context, provider, _) {
              if (provider.errorMessage == null) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(provider.errorMessage!,
                            style: const TextStyle(color: Colors.red))),
                    IconButton(
                        onPressed: provider.clearError,
                        icon: const Icon(Icons.close, color: Colors.red)),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Intestazione
                  const Text(
                    '🧙‍♂️ Generatore guidato di personaggio',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Seguirai ${_stepsInfo.length} semplici passi',
                    style:
                        TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Lista step
                  ...List.generate(_stepsInfo.length, (i) {
                    final step = _stepsInfo[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B4513).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(step['icona']!,
                                  style: const TextStyle(fontSize: 18)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${i + 1}. ${step["nome"]}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                                Text(
                                  step['descr']!,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _inCorso ? null : _iniziaCreazione,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B4513),
                        foregroundColor: Colors.white,
                      ),
                      icon: _inCorso
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.play_arrow),
                      label: Text(
                        _inCorso ? 'Creazione in corso...' : 'Inizia la creazione',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _iniziaCreazione() async {
    setState(() => _inCorso = true);
    try {
      AppLogger.info('Iniziando creazione personaggio');

      if (!await _eseguiStep('Nome', () => vaiAStepNome(context, factory))) return;
      if (!await _eseguiStep('Specie', () => vaiAStepSpecie(context, factory))) return;
      if (!await _eseguiStep('Classe', () => vaiAStepClasse(context, factory))) return;
      if (!await _eseguiStep('Livello', () => vaiAStepLivello(context, factory))) return;
      if (!await _eseguiStep('Caratteristiche', () => vaiAStepCaratteristiche(context, factory))) return;
      if (!await _eseguiStep('Abilità', () => vaiAStepAbilita(context, factory))) return;
      if (!await _eseguiStep('Equipaggiamento', () => vaiAStepEquipaggiamento(context, factory))) return;

      await _eseguiStep('Scheda', () => vaiAStepExportPDF(context, factory));
    } catch (e, stackTrace) {
      AppLogger.error('Errore durante la creazione del personaggio', e, stackTrace);
      _mostraErrore('Errore durante la creazione del personaggio: $e');
    } finally {
      if (mounted) setState(() => _inCorso = false);
    }
  }

  Future<bool> _eseguiStep(
      String nomeStep, Future<bool> Function() stepFunction) async {
    try {
      AppLogger.debug('Eseguendo step: $nomeStep');
      final result = await stepFunction();
      if (!result) AppLogger.info('Step $nomeStep annullato dall\'utente');
      return result;
    } catch (e, stackTrace) {
      AppLogger.error('Errore nello step $nomeStep', e, stackTrace);
      _mostraErrore('Errore nello step $nomeStep: $e');
      return false;
    }
  }

  void _mostraErrore(String messaggio) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Errore', style: TextStyle(color: Colors.red)),
        content: Text(messaggio),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'))
        ],
      ),
    );
  }
}

// Navigator helpers — ritornano tutti Future<bool> per il flusso wizard
Future<bool> vaiAStepNome(
    BuildContext context, PGBaseFactory factory) async {
  return await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StepNomeScreen(factory: factory)),
      ) ??
      false;
}

Future<bool> vaiAStepSpecie(
    BuildContext context, PGBaseFactory factory) async {
  return await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StepSpecieScreen(factory: factory)),
      ) ??
      false;
}

Future<bool> vaiAStepClasse(
    BuildContext context, PGBaseFactory factory) async {
  return await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StepClasseScreen(factory: factory)),
      ) ??
      false;
}

Future<bool> vaiAStepLivello(
    BuildContext context, PGBaseFactory factory) async {
  return await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => StepLivelloScreen(factory: factory)),
      ) ??
      false;
}

Future<bool> vaiAStepCaratteristiche(
    BuildContext context, PGBaseFactory factory) async {
  return await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => StepCaratteristicheScreen(factory: factory)),
      ) ??
      false;
}

Future<bool> vaiAStepAbilita(
    BuildContext context, PGBaseFactory factory) async {
  return await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => StepAbilitaScreen(factory: factory)),
      ) ??
      false;
}

Future<bool> vaiAStepEquipaggiamento(
    BuildContext context, PGBaseFactory factory) async {
  return await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StepEquipScreen(factory: factory)),
      ) ??
      false;
}
