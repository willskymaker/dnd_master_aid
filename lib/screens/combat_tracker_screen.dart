import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_theme.dart';
import '../data/db_condizioni.dart';
import '../data/db_slot_incantesimi.dart';
import '../factory_pg_base.dart';
import '../providers/saved_characters_provider.dart';
import '../providers/settings_provider.dart';
import '../repositories/json_data_repository.dart';
import '../services/homebrew_monster_service.dart';
import '../utils/damage_types.dart';
import '../utils/encounter_generator.dart';
import '../utils/health_band.dart';
import '../utils/loot_generator.dart';
import '../utils/npc_generator.dart' hide calcolaGs;
import '../utils/tactical_hints.dart';
import '../widgets/mobile/mobile_scaffold.dart';
import 'dice_roller.dart';
import 'spell_cards_screen.dart';

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
  int? ca;
  int? cd;
  final String? classe;
  final int? livello;
  final Map<String, int> slotUsati;
  final List<String> condizioni;

  /// Dati completi del mostro (da monsters.json), usati per la vista
  /// dettagli (caratteristiche, azioni, abilita' speciali, azioni
  /// leggendarie). Null per PG e combattenti manuali.
  final Map<String, dynamic>? datiMostro;
  final int? azioniLeggendarieMax;
  int azioniLeggendarieUsate = 0;
  int tsMorteSuccessi = 0;
  int tsMorteFallimenti = 0;

  _Combattente({
    required this.nome,
    required this.iniziativa,
    required this.pfMax,
    int? pfCorrenti,
    this.isPg = false,
    this.ca,
    this.classe,
    this.livello,
    Map<String, int>? slotUsati,
    List<String>? condizioni,
    this.datiMostro,
    this.azioniLeggendarieMax,
  }) : id = '${DateTime.now().microsecondsSinceEpoch}_$nome',
       pfCorrenti = pfCorrenti ?? pfMax,
       slotUsati = slotUsati ?? {},
       condizioni = condizioni ?? [];

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

  bool get eLeggendario => azioniLeggendarieMax != null;
}

/// Descrizione di un mostro all'interno di un incontro preparato e salvato:
/// solo i dati necessari a ricreare un _Combattente da zero (niente stato
/// di combattimento in corso, quello si genera al ripristino).
class _MostroBlueprint {
  final String nome;
  final int pfMax;
  final int? ca;
  final Map<String, dynamic>? datiMostro;
  final int? azioniLeggendarieMax;

  _MostroBlueprint({
    required this.nome,
    required this.pfMax,
    this.ca,
    this.datiMostro,
    this.azioniLeggendarieMax,
  });

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'pfMax': pfMax,
    'ca': ca,
    'datiMostro': datiMostro,
    'azioniLeggendarieMax': azioniLeggendarieMax,
  };

  factory _MostroBlueprint.fromJson(Map<String, dynamic> j) => _MostroBlueprint(
    nome: j['nome'] as String,
    pfMax: (j['pfMax'] as num).toInt(),
    ca: (j['ca'] as num?)?.toInt(),
    datiMostro: (j['datiMostro'] as Map?)?.cast<String, dynamic>(),
    azioniLeggendarieMax: (j['azioniLeggendarieMax'] as num?)?.toInt(),
  );
}

class _EncounterPreset {
  final String nome;
  final List<_MostroBlueprint> mostri;

  _EncounterPreset({required this.nome, required this.mostri});

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'mostri': mostri.map((m) => m.toJson()).toList(),
  };

  factory _EncounterPreset.fromJson(Map<String, dynamic> j) => _EncounterPreset(
    nome: j['nome'] as String,
    mostri:
        (j['mostri'] as List)
            .map(
              (m) =>
                  _MostroBlueprint.fromJson((m as Map).cast<String, dynamic>()),
            )
            .toList(),
  );
}

class CombatTrackerScreen extends StatefulWidget {
  const CombatTrackerScreen({super.key});

  @override
  State<CombatTrackerScreen> createState() => _CombatTrackerScreenState();
}

class _CombatTrackerScreenState extends State<CombatTrackerScreen> {
  static const _prefsKeyIncontri = 'combat_tracker_incontri_salvati';

  final List<_Combattente> _combattenti = [];
  int _turnoIndex = 0;
  int _round = 1;
  List<_EncounterPreset> _incontriSalvati = [];
  bool _vistaGiocatori = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavedCharactersProvider>().loadAll();
    });
    _caricaIncontriSalvati();
  }

  Future<void> _caricaIncontriSalvati() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKeyIncontri);
    if (raw == null) return;
    final lista =
        (jsonDecode(raw) as List)
            .map(
              (e) =>
                  _EncounterPreset.fromJson((e as Map).cast<String, dynamic>()),
            )
            .toList();
    if (mounted) setState(() => _incontriSalvati = lista);
  }

  Future<void> _persistiIncontriSalvati() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKeyIncontri,
      jsonEncode(_incontriSalvati.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _salvaIncontroCorrente() async {
    final mostri =
        _combattenti
            .where((c) => !c.isPg)
            .map(
              (c) => _MostroBlueprint(
                nome: c.nome,
                pfMax: c.pfMax,
                ca: c.ca,
                datiMostro: c.datiMostro,
                azioniLeggendarieMax: c.azioniLeggendarieMax,
              ),
            )
            .toList();
    if (mostri.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aggiungi almeno un mostro prima di salvare'),
        ),
      );
      return;
    }
    final controller = TextEditingController();
    final nome = await showDialog<String>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Salva incontro'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nome incontro'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annulla'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                child: const Text('Salva'),
              ),
            ],
          ),
    );
    if (nome == null || nome.isEmpty) return;
    setState(() {
      _incontriSalvati.removeWhere((e) => e.nome == nome);
      _incontriSalvati.add(_EncounterPreset(nome: nome, mostri: mostri));
    });
    await _persistiIncontriSalvati();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Incontro "$nome" salvato')));
    }
  }

  Future<void> _mostraIncontriSalvati() async {
    if (_incontriSalvati.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nessun incontro salvato')));
      return;
    }
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => SafeArea(
            child: ListView(
              shrinkWrap: true,
              children: [
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    'Incontri salvati',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                for (final preset in _incontriSalvati)
                  ListTile(
                    title: Text(preset.nome),
                    subtitle: Text('${preset.mostri.length} mostri'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _ripristinaIncontro(preset);
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _eliminaIncontroSalvato(preset);
                      },
                    ),
                  ),
              ],
            ),
          ),
    );
  }

  void _ripristinaIncontro(_EncounterPreset preset) {
    final random = Random();
    setState(() {
      for (final m in preset.mostri) {
        _combattenti.add(
          _Combattente(
            nome: m.nome,
            iniziativa: random.nextInt(20) + 1,
            pfMax: m.pfMax,
            ca: m.ca,
            datiMostro: m.datiMostro,
            azioniLeggendarieMax: m.azioniLeggendarieMax,
          ),
        );
      }
    });
  }

  Future<void> _eliminaIncontroSalvato(_EncounterPreset preset) async {
    setState(() => _incontriSalvati.removeWhere((e) => e.nome == preset.nome));
    await _persistiIncontriSalvati();
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
    setState(() {
      c.pfCorrenti = (c.pfCorrenti + delta).clamp(0, c.pfMax);
      if (c.pfCorrenti > 0) {
        c.tsMorteSuccessi = 0;
        c.tsMorteFallimenti = 0;
      }
    });
  }

  Future<void> _mostraApplicaDanno(_Combattente c) async {
    final dannoController = TextEditingController();
    String? tipoSelezionato;

    final confermato = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text('Applica danno a ${c.nome}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: dannoController,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantità di danno',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    initialValue: tipoSelezionato,
                    decoration: const InputDecoration(
                      labelText: 'Tipo di danno (opzionale)',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Nessuno (danno pieno)'),
                      ),
                      for (final tipo in tipiDanno)
                        DropdownMenuItem<String?>(
                          value: tipo,
                          child: Text(tipo),
                        ),
                    ],
                    onChanged: (v) => setDialogState(() => tipoSelezionato = v),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Annulla'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Applica'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confermato != true) return;
    final danno = int.tryParse(dannoController.text) ?? 0;
    if (danno <= 0) return;

    if (tipoSelezionato == null) {
      _modificaPf(c, -danno);
      return;
    }

    final risultato = applicaResistenze(
      danno: danno,
      tipoDannoItaliano: tipoSelezionato!,
      datiMostro: c.datiMostro,
    );
    _modificaPf(c, -risultato.dannoApplicato);
    if (risultato.messaggio != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(risultato.messaggio!)));
    }
  }

  /// Tira un TS contro la morte per un combattente a 0 PF: 20 naturale
  /// risveglia con 1 PF, 1 naturale conta come 2 fallimenti, 10+ e' un
  /// successo, il resto un fallimento. 3 successi stabilizzano, 3
  /// fallimenti significano morte.
  void _tiraTsMorte(_Combattente c) {
    final roll = Random().nextInt(20) + 1;
    final String esito;
    if (roll == 20) {
      esito = '20 naturale! ${c.nome} si risveglia con 1 PF';
    } else if (roll == 1) {
      esito = '1 naturale: 2 fallimenti per ${c.nome}';
    } else if (roll >= 10) {
      esito = '$roll: successo per ${c.nome}';
    } else {
      esito = '$roll: fallimento per ${c.nome}';
    }

    setState(() {
      if (roll == 20) {
        c.pfCorrenti = 1;
        c.tsMorteSuccessi = 0;
        c.tsMorteFallimenti = 0;
      } else if (roll == 1) {
        c.tsMorteFallimenti = (c.tsMorteFallimenti + 2).clamp(0, 3);
      } else if (roll >= 10) {
        c.tsMorteSuccessi = (c.tsMorteSuccessi + 1).clamp(0, 3);
      } else {
        c.tsMorteFallimenti = (c.tsMorteFallimenti + 1).clamp(0, 3);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(esito)));
  }

  /// Riga compatta dei tiri salvezza contro la morte per un combattente a
  /// 0 PF: pallini per successi/fallimenti e un dado per tirare, oppure
  /// un'etichetta se e' gia' morto o stabilizzato.
  /// Barra colorata (blu -> giallo -> rosso man mano che i PF scendono),
  /// senza mostrare alcun numero: solo lo stato relativo di salute, per la
  /// Vista Giocatori.
  Widget _barraSalute(InfoFasciaSalute info) {
    final colore = switch (info.fascia) {
      FasciaSalute.sano => Colors.blue,
      FasciaSalute.ferito => Colors.amber.shade700,
      FasciaSalute.gravementeFerito => Colors.red,
      FasciaSalute.morente => Colors.grey.shade800,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: info.frazione,
            minHeight: 8,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation(colore),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          info.etichetta,
          style: TextStyle(
            fontSize: 12,
            color: colore,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _rigaTsMorte(_Combattente c) {
    if (c.tsMorteFallimenti >= 3) {
      return const Row(
        children: [
          Icon(Icons.dangerous, color: Colors.red, size: 16),
          SizedBox(width: 4),
          Text(
            'Morto',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      );
    }
    if (c.tsMorteSuccessi >= 3) {
      return const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 16),
          SizedBox(width: 4),
          Text(
            'Stabilizzato',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        const Text('TS Morte ', style: TextStyle(fontSize: 12)),
        for (var i = 0; i < 3; i++)
          Icon(
            i < c.tsMorteSuccessi ? Icons.circle : Icons.circle_outlined,
            size: 12,
            color: Colors.green,
          ),
        const SizedBox(width: 6),
        for (var i = 0; i < 3; i++)
          Icon(
            i < c.tsMorteFallimenti ? Icons.circle : Icons.circle_outlined,
            size: 12,
            color: Colors.red,
          ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => _tiraTsMorte(c),
          child: const Icon(Icons.casino, size: 18, color: AppColors.primary),
        ),
      ],
    );
  }

  Future<void> _modificaCombattente(_Combattente c) async {
    final nomeController = TextEditingController(text: c.nome);
    final iniziativaController = TextEditingController(text: '${c.iniziativa}');
    final pfMaxController = TextEditingController(text: '${c.pfMax}');
    final pfCorrentiController = TextEditingController(text: '${c.pfCorrenti}');
    final caController = TextEditingController(text: c.ca?.toString() ?? '');
    final cdController = TextEditingController(text: c.cd?.toString() ?? '');
    final condizioniSelezionate = Set<String>.from(c.condizioni);

    final confermato = await showDialog<bool>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
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
                          decoration: const InputDecoration(
                            labelText: 'PF massimi',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: pfCorrentiController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'PF correnti',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: caController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'CA',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: cdController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'CD',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Condizioni attive',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children:
                              condizioniD20.keys.map((condizione) {
                                final attiva = condizioniSelezionate.contains(
                                  condizione,
                                );
                                return FilterChip(
                                  label: Text(condizione),
                                  selected: attiva,
                                  onSelected:
                                      (sel) => setDialogState(() {
                                        if (sel) {
                                          condizioniSelezionate.add(condizione);
                                        } else {
                                          condizioniSelezionate.remove(
                                            condizione,
                                          );
                                        }
                                      }),
                                );
                              }).toList(),
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
        if (c.pfCorrenti > 0) {
          c.tsMorteSuccessi = 0;
          c.tsMorteFallimenti = 0;
        }
        c.ca = int.tryParse(caController.text);
        c.cd = int.tryParse(cdController.text);
        c.condizioni
          ..clear()
          ..addAll(condizioniSelezionate);
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
        for (final c in _combattenti) {
          if (c.eLeggendario) c.azioniLeggendarieUsate = 0;
        }
      }
    });
  }

  void _modificaAzioniLeggendarie(_Combattente c, int delta) {
    final max = c.azioniLeggendarieMax ?? 0;
    setState(
      () =>
          c.azioniLeggendarieUsate = (c.azioniLeggendarieUsate + delta).clamp(
            0,
            max,
          ),
    );
  }

  Future<void> _mostraDettagliMostro(_Combattente c) async {
    final dati = c.datiMostro;
    if (dati == null) return;
    final abilityScores = dati['ability_scores'] as Map?;
    final azioni = (dati['actions'] as List?) ?? const [];
    final azioniSpeciali = (dati['special_abilities'] as List?) ?? const [];
    final azioniLeggendarie = (dati['legendary_actions'] as List?) ?? const [];
    final suggerimenti = suggerimentiTattici(
      datiMostro: dati,
      pfCorrenti: c.pfCorrenti,
      pfMax: c.pfMax,
    );

    const nomiCaratteristiche = {
      'strength': 'FOR',
      'dexterity': 'DES',
      'constitution': 'COS',
      'intelligence': 'INT',
      'wisdom': 'SAG',
      'charisma': 'CAR',
    };

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              maxChildSize: 0.95,
              minChildSize: 0.4,
              expand: false,
              builder:
                  (_, scrollController) => ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        c.nome,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'CA ${c.ca ?? '?'} · PF ${c.pfCorrenti}/${c.pfMax}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      if (abilityScores != null) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children:
                              nomiCaratteristiche.entries.map((e) {
                                final valore =
                                    (abilityScores[e.key] as num?)?.toInt();
                                if (valore == null) return const SizedBox();
                                final mod = ((valore - 10) / 2).floor();
                                return Column(
                                  children: [
                                    Text(
                                      e.value,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '$valore (${mod >= 0 ? '+' : ''}$mod)',
                                    ),
                                  ],
                                );
                              }).toList(),
                        ),
                      ],
                      if (suggerimenti.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Suggerimento',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              for (final s in suggerimenti)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text('• $s'),
                                ),
                            ],
                          ),
                        ),
                      ],
                      if (azioniSpeciali.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Abilità speciali',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        for (final a in azioniSpeciali)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '${a['name']}: ${a['description'] ?? ''}',
                            ),
                          ),
                      ],
                      if (azioni.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Azioni',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        for (final a in azioni)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '${a['name']}: ${a['description'] ?? ''}',
                            ),
                          ),
                      ],
                      if (azioniLeggendarie.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Azioni leggendarie',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    _modificaAzioniLeggendarie(c, -1);
                                    setSheetState(() {});
                                  },
                                  icon: const Icon(Icons.add_circle_outline),
                                  color: Colors.green.shade700,
                                ),
                                Text(
                                  '${(c.azioniLeggendarieMax ?? 0) - c.azioniLeggendarieUsate} / ${c.azioniLeggendarieMax ?? 0}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    _modificaAzioniLeggendarie(c, 1);
                                    setSheetState(() {});
                                  },
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ],
                        ),
                        for (final a in azioniLeggendarie)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '${a['name']}: ${a['description'] ?? ''}',
                            ),
                          ),
                      ],
                    ],
                  ),
            );
          },
        );
      },
    );
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
                final ca = (mostro['armor_class'] as num?)?.toInt();
                final azioniLeggendarie = mostro['legendary_actions'] as List?;
                final nome =
                    mostro['italian_name'] ?? mostro['name'] ?? 'Mostro';
                for (var i = 0; i < gruppo.quantita; i++) {
                  _aggiungiCombattente(
                    _Combattente(
                      nome: gruppo.quantita > 1 ? '$nome ${i + 1}' : nome,
                      iniziativa: random.nextInt(20) + 1 + mod,
                      pfMax: pf,
                      ca: ca,
                      datiMostro: mostro,
                      azioniLeggendarieMax:
                          (azioniLeggendarie != null &&
                                  azioniLeggendarie.isNotEmpty)
                              ? 3
                              : null,
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
    final barraSaluteMostriAttiva =
        context.watch<SettingsProvider>().barraSaluteMostriAttiva;
    final vistaGiocatori = _vistaGiocatori && barraSaluteMostriAttiva;

    return MobileScaffold(
      title: 'Tracker Combattimento',
      actions: [
        if (barraSaluteMostriAttiva)
          IconButton(
            onPressed: () => setState(() => _vistaGiocatori = !_vistaGiocatori),
            icon: Icon(
              vistaGiocatori ? Icons.visibility : Icons.visibility_outlined,
            ),
            style:
                vistaGiocatori
                    ? IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                    )
                    : null,
            tooltip: 'Vista Giocatori',
          ),
        if (!vistaGiocatori)
          PopupMenuButton<String>(
            tooltip: 'Altre azioni',
            onSelected: (azione) {
              switch (azione) {
                case 'dadi':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DiceRollerScreen()),
                  );
                case 'incantesimi':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SpellCardsScreen()),
                  );
                case 'genera_incontro':
                  _mostraGeneraIncontro();
                case 'salva_incontro':
                  _salvaIncontroCorrente();
                case 'incontri_salvati':
                  _mostraIncontriSalvati();
                case 'genera_bottino':
                  _mostraGeneraBottino();
                case 'nuovo_combattimento':
                  _nuovoCombattimento();
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'dadi',
                    child: ListTile(
                      leading: Icon(Icons.casino),
                      title: Text('Tira dadi'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'incantesimi',
                    child: ListTile(
                      leading: Icon(Icons.auto_stories),
                      title: Text('Card incantesimi'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'genera_incontro',
                    child: ListTile(
                      leading: Icon(Icons.auto_awesome),
                      title: Text('Genera incontro'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'salva_incontro',
                    child: ListTile(
                      leading: Icon(Icons.save_outlined),
                      title: Text('Salva incontro'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'incontri_salvati',
                    child: ListTile(
                      leading: Icon(Icons.folder_open_outlined),
                      title: Text('Incontri salvati'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'genera_bottino',
                    child: ListTile(
                      leading: Icon(Icons.diamond_outlined),
                      title: Text('Genera bottino'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'nuovo_combattimento',
                    enabled: _combattenti.isNotEmpty,
                    child: const ListTile(
                      leading: Icon(Icons.refresh),
                      title: Text('Nuovo combattimento'),
                    ),
                  ),
                ],
          ),
      ],
      floatingActionButton:
          vistaGiocatori
              ? null
              : FloatingActionButton.extended(
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
                                    onTap:
                                        vistaGiocatori
                                            ? null
                                            : () => _modificaCombattente(c),
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
                                        if (vistaGiocatori && !c.isPg)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                              bottom: 2,
                                            ),
                                            child: _barraSalute(
                                              fasciaSalute(
                                                pfCorrenti: c.pfCorrenti,
                                                pfMax: c.pfMax,
                                              ),
                                            ),
                                          )
                                        else
                                          Text(
                                            '${c.isPg ? "PG" : "Mostro"}'
                                            '${c.ca != null ? " · CA ${c.ca}" : ""}'
                                            '${!vistaGiocatori && c.cd != null ? " · CD ${c.cd}" : ""}'
                                            ' · PF ${c.pfCorrenti}/${c.pfMax}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        if (c.condizioni.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: Wrap(
                                              spacing: 4,
                                              runSpacing: 4,
                                              children:
                                                  c.condizioni
                                                      .map(
                                                        (cond) => Chip(
                                                          label: Text(
                                                            cond,
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 11,
                                                                ),
                                                          ),
                                                          visualDensity:
                                                              VisualDensity
                                                                  .compact,
                                                          materialTapTargetSize:
                                                              MaterialTapTargetSize
                                                                  .shrinkWrap,
                                                          padding:
                                                              EdgeInsets.zero,
                                                          backgroundColor:
                                                              Colors
                                                                  .red
                                                                  .shade50,
                                                        ),
                                                      )
                                                      .toList(),
                                            ),
                                          ),
                                        if (c.isPg && c.pfCorrenti <= 0)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: _rigaTsMorte(c),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (!vistaGiocatori) ...[
                                  if (c.datiMostro != null)
                                    IconButton(
                                      onPressed: () => _mostraDettagliMostro(c),
                                      icon: const Icon(Icons.info_outline),
                                      color: Colors.grey[700],
                                      tooltip: 'Dettagli mostro',
                                    ),
                                  if (c.eIncantatore)
                                    IconButton(
                                      onPressed:
                                          () => _mostraSlotIncantesimo(c),
                                      icon: const Icon(Icons.auto_fix_high),
                                      color: AppColors.primary,
                                      tooltip: 'Slot incantesimo',
                                    ),
                                  IconButton(
                                    onPressed: () => _mostraApplicaDanno(c),
                                    icon: const Icon(
                                      Icons.local_fire_department_outlined,
                                    ),
                                    color: Colors.deepOrange,
                                    tooltip: 'Applica danno tipizzato',
                                  ),
                                  IconButton(
                                    onPressed: () => _modificaPf(c, -1),
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
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
    // Cerca sia nei mostri SRD che in quelli homebrew salvati localmente.
    final futures = await Future.wait([
      JsonDataRepository.searchMonsters(query: query),
      HomebrewMonsterService.caricaComeMaps(),
    ]);
    final srd = futures[0];
    final homebrew =
        futures[1].where((m) {
          final q = query.toLowerCase();
          final nome = (m['italian_name'] as String? ?? '').toLowerCase();
          final nomeEn = (m['name'] as String? ?? '').toLowerCase();
          return nome.contains(q) || nomeEn.contains(q);
        }).toList();
    if (!mounted) return;
    // Mostri homebrew in cima, poi SRD (al massimo 20 risultati totali).
    final tutti = [...homebrew, ...srd];
    setState(() => _risultatiMostri = tutti.take(20).toList());
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
        condizioni: List<String>.from(pg.condizioniAttive),
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
    final ca = (mostro['armor_class'] as num?)?.toInt();
    final azioniLeggendarie = mostro['legendary_actions'] as List?;
    widget.onAggiungi(
      _Combattente(
        nome: mostro['italian_name'] ?? mostro['name'] ?? 'Mostro',
        iniziativa: iniziativa,
        pfMax: pf,
        ca: ca,
        datiMostro: mostro,
        azioniLeggendarieMax:
            (azioniLeggendarie != null && azioniLeggendarie.isNotEmpty)
                ? 3
                : null,
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
                      final isHomebrew = m['source'] == 'Homebrew';
                      return ListTile(
                        title: Row(
                          children: [
                            Text(m['italian_name'] ?? m['name'] ?? '?'),
                            if (isHomebrew) ...[
                              const SizedBox(width: 6),
                              const _HomebrewBadge(),
                            ],
                          ],
                        ),
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

/// Piccolo badge che segnala un mostro homebrew nella lista di ricerca.
class _HomebrewBadge extends StatelessWidget {
  const _HomebrewBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'HB',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
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
