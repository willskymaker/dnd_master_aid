import 'package:flutter/material.dart';
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

class _DiceRollerScreenState extends State<DiceRollerScreen> {
  final Random _random = Random();
  int _numeroDadi = 1;
  int _facceDado = 20;
  int _modificatore = 0;
  _VantaggioMode _modalita = _VantaggioMode.normale;

  List<int> _risultati = [];
  int? _altroD20; // per vantaggio/svantaggio
  final List<_RollRecord> _storico = [];

  static const _dadi = [4, 6, 8, 10, 12, 20, 100];

  bool get _mostraVantaggio => _facceDado == 20 && _numeroDadi == 1;

  void _lanciaDadi() {
    List<int> tiri = List.generate(_numeroDadi, (_) => _random.nextInt(_facceDado) + 1);
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

    final somma = tiri.fold(0, (a, b) => a + b) + _modificatore;
    final label = _buildLabel();
    final dettaglio = _buildDettaglio(tiri, altroD20);

    setState(() {
      _risultati = tiri;
      _altroD20 = altroD20;
      _storico.insert(0, _RollRecord(label, somma, dettaglio));
      if (_storico.length > 10) _storico.removeLast();
    });
  }

  String _buildLabel() {
    var s = '$_numeroDadi d$_facceDado';
    if (_modificatore != 0) s += ' ${_modificatore > 0 ? '+' : ''}$_modificatore';
    if (_mostraVantaggio && _modalita == _VantaggioMode.vantaggio) s += ' (V)';
    if (_mostraVantaggio && _modalita == _VantaggioMode.svantaggio) s += ' (S)';
    return s;
  }

  String _buildDettaglio(List<int> tiri, int? altro) {
    if (tiri.length == 1 && altro != null) {
      return '[${tiri[0]}, $altro] + mod$_modificatore';
    }
    return '[${tiri.join(', ')}] + mod$_modificatore';
  }

  int get _totale => _risultati.isEmpty ? 0 : _risultati.fold(0, (a, b) => a + b) + _modificatore;

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
                  const Text('Tipo di dado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _dadi.map((f) {
                      final sel = f == _facceDado;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _facceDado = f;
                          if (f != 20) _modalita = _VantaggioMode.normale;
                        }),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: sel ? const Color(0xFF8B4513) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: sel ? const Color(0xFF8B4513) : Colors.grey.shade300,
                              width: 2,
                            ),
                            boxShadow: sel ? [BoxShadow(color: const Color(0xFF8B4513).withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))] : null,
                          ),
                          child: Center(
                            child: Text(
                              'd$f',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: f == 100 ? 13 : 16,
                                color: sel ? Colors.white : const Color(0xFF8B4513),
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
                            const Text('N° dadi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _iconBtn(Icons.remove, () {
                                  if (_numeroDadi > 1) setState(() => _numeroDadi--);
                                }),
                                const SizedBox(width: 8),
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text('$_numeroDadi', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _iconBtn(Icons.add, () {
                                  if (_numeroDadi < 20) setState(() => _numeroDadi++);
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
                            const Text('Modificatore', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _iconBtn(Icons.remove, () => setState(() => _modificatore--)),
                                const SizedBox(width: 8),
                                Container(
                                  width: 52,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${_modificatore >= 0 ? '+' : ''}$_modificatore',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: _modificatore > 0 ? Colors.green.shade700 : _modificatore < 0 ? Colors.red.shade700 : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _iconBtn(Icons.add, () => setState(() => _modificatore++)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Vantaggio/Svantaggio (solo d20 x1)
                  if (_mostraVantaggio) ...[
                    const SizedBox(height: 20),
                    const Text('Modalità (solo 1d20)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _modoBtn('Normale', _VantaggioMode.normale, Colors.grey.shade700),
                        const SizedBox(width: 8),
                        _modoBtn('Vantaggio', _VantaggioMode.vantaggio, Colors.green.shade700),
                        const SizedBox(width: 8),
                        _modoBtn('Svantaggio', _VantaggioMode.svantaggio, Colors.red.shade700),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Bottone lancia
                  SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _lanciaDadi,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B4513),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Text('🎲', style: TextStyle(fontSize: 22)),
                      label: Text(
                        'Lancia $_numeroDadi d$_facceDado${_modificatore != 0 ? ' ${_modificatore > 0 ? '+' : ''}$_modificatore' : ''}',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  // Risultato principale
                  if (_risultati.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _coloreTotale().withOpacity(0.4), width: 2),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                      ),
                      child: Column(
                        children: [
                          // Critico/Fallimento critico
                          if (_facceDado == 20 && _risultati[0] == 20)
                            const Text('🎯 COLPO CRITICO!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                          if (_facceDado == 20 && _risultati[0] == 1)
                            const Text('💀 FALLIMENTO CRITICO', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(
                            '$_totale',
                            style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: _coloreTotale(), height: 1.1),
                          ),
                          // Breakdown
                          Text(
                            _buildDettaglio(_risultati, _altroD20),
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                          if (_mostraVantaggio && _modalita != _VantaggioMode.normale && _altroD20 != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                _modalita == _VantaggioMode.vantaggio ? 'Vantaggio: tieni il massimo' : 'Svantaggio: tieni il minimo',
                                style: TextStyle(fontSize: 12, color: _modalita == _VantaggioMode.vantaggio ? Colors.green.shade600 : Colors.red.shade600),
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
                        const Text('Storico lanci', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                        const Spacer(),
                        TextButton(
                          onPressed: () => setState(() { _storico.clear(); _risultati.clear(); }),
                          child: const Text('Cancella', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ...(_storico.skip(1).map((r) => Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Text(r.label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                          const Spacer(),
                          Text(r.dettaglio, style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                          const SizedBox(width: 12),
                          Text('${r.totale}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF8B4513))),
                        ],
                      ),
                    ))),
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
            color: sel ? color.withOpacity(0.12) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: sel ? color : Colors.grey.shade300, width: sel ? 2 : 1),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontWeight: sel ? FontWeight.bold : FontWeight.normal, color: sel ? color : Colors.grey.shade700),
          ),
        ),
      ),
    );
  }
}
