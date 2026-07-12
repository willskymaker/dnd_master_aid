import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../data/db_nomi.dart';
import '../factory_pg_base.dart';
import '../widgets/mobile/mobile_scaffold.dart';
import 'dart:math'; // ✅ IMPORTA Random

enum _Genere { maschio, femmina }

class NameGeneratorScreen extends StatefulWidget {
  final PGBaseFactory factory;

  const NameGeneratorScreen({super.key, required this.factory});

  @override
  State<NameGeneratorScreen> createState() => _NameGeneratorScreenState();
}

class _NameGeneratorScreenState extends State<NameGeneratorScreen> {
  final _random = Random();
  _Genere _genere = _Genere.maschio;

  // Sillabe generiche, usate solo se la specie non e' ancora nel database
  // dei nomi (lib/data/db_nomi.dart copre le 9 specie base del wizard).
  static const _prefissiGenerici = [
    "El",
    "Fa",
    "Al",
    "Thar",
    "Mor",
    "Gla",
    "Ka",
    "Thal",
    "Zan",
    "Dan",
    "Den",
    "Gul",
    "Gor",
    "An",
    "Der",
    "Bel",
  ];
  static const _suffissiGenerici = [
    "dor",
    "ion",
    "mir",
    "rien",
    "dil",
    "gar",
    "gon",
    "ril",
    "eth",
    "las",
    "ent",
    "gil",
    "fil",
  ];
  static const _cognomiGenerici = [
    "Ombrafuoco",
    "Cuorepuro",
    "Ventoargenteo",
    "Dentedrago",
    "Manoferma",
    "Cuoreardente",
    "Pietralama",
    "Lunargento",
  ];

  String _nomeGenerato = "";

  String get _specie => widget.factory.build().specie;

  void _generaNome() {
    final nomiSpecie = nomiPerSpecie[_specie];
    String nomeCompleto;

    if (nomiSpecie != null) {
      final lista =
          _genere == _Genere.maschio
              ? nomiSpecie.maschili
              : nomiSpecie.femminili;
      final nome =
          lista.isNotEmpty
              ? lista[_random.nextInt(lista.length)]
              : _generaNomeGenerico();
      nomeCompleto =
          nomiSpecie.cognomi.isNotEmpty
              ? '$nome ${nomiSpecie.cognomi[_random.nextInt(nomiSpecie.cognomi.length)]}'
              : nome;
    } else {
      nomeCompleto =
          '${_generaNomeGenerico()} ${_cognomiGenerici[_random.nextInt(_cognomiGenerici.length)]}';
    }

    widget.factory.setNome(nomeCompleto); // ✅ salva direttamente nella factory

    setState(() {
      _nomeGenerato = nomeCompleto;
    });
  }

  String _generaNomeGenerico() =>
      _prefissiGenerici[_random.nextInt(_prefissiGenerici.length)] +
      _suffissiGenerici[_random.nextInt(_suffissiGenerici.length)];

  @override
  Widget build(BuildContext context) {
    final specie = _specie;
    final haNomiSpecifici = nomiPerSpecie.containsKey(specie);

    return MobileScaffold(
      title: "Generatore di Nomi",
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Text(
              specie.isEmpty
                  ? 'Nessuna specie selezionata: nomi generici'
                  : haNomiSpecifici
                  ? 'Nomi per: $specie'
                  : 'Nomi generici (nessun elenco specifico per $specie)',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            SegmentedButton<_Genere>(
              segments: const [
                ButtonSegment(value: _Genere.maschio, label: Text('Maschile')),
                ButtonSegment(value: _Genere.femmina, label: Text('Femminile')),
              ],
              selected: {_genere},
              onSelectionChanged: (sel) => setState(() => _genere = sel.first),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              _nomeGenerato.isEmpty ? "Premi per generare" : _nomeGenerato,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: _generaNome,
              icon: const Icon(Icons.casino),
              label: const Text("Genera Nome"),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed:
                  _nomeGenerato.isEmpty
                      ? null
                      : () => Navigator.pop(context, true),
              icon: const Icon(Icons.check),
              label: const Text("Conferma nome e continua"),
            ),
          ],
        ),
      ),
    );
  }
}
