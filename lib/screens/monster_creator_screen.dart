import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/homebrew_monster.dart';
import '../services/homebrew_monster_service.dart';
import '../utils/cr_calculator.dart';
import '../utils/damage_types.dart';
import '../widgets/mobile/mobile_scaffold.dart';

/// Schermata per la creazione e modifica di mostri homebrew con stima
/// automatica del GS (Grado di Sfida) secondo le regole DMG 5e.
class MonsterCreatorScreen extends StatefulWidget {
  /// Se fornito, carica il mostro per la modifica; altrimenti crea uno nuovo.
  final HomebrewMonster? monstroDaModificare;

  const MonsterCreatorScreen({super.key, this.monstroDaModificare});

  @override
  State<MonsterCreatorScreen> createState() => _MonsterCreatorScreenState();
}

class _MonsterCreatorScreenState extends State<MonsterCreatorScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- Controller per i campi di testo ---
  late final TextEditingController _nomeController;
  late final TextEditingController _caController;
  late final TextEditingController _pfController;
  late final TextEditingController _dadiVitaController;
  late final TextEditingController _velocitaController;
  late final TextEditingController _forzaController;
  late final TextEditingController _destrezzaController;
  late final TextEditingController _costituzioneController;
  late final TextEditingController _intelligenzaController;
  late final TextEditingController _saggezzaController;
  late final TextEditingController _carismaController;

  // --- Stato della form ---
  String _tipo = 'humanoid';
  String _taglia = 'Medium';
  final List<String> _resistenze = [];
  final List<String> _immunitaDanno = [];
  final List<AzioneHomebrew> _azioni = [];
  final List<AbilitaSpecialeHomebrew> _abilitaSpeciali = [];

  // --- GS stimato (aggiornato in tempo reale) ---
  RisultatoGS _gsStimato = calcolaGs(
    hp: 10,
    dannoMedioPerRound: 0,
    bonusAttacco: 3,
  );

  bool _salvando = false;

  static const List<String> _tipi = [
    'aberration',
    'beast',
    'celestial',
    'construct',
    'dragon',
    'elemental',
    'fey',
    'fiend',
    'giant',
    'humanoid',
    'monstrosity',
    'ooze',
    'plant',
    'undead',
  ];

  static const List<String> _taglie = [
    'Tiny',
    'Small',
    'Medium',
    'Large',
    'Huge',
    'Gargantuan',
  ];

  @override
  void initState() {
    super.initState();
    final m = widget.monstroDaModificare;
    _nomeController = TextEditingController(text: m?.nome ?? '');
    _caController = TextEditingController(text: (m?.ca ?? 10).toString());
    _pfController = TextEditingController(text: (m?.pf ?? 10).toString());
    _dadiVitaController = TextEditingController(text: m?.dadiVita ?? '');
    _velocitaController = TextEditingController(
      text: (m?.velocita ?? 30).toString(),
    );
    _forzaController = TextEditingController(text: (m?.forza ?? 10).toString());
    _destrezzaController = TextEditingController(
      text: (m?.destrezza ?? 10).toString(),
    );
    _costituzioneController = TextEditingController(
      text: (m?.costituzione ?? 10).toString(),
    );
    _intelligenzaController = TextEditingController(
      text: (m?.intelligenza ?? 10).toString(),
    );
    _saggezzaController = TextEditingController(
      text: (m?.saggezza ?? 10).toString(),
    );
    _carismaController = TextEditingController(
      text: (m?.carisma ?? 10).toString(),
    );

    if (m != null) {
      _tipo = m.tipo;
      _taglia = m.taglia;
      _resistenze.addAll(m.resistenze);
      _immunitaDanno.addAll(m.immunitaDanno);
      _azioni.addAll(m.azioni);
      _abilitaSpeciali.addAll(m.abilitaSpeciali);
    }

    _aggiornaGs();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _caController.dispose();
    _pfController.dispose();
    _dadiVitaController.dispose();
    _velocitaController.dispose();
    _forzaController.dispose();
    _destrezzaController.dispose();
    _costituzioneController.dispose();
    _intelligenzaController.dispose();
    _saggezzaController.dispose();
    _carismaController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Calcolo GS in tempo reale
  // ---------------------------------------------------------------------------

  void _aggiornaGs() {
    final hp = int.tryParse(_pfController.text) ?? 1;
    // Stima danno/round dalla prima azione con danno (semplificato)
    int dannoStimato = 0;
    int bonusAttacco = 3;
    for (final azione in _azioni) {
      if (azione.danno != null && azione.danno!.isNotEmpty) {
        dannoStimato = _stimaDannoMedio(azione.danno!);
        if (azione.bonusAttacco != null) {
          bonusAttacco =
              int.tryParse(azione.bonusAttacco!.replaceAll('+', '')) ??
              bonusAttacco;
        }
        break;
      }
    }

    final resistenze = ResistenzeImmunita(
      haResistenze: _resistenze.length >= 2,
      haImmunita: _immunitaDanno.length >= 2,
    );

    setState(() {
      _gsStimato = calcolaGs(
        hp: hp < 1 ? 1 : hp,
        dannoMedioPerRound: dannoStimato,
        bonusAttacco: bonusAttacco,
        resistenze: resistenze,
      );
    });
  }

  /// Stima grossolana del danno medio da una stringa come "2d6+3 slashing".
  int _stimaDannoMedio(String dannoStr) {
    // Estrae la prima parte numerica: es. "2d6+3"
    final match = RegExp(r'(\d+)d(\d+)([+-]\d+)?').firstMatch(dannoStr);
    if (match == null) return int.tryParse(dannoStr.split(' ').first) ?? 0;
    final dadi = int.parse(match.group(1)!);
    final facce = int.parse(match.group(2)!);
    final bonus = int.tryParse(match.group(3) ?? '0') ?? 0;
    return (dadi * (facce + 1) / 2).round() + bonus;
  }

  // ---------------------------------------------------------------------------
  // Salvataggio
  // ---------------------------------------------------------------------------

  Future<void> _salva() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);
    try {
      final mostro = HomebrewMonster.create(
        nome: _nomeController.text.trim(),
        ca: int.tryParse(_caController.text) ?? 10,
        pf: int.tryParse(_pfController.text) ?? 10,
        dadiVita:
            _dadiVitaController.text.trim().isEmpty
                ? null
                : _dadiVitaController.text.trim(),
        velocita: int.tryParse(_velocitaController.text) ?? 30,
        forza: int.tryParse(_forzaController.text) ?? 10,
        destrezza: int.tryParse(_destrezzaController.text) ?? 10,
        costituzione: int.tryParse(_costituzioneController.text) ?? 10,
        intelligenza: int.tryParse(_intelligenzaController.text) ?? 10,
        saggezza: int.tryParse(_saggezzaController.text) ?? 10,
        carisma: int.tryParse(_carismaController.text) ?? 10,
        tipo: _tipo,
        taglia: _taglia,
        resistenze: List.from(_resistenze),
        immunitaDanno: List.from(_immunitaDanno),
        azioni: List.from(_azioni),
        abilitaSpeciali: List.from(_abilitaSpeciali),
        challengeRating: _gsStimato.gsFormattato,
        experiencePoints: _xpDaGs(_gsStimato.gsFinale),
      );

      await HomebrewMonsterService.salva(mostro);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${mostro.nome} salvato!')));
      Navigator.pop(context, mostro);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore nel salvataggio: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  /// XP standard del DMG per GS (approssimazione per GS fino a 30).
  int _xpDaGs(double gs) {
    final xpPerGs = {
      0.0: 10,
      0.125: 25,
      0.25: 50,
      0.5: 100,
      1.0: 200,
      2.0: 450,
      3.0: 700,
      4.0: 1100,
      5.0: 1800,
      6.0: 2300,
      7.0: 2900,
      8.0: 3900,
      9.0: 5000,
      10.0: 5900,
      11.0: 7200,
      12.0: 8400,
      13.0: 10000,
      14.0: 11500,
      15.0: 13000,
      16.0: 15000,
      17.0: 18000,
      18.0: 20000,
      19.0: 22000,
      20.0: 25000,
      21.0: 33000,
      22.0: 41000,
      23.0: 50000,
      24.0: 62000,
      25.0: 75000,
      26.0: 90000,
      27.0: 105000,
      28.0: 120000,
      29.0: 135000,
      30.0: 155000,
    };
    return xpPerGs[gs] ?? (gs * 1000).round();
  }

  // ---------------------------------------------------------------------------
  // Gestione azioni
  // ---------------------------------------------------------------------------

  void _aggiungiAzione() {
    showDialog<AzioneHomebrew>(
      context: context,
      builder: (_) => const _DialogAzione(),
    ).then((azione) {
      if (azione != null) {
        setState(() => _azioni.add(azione));
        _aggiornaGs();
      }
    });
  }

  void _rimuoviAzione(int index) {
    setState(() => _azioni.removeAt(index));
    _aggiornaGs();
  }

  // ---------------------------------------------------------------------------
  // Gestione abilità speciali
  // ---------------------------------------------------------------------------

  void _aggiungiAbilita() {
    showDialog<AbilitaSpecialeHomebrew>(
      context: context,
      builder: (_) => const _DialogAbilita(),
    ).then((abilita) {
      if (abilita != null) {
        setState(() => _abilitaSpeciali.add(abilita));
      }
    });
  }

  void _rimuoviAbilita(int index) {
    setState(() => _abilitaSpeciali.removeAt(index));
  }

  // ---------------------------------------------------------------------------
  // Gestione resistenze / immunità
  // ---------------------------------------------------------------------------

  void _mostraSelezioneTipiDanno({required bool sonoImmunita}) {
    final lista = sonoImmunita ? _immunitaDanno : _resistenze;
    showDialog<void>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(sonoImmunita ? 'Immunità ai danni' : 'Resistenze'),
            content: SizedBox(
              width: double.maxFinite,
              child: StatefulBuilder(
                builder:
                    (ctx, innerSetState) => ListView(
                      shrinkWrap: true,
                      children:
                          tipiDanno.map((tipo) {
                            // Il filtro usa la chiave inglese corrispondente
                            final chiaveEn = _chiaveEnDaTipoIt(tipo);
                            final selezionato = lista.contains(chiaveEn);
                            return CheckboxListTile(
                              title: Text(tipo),
                              value: selezionato,
                              onChanged: (val) {
                                innerSetState(() {
                                  if (val == true) {
                                    lista.add(chiaveEn);
                                  } else {
                                    lista.remove(chiaveEn);
                                  }
                                });
                              },
                            );
                          }).toList(),
                    ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _aggiornaGs();
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  String _chiaveEnDaTipoIt(String tipoIt) {
    const mappa = {
      'Contundente': 'bludgeoning',
      'Perforante': 'piercing',
      'Tagliente': 'slashing',
      'Acido': 'acid',
      'Freddo': 'cold',
      'Fuoco': 'fire',
      'Forza': 'force',
      'Fulmine': 'lightning',
      'Necrotico': 'necrotic',
      'Veleno': 'poison',
      'Psichico': 'psychic',
      'Radiante': 'radiant',
      'Tuono': 'thunder',
    };
    return mappa[tipoIt] ?? tipoIt.toLowerCase();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return MobileScaffold(
      title: 'Crea Mostro',
      titleBadge: 'HOMEBREW',
      actions: [
        IconButton(
          icon:
              _salvando
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Icon(Icons.save),
          tooltip: 'Salva mostro',
          onPressed: _salvando ? null : _salva,
        ),
      ],
      body: Form(
        key: _formKey,
        onChanged: _aggiornaGs,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _buildGsBadge(),
            const SizedBox(height: AppSpacing.lg),
            _buildSezionePrincipale(),
            const SizedBox(height: AppSpacing.lg),
            _buildSezioneCaratteristiche(),
            const SizedBox(height: AppSpacing.lg),
            _buildSezioneResistenze(),
            const SizedBox(height: AppSpacing.lg),
            _buildSezioneAzioni(),
            const SizedBox(height: AppSpacing.lg),
            _buildSezioneAbilita(),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _salvando ? null : _salva,
                icon: const Icon(Icons.save),
                label: const Text('Salva mostro'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Widget sezioni
  // ---------------------------------------------------------------------------

  Widget _buildGsBadge() {
    return Card(
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Text(
              'GS STIMATO',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white70,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _gsStimato.gsFormattato,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Difensivo: GS ${formattaGs(_gsStimato.gsDifensivo)}  '
              '·  Offensivo: GS ${formattaGs(_gsStimato.gsOffensivo)}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSezionePrincipale() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titolSezione('Informazioni base'),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _nomeController,
          decoration: const InputDecoration(
            labelText: 'Nome *',
            border: OutlineInputBorder(),
          ),
          validator:
              (v) => (v == null || v.trim().isEmpty) ? 'Richiesto' : null,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _caController,
                decoration: const InputDecoration(
                  labelText: 'CA',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextFormField(
                controller: _pfController,
                decoration: const InputDecoration(
                  labelText: 'PF *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator:
                    (v) => (int.tryParse(v ?? '') ?? 0) < 1 ? 'Almeno 1' : null,
                onChanged: (_) => _aggiornaGs(),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _dadiVitaController,
                decoration: const InputDecoration(
                  labelText: 'Dadi vita (es. 2d8+4)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextFormField(
                controller: _velocitaController,
                decoration: const InputDecoration(
                  labelText: 'Velocità (ft)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _taglia,
                decoration: const InputDecoration(
                  labelText: 'Taglia',
                  border: OutlineInputBorder(),
                ),
                items:
                    _taglie
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                onChanged: (v) => setState(() => _taglia = v ?? _taglia),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _tipo,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
                items:
                    _tipi
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                onChanged: (v) => setState(() => _tipo = v ?? _tipo),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSezioneCaratteristiche() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titolSezione('Caratteristiche'),
        const SizedBox(height: AppSpacing.sm),
        _buildRigaCaratteristiche([
          _buildStatField('FOR', _forzaController),
          _buildStatField('DES', _destrezzaController),
          _buildStatField('COS', _costituzioneController),
        ]),
        const SizedBox(height: AppSpacing.sm),
        _buildRigaCaratteristiche([
          _buildStatField('INT', _intelligenzaController),
          _buildStatField('SAG', _saggezzaController),
          _buildStatField('CAR', _carismaController),
        ]),
      ],
    );
  }

  Widget _buildRigaCaratteristiche(List<Widget> campi) {
    return Row(
      children:
          campi
              .expand(
                (w) => [
                  Expanded(child: w),
                  const SizedBox(width: AppSpacing.sm),
                ],
              )
              .toList()
            ..removeLast(),
    );
  }

  Widget _buildStatField(String label, TextEditingController controller) {
    final valore = int.tryParse(controller.text) ?? 10;
    final mod = (valore - 10) ~/ 2;
    final modStr = mod >= 0 ? '+$mod' : '$mod';

    return Column(
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            helperText: modStr,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
          ),
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildSezioneResistenze() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titolSezione('Resistenze e Immunità'),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildChipList(
                titolo: 'Resistenze',
                lista: _resistenze,
                colore: Colors.orange.shade100,
                onModifica:
                    () => _mostraSelezioneTipiDanno(sonoImmunita: false),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildChipList(
                titolo: 'Immunità',
                lista: _immunitaDanno,
                colore: Colors.red.shade100,
                onModifica: () => _mostraSelezioneTipiDanno(sonoImmunita: true),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChipList({
    required String titolo,
    required List<String> lista,
    required Color colore,
    required VoidCallback onModifica,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(titolo, style: Theme.of(context).textTheme.labelLarge),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: onModifica,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          lista.isEmpty
              ? Text(
                'Nessuna',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              )
              : Wrap(
                spacing: 4,
                runSpacing: 4,
                children:
                    lista
                        .map(
                          (d) => Chip(
                            label: Text(
                              d,
                              style: const TextStyle(fontSize: 11),
                            ),
                            backgroundColor: colore,
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                        .toList(),
              ),
        ],
      ),
    );
  }

  Widget _buildSezioneAzioni() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _titolSezione('Azioni'),
            const Spacer(),
            TextButton.icon(
              onPressed: _aggiungiAzione,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Aggiungi'),
            ),
          ],
        ),
        if (_azioni.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Text(
              'Nessuna azione aggiunta',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          )
        else
          ..._azioni.asMap().entries.map(
            (e) => Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                title: Text(e.value.nome),
                subtitle: Text(
                  [
                    if (e.value.danno != null) 'Danno: ${e.value.danno}',
                    if (e.value.bonusAttacco != null)
                      'Bonus: ${e.value.bonusAttacco}',
                    if (e.value.descrizione.isNotEmpty) e.value.descrizione,
                  ].join(' · '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _rimuoviAzione(e.key),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSezioneAbilita() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _titolSezione('Abilità Speciali'),
            const Spacer(),
            TextButton.icon(
              onPressed: _aggiungiAbilita,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Aggiungi'),
            ),
          ],
        ),
        if (_abilitaSpeciali.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Text(
              'Nessuna abilità speciale',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          )
        else
          ..._abilitaSpeciali.asMap().entries.map(
            (e) => Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                title: Text(e.value.nome),
                subtitle: Text(
                  e.value.descrizione,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _rimuoviAbilita(e.key),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _titolSezione(String testo) => Text(
    testo,
    style: Theme.of(
      context,
    ).textTheme.titleSmall?.copyWith(color: AppColors.primary),
  );
}

// =============================================================================
// Dialog per aggiungere un'azione
// =============================================================================

class _DialogAzione extends StatefulWidget {
  const _DialogAzione();

  @override
  State<_DialogAzione> createState() => _DialogAzioneState();
}

class _DialogAzioneState extends State<_DialogAzione> {
  final _nomeController = TextEditingController();
  final _descrizioneController = TextEditingController();
  final _dannoController = TextEditingController();
  final _bonusController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _descrizioneController.dispose();
    _dannoController.dispose();
    _bonusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuova azione'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _dannoController,
              decoration: const InputDecoration(
                labelText: 'Danno (es. 2d6+3 slashing)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _bonusController,
              decoration: const InputDecoration(
                labelText: 'Bonus attacco (es. +5)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _descrizioneController,
              decoration: const InputDecoration(
                labelText: 'Descrizione',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nomeController.text.trim().isEmpty) return;
            Navigator.pop(
              context,
              AzioneHomebrew(
                nome: _nomeController.text.trim(),
                descrizione: _descrizioneController.text.trim(),
                danno:
                    _dannoController.text.trim().isEmpty
                        ? null
                        : _dannoController.text.trim(),
                bonusAttacco:
                    _bonusController.text.trim().isEmpty
                        ? null
                        : _bonusController.text.trim(),
              ),
            );
          },
          child: const Text('Aggiungi'),
        ),
      ],
    );
  }
}

// =============================================================================
// Dialog per aggiungere un'abilità speciale
// =============================================================================

class _DialogAbilita extends StatefulWidget {
  const _DialogAbilita();

  @override
  State<_DialogAbilita> createState() => _DialogAbilitaState();
}

class _DialogAbilitaState extends State<_DialogAbilita> {
  final _nomeController = TextEditingController();
  final _descrizioneController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _descrizioneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuova abilità speciale'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nomeController,
            decoration: const InputDecoration(
              labelText: 'Nome *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _descrizioneController,
            decoration: const InputDecoration(
              labelText: 'Descrizione',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nomeController.text.trim().isEmpty) return;
            Navigator.pop(
              context,
              AbilitaSpecialeHomebrew(
                nome: _nomeController.text.trim(),
                descrizione: _descrizioneController.text.trim(),
              ),
            );
          },
          child: const Text('Aggiungi'),
        ),
      ],
    );
  }
}
