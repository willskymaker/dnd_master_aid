import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';

class DiceRollerScreen extends StatefulWidget {
  const DiceRollerScreen({super.key});

  @override
  State<DiceRollerScreen> createState() => _DiceRollerScreenState();
}

enum _VantaggioMode { normale, vantaggio, svantaggio }

class _RollRecord {
  final String label;
  final int totale;
  final String dettaglio;
  _RollRecord(this.label, this.totale, this.dettaglio);
}

/// Un gruppo di dadi extra da tirare insieme al dado principale (es. il
/// "+1d6" di un attacco con bonus, tirato insieme al dado dell'arma).
class _DadoExtra {
  final int numero;
  final int facce;
  const _DadoExtra(this.numero, this.facce);

  Map<String, dynamic> toJson() => {'numero': numero, 'facce': facce};

  factory _DadoExtra.fromJson(Map<String, dynamic> json) =>
      _DadoExtra(json['numero'] as int? ?? 1, json['facce'] as int? ?? 6);
}

/// Configurazione di lancio salvata dall'utente con un nome a scelta (es.
/// "Palla di fuoco" = 6d6), per richiamarla senza reimpostare tutto ogni
/// volta. Persistita localmente, un giocatore per dispositivo.
class _PresetDadi {
  final String nome;
  final int numero;
  final int facce;
  final List<_DadoExtra> extra;
  final int modificatore;

  const _PresetDadi({
    required this.nome,
    required this.numero,
    required this.facce,
    required this.extra,
    required this.modificatore,
  });

  /// Etichetta sintetica per l'anteprima (es. "6d6" o "1d20 + 1d6 +3").
  String get etichetta {
    var s = '$numero d$facce';
    for (final e in extra) {
      s += ' + ${e.numero}d${e.facce}';
    }
    if (modificatore != 0) {
      s += ' ${modificatore > 0 ? '+' : ''}$modificatore';
    }
    return s;
  }

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'numero': numero,
    'facce': facce,
    'extra': extra.map((e) => e.toJson()).toList(),
    'modificatore': modificatore,
  };

  factory _PresetDadi.fromJson(Map<String, dynamic> json) => _PresetDadi(
    nome: json['nome'] as String? ?? '',
    numero: json['numero'] as int? ?? 1,
    facce: json['facce'] as int? ?? 20,
    extra:
        (json['extra'] as List?)
            ?.map((e) => _DadoExtra.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    modificatore: json['modificatore'] as int? ?? 0,
  );
}

/// Skin cosmetica del tiratore: colore principale (bottoni, dado
/// selezionato) e colore di sfondo. Solo estetica, nessuna meccanica.
///
/// Pensata come punto di estensione futuro: un pacchetto di skin a
/// pagamento venduto altrove potrebbe aggiungere altre voci a una mappa
/// come questa, senza dover cambiare come le skin vengono usate qui.
class DiceSkin {
  final String nome;
  final Color primario;
  final Color sfondo;

  const DiceSkin({
    required this.nome,
    required this.primario,
    required this.sfondo,
  });
}

const Map<String, DiceSkin> skinDadiDisponibili = {
  'Classico': DiceSkin(
    nome: 'Classico',
    primario: Color(0xFF8B4513),
    sfondo: Color(0xFFFAF7F2),
  ),
  'Smeraldo': DiceSkin(
    nome: 'Smeraldo',
    primario: Color(0xFF2E7D32),
    sfondo: Color(0xFFF1F8F4),
  ),
  'Notturno': DiceSkin(
    nome: 'Notturno',
    primario: Color(0xFF5E35B1),
    sfondo: Color(0xFFF3F0FA),
  ),
};

class _DiceRollerScreenState extends State<DiceRollerScreen>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();
  int _numeroDadi = 1;
  int _facceDado = 20;
  int _modificatore = 0;
  _VantaggioMode _modalita = _VantaggioMode.normale;

  List<int> _risultati = [];
  int? _altroD20; // per vantaggio/svantaggio
  final List<_RollRecord> _storico = [];

  // Dadi extra da tirare insieme al dado principale (es. 3d10 + 1d6).
  final List<_DadoExtra> _extra = [];
  List<List<int>> _risultatiExtra = [];
  int _extraNumero = 1;
  int _extraFacce = 6;

  late final AnimationController _rollController;
  Timer? _rollTimer;
  bool _rolling = false;
  int _displayTotale = 0;

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _audioAttivo = true;
  static const _prefAudio = 'dice_roller_audio_attivo';

  String _skinAttiva = 'Classico';
  static const _prefSkin = 'dice_roller_skin';

  List<_PresetDadi> _preset = [];
  static const _prefPreset = 'dice_roller_presets';

  static const _dadi = [4, 6, 8, 10, 12, 20, 100];
  static const _durataAnimazione = Duration(milliseconds: 650);

  bool get _mostraVantaggio =>
      _facceDado == 20 && _numeroDadi == 1 && _extra.isEmpty;

  DiceSkin get _skin =>
      skinDadiDisponibili[_skinAttiva] ?? skinDadiDisponibili.values.first;

  @override
  void initState() {
    super.initState();
    _rollController = AnimationController(
      vsync: this,
      duration: _durataAnimazione,
    );
    _caricaPreferenzaAudio();
    _caricaSkin();
    _caricaPreset();
  }

  Future<void> _caricaPreferenzaAudio() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _audioAttivo = prefs.getBool(_prefAudio) ?? true);
  }

  Future<void> _caricaSkin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final salvata = prefs.getString(_prefSkin);
    if (salvata != null && skinDadiDisponibili.containsKey(salvata)) {
      setState(() => _skinAttiva = salvata);
    }
  }

  Future<void> _cambiaSkin(String nome) async {
    setState(() => _skinAttiva = nome);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefSkin, nome);
  }

  Future<void> _caricaPreset() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefPreset) ?? [];
    if (!mounted) return;
    setState(() {
      _preset =
          raw
              .map(
                (s) =>
                    _PresetDadi.fromJson(jsonDecode(s) as Map<String, dynamic>),
              )
              .toList();
    });
  }

  Future<void> _salvaPresetSuStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefPreset,
      _preset.map((p) => jsonEncode(p.toJson())).toList(),
    );
  }

  void _caricaConfigurazione(_PresetDadi p) {
    setState(() {
      _numeroDadi = p.numero;
      _facceDado = p.facce;
      _extra
        ..clear()
        ..addAll(p.extra);
      _modificatore = p.modificatore;
      if (_facceDado != 20 || _numeroDadi != 1) {
        _modalita = _VantaggioMode.normale;
      }
    });
  }

  Future<void> _salvaPresetCorrente() async {
    final controller = TextEditingController();
    final nome = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Salva preset'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nome (es. "Palla di fuoco")',
              ),
              onSubmitted: (v) => Navigator.pop(context, v.trim()),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annulla'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: const Text('Salva'),
              ),
            ],
          ),
    );
    if (nome == null || nome.isEmpty) return;
    if (!mounted) return;

    setState(() {
      _preset.add(
        _PresetDadi(
          nome: nome,
          numero: _numeroDadi,
          facce: _facceDado,
          extra: List.of(_extra),
          modificatore: _modificatore,
        ),
      );
    });
    await _salvaPresetSuStorage();
  }

  Future<void> _eliminaPreset(int index) async {
    setState(() => _preset.removeAt(index));
    await _salvaPresetSuStorage();
  }

  Future<void> _toggleAudio() async {
    final nuovoValore = !_audioAttivo;
    setState(() => _audioAttivo = nuovoValore);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefAudio, nuovoValore);
  }

  Future<void> _riproduciSuono(String assetPath) async {
    if (!_audioAttivo) return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (_) {
      // L'audio è un dettaglio non essenziale: un fallimento nella
      // riproduzione (piattaforma non supportata, permessi, ecc.) non
      // deve interrompere il lancio dei dadi.
    }
  }

  @override
  void dispose() {
    _rollTimer?.cancel();
    _rollController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _aggiungiExtra() {
    setState(() => _extra.add(_DadoExtra(_extraNumero, _extraFacce)));
  }

  void _rimuoviExtra(int index) {
    setState(() => _extra.removeAt(index));
  }

  void _lanciaDadi() {
    List<int> tiri = List.generate(
      _numeroDadi,
      (_) => _random.nextInt(_facceDado) + 1,
    );
    int? altroD20;

    if (_mostraVantaggio && _modalita != _VantaggioMode.normale) {
      altroD20 = _random.nextInt(20) + 1;
      final principale = tiri[0];
      if (_modalita == _VantaggioMode.vantaggio) {
        tiri[0] = max(principale, altroD20);
      } else {
        tiri[0] = min(principale, altroD20);
      }
    }

    final risultatiExtra =
        _extra
            .map(
              (e) =>
                  List.generate(e.numero, (_) => _random.nextInt(e.facce) + 1),
            )
            .toList();

    final sommaPrimaria = tiri.fold(0, (a, b) => a + b);
    final sommaExtra = risultatiExtra.fold(
      0,
      (acc, lista) => acc + lista.fold(0, (a, b) => a + b),
    );
    final somma = sommaPrimaria + sommaExtra + _modificatore;
    final label = _buildLabel();
    final dettaglio = _buildDettaglio(tiri, altroD20, risultatiExtra);

    final maxPossibile =
        _facceDado * _numeroDadi +
        _extra.fold<int>(0, (acc, e) => acc + e.facce * e.numero);

    _rollTimer?.cancel();
    setState(() => _rolling = true);

    // Effetto "slot machine": mostra numeri casuali finché l'animazione gira.
    _rollTimer = Timer.periodic(const Duration(milliseconds: 60), (_) {
      setState(() {
        _displayTotale =
            _random.nextInt(max(maxPossibile, 1)) + 1 + _modificatore;
      });
    });

    _rollController.forward(from: 0).whenComplete(() {
      _rollTimer?.cancel();
      if (!mounted) return;
      setState(() {
        _rolling = false;
        _risultati = tiri;
        _altroD20 = altroD20;
        _risultatiExtra = risultatiExtra;
        _storico.insert(0, _RollRecord(label, somma, dettaglio));
        if (_storico.length > 10) _storico.removeLast();
      });
      if (_facceDado == 20 && tiri[0] == 20) {
        _riproduciSuono('audio/dice_crit.wav');
      } else if (_facceDado == 20 && tiri[0] == 1) {
        _riproduciSuono('audio/dice_fail.wav');
      }
    });
  }

  String _buildLabel() {
    var s = '$_numeroDadi d$_facceDado';
    for (final e in _extra) {
      s += ' + ${e.numero}d${e.facce}';
    }
    if (_modificatore != 0) {
      s += ' ${_modificatore > 0 ? '+' : ''}$_modificatore';
    }
    if (_mostraVantaggio && _modalita == _VantaggioMode.vantaggio) s += ' (V)';
    if (_mostraVantaggio && _modalita == _VantaggioMode.svantaggio) s += ' (S)';
    return s;
  }

  String _buildDettaglio(List<int> tiri, int? altro, [List<List<int>>? extra]) {
    final base =
        tiri.length == 1 && altro != null
            ? '[${tiri[0]}, $altro]'
            : '[${tiri.join(', ')}]';
    final extraStr =
        (extra ?? _risultatiExtra)
            .map((lista) => ' + [${lista.join(', ')}]')
            .join();
    return '$base$extraStr + mod$_modificatore';
  }

  int get _totale {
    if (_risultati.isEmpty) return 0;
    final sommaPrimaria = _risultati.fold(0, (a, b) => a + b);
    final sommaExtra = _risultatiExtra.fold(
      0,
      (acc, lista) => acc + lista.fold(0, (a, b) => a + b),
    );
    return sommaPrimaria + sommaExtra + _modificatore;
  }

  Color _coloreTotale() {
    if (_risultati.isEmpty) return Colors.grey;
    if (_facceDado == 20 && _risultati[0] == 20) return Colors.green.shade700;
    if (_facceDado == 20 && _risultati[0] == 1) return Colors.red.shade700;
    return _skin.primario;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _skin.sfondo,
      appBar: AppBar(
        title: const Text('Tira Dadi'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Cambia skin',
            onSelected: _cambiaSkin,
            itemBuilder:
                (context) =>
                    skinDadiDisponibili.keys.map((nome) {
                      return PopupMenuItem(
                        value: nome,
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: skinDadiDisponibili[nome]!.primario,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(nome),
                            if (nome == _skinAttiva) ...[
                              const Spacer(),
                              const Icon(Icons.check, size: 18),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
          ),
          IconButton(
            onPressed: _toggleAudio,
            icon: Icon(_audioAttivo ? Icons.volume_up : Icons.volume_off),
            tooltip: _audioAttivo ? 'Disattiva audio' : 'Attiva audio',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Preset salvati (es. "Palla di fuoco" = 6d6)
                  if (_preset.isNotEmpty) ...[
                    const Text(
                      'Preset salvati',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          _preset.asMap().entries.map((entry) {
                            final p = entry.value;
                            return InputChip(
                              label: Text('${p.nome} (${p.etichetta})'),
                              onPressed: () => _caricaConfigurazione(p),
                              onDeleted: () => _eliminaPreset(entry.key),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Selezione dado
                  const Text(
                    'Tipo di dado',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        _dadi.map((f) {
                          final sel = f == _facceDado;
                          return GestureDetector(
                            onTap:
                                () => setState(() {
                                  _facceDado = f;
                                  if (f != 20) {
                                    _modalita = _VantaggioMode.normale;
                                  }
                                }),
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: sel ? _skin.primario : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      sel
                                          ? _skin.primario
                                          : Colors.grey.shade300,
                                  width: 2,
                                ),
                                boxShadow:
                                    sel
                                        ? [
                                          BoxShadow(
                                            color: _skin.primario.withValues(
                                              alpha: 0.3,
                                            ),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                        : null,
                              ),
                              child: Center(
                                child: Text(
                                  'd$f',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: f == 100 ? 13 : 16,
                                    color: sel ? Colors.white : _skin.primario,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Numero dadi + modificatore
                  Row(
                    children: [
                      // Numero dadi
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'N° dadi',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _iconBtn(Icons.remove, () {
                                  if (_numeroDadi > 1) {
                                    setState(() => _numeroDadi--);
                                  }
                                }),
                                const SizedBox(width: 8),
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$_numeroDadi',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _iconBtn(Icons.add, () {
                                  if (_numeroDadi < 20) {
                                    setState(() => _numeroDadi++);
                                  }
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Modificatore
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Modificatore',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _iconBtn(
                                  Icons.remove,
                                  () => setState(() => _modificatore--),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 52,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${_modificatore >= 0 ? '+' : ''}$_modificatore',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            _modificatore > 0
                                                ? Colors.green.shade700
                                                : _modificatore < 0
                                                ? Colors.red.shade700
                                                : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _iconBtn(
                                  Icons.add,
                                  () => setState(() => _modificatore++),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Dadi extra (es. 3d10 + 1d6, tirati insieme)
                  const SizedBox(height: 20),
                  const Text(
                    'Dadi extra (opzionale)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _iconBtn(Icons.remove, () {
                        if (_extraNumero > 1) {
                          setState(() => _extraNumero--);
                        }
                      }),
                      const SizedBox(width: 8),
                      Container(
                        width: 40,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$_extraNumero',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _iconBtn(Icons.add, () {
                        if (_extraNumero < 20) {
                          setState(() => _extraNumero++);
                        }
                      }),
                      const SizedBox(width: 12),
                      DropdownButton<int>(
                        value: _extraFacce,
                        items:
                            _dadi
                                .map(
                                  (f) => DropdownMenuItem(
                                    value: f,
                                    child: Text('d$f'),
                                  ),
                                )
                                .toList(),
                        onChanged: (f) {
                          if (f != null) setState(() => _extraFacce = f);
                        },
                      ),
                      const SizedBox(width: 12),
                      TextButton.icon(
                        onPressed: _aggiungiExtra,
                        icon: const Icon(Icons.add_circle_outline, size: 18),
                        label: const Text('Aggiungi'),
                      ),
                    ],
                  ),
                  if (_extra.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          _extra.asMap().entries.map((entry) {
                            final e = entry.value;
                            return Chip(
                              label: Text('${e.numero}d${e.facce}'),
                              onDeleted: () => _rimuoviExtra(entry.key),
                            );
                          }).toList(),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _salvaPresetCorrente,
                      icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                      label: const Text('Salva come preset'),
                    ),
                  ),

                  // Vantaggio/Svantaggio (solo d20 x1, senza dadi extra)
                  if (_mostraVantaggio) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Modalità (solo 1d20)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _modoBtn(
                          'Normale',
                          _VantaggioMode.normale,
                          Colors.grey.shade700,
                        ),
                        const SizedBox(width: 8),
                        _modoBtn(
                          'Vantaggio',
                          _VantaggioMode.vantaggio,
                          Colors.green.shade700,
                        ),
                        const SizedBox(width: 8),
                        _modoBtn(
                          'Svantaggio',
                          _VantaggioMode.svantaggio,
                          Colors.red.shade700,
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Bottone lancia
                  SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _rolling ? null : _lanciaDadi,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _skin.primario,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Text('🎲', style: TextStyle(fontSize: 22)),
                      label: Text(
                        'Lancia $_numeroDadi d$_facceDado'
                        '${_extra.map((e) => ' + ${e.numero}d${e.facce}').join()}'
                        '${_modificatore != 0 ? ' ${_modificatore > 0 ? '+' : ''}$_modificatore' : ''}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Risultato principale
                  if (_risultati.isNotEmpty || _rolling) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              _rolling
                                  ? Colors.grey.shade300
                                  : _coloreTotale().withValues(alpha: 0.4),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Critico/Fallimento critico
                          if (!_rolling &&
                              _facceDado == 20 &&
                              _risultati[0] == 20)
                            const Text(
                              '🎯 COLPO CRITICO!',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          if (!_rolling &&
                              _facceDado == 20 &&
                              _risultati[0] == 1)
                            const Text(
                              '💀 FALLIMENTO CRITICO',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          AnimatedBuilder(
                            animation: _rollController,
                            builder: (context, child) {
                              final angolo =
                                  _rolling
                                      ? sin(_rollController.value * pi * 8) *
                                          0.15
                                      : 0.0;
                              return Transform.rotate(
                                angle: angolo,
                                child: child,
                              );
                            },
                            child: Text(
                              '${_rolling ? _displayTotale : _totale}',
                              style: TextStyle(
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                                color:
                                    _rolling
                                        ? Colors.grey.shade400
                                        : _coloreTotale(),
                                height: 1.1,
                              ),
                            ),
                          ),
                          // Breakdown
                          Text(
                            _rolling
                                ? 'Tiro in corso...'
                                : _buildDettaglio(_risultati, _altroD20),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (!_rolling &&
                              _mostraVantaggio &&
                              _modalita != _VantaggioMode.normale &&
                              _altroD20 != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                _modalita == _VantaggioMode.vantaggio
                                    ? 'Vantaggio: tieni il massimo'
                                    : 'Svantaggio: tieni il minimo',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      _modalita == _VantaggioMode.vantaggio
                                          ? Colors.green.shade600
                                          : Colors.red.shade600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],

                  // Storico
                  if (_storico.length > 1) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          'Storico lanci',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed:
                              () => setState(() {
                                _storico.clear();
                                _risultati.clear();
                              }),
                          child: const Text(
                            'Cancella',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ...(_storico
                        .skip(1)
                        .map(
                          (r) => Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  r.label,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  r.dettaglio,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${r.totale}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _skin.primario,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ],

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Icon(icon, size: 18, color: Colors.grey.shade700),
    ),
  );

  Widget _modoBtn(String label, _VantaggioMode mode, Color color) {
    final sel = _modalita == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _modalita = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: sel ? color.withValues(alpha: 0.12) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: sel ? color : Colors.grey.shade300,
              width: sel ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: sel ? FontWeight.bold : FontWeight.normal,
              color: sel ? color : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}
