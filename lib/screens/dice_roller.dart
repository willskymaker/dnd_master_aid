import 'package:flutter/material.dart';
import 'dart:async';
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
}

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

  static const _dadi = [4, 6, 8, 10, 12, 20, 100];
  static const _durataAnimazione = Duration(milliseconds: 650);

  bool get _mostraVantaggio =>
      _facceDado == 20 && _numeroDadi == 1 && _extra.isEmpty;

  @override
  void initState() {
    super.initState();
    _rollController = AnimationController(
      vsync: this,
      duration: _durataAnimazione,
    );
  }

  @override
  void dispose() {
    _rollTimer?.cancel();
    _rollController.dispose();
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
    return const Color(0xFF8B4513);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(title: const Text('Tira Dadi')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                                color:
                                    sel
                                        ? const Color(0xFF8B4513)
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      sel
                                          ? const Color(0xFF8B4513)
                                          : Colors.grey.shade300,
                                  width: 2,
                                ),
                                boxShadow:
                                    sel
                                        ? [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF8B4513,
                                            ).withValues(alpha: 0.3),
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
                                    color:
                                        sel
                                            ? Colors.white
                                            : const Color(0xFF8B4513),
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
                        backgroundColor: const Color(0xFF8B4513),
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
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF8B4513),
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
