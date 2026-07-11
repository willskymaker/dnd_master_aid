import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../factory_pg_base.dart';
import '../widgets/mobile/mobile_scaffold.dart';
import 'dart:math'; // ✅ IMPORTA Random

class NameGeneratorScreen extends StatefulWidget {
  final PGBaseFactory factory;

  const NameGeneratorScreen({super.key, required this.factory});

  @override
  State<NameGeneratorScreen> createState() => _NameGeneratorScreenState();
}

class _NameGeneratorScreenState extends State<NameGeneratorScreen> {
  final _random = Random();
  final _prefissi = [
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
  final _suffissi = [
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
  final _cognomi = [
    "Ombrafuoco",
    "Cuorepuro",
    "Ventoargenteo",
    "Dentedrago",
    "Manoferma",
    "Cuoreardente",
    "Pietralama",
    "Lunargento",
    "Denteombra",
    "Ferroduro",
    "Ambrato",
    "Mordiroccia",
  ];

  String _nomeGenerato = "";

  void _generaNome() {
    final nome =
        _prefissi[_random.nextInt(_prefissi.length)] +
        _suffissi[_random.nextInt(_suffissi.length)];
    final cognome = _cognomi[_random.nextInt(_cognomi.length)];

    final nomeCompleto = "$nome $cognome";
    widget.factory.setNome(nomeCompleto); // ✅ salva direttamente nella factory

    setState(() {
      _nomeGenerato = nomeCompleto;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MobileScaffold(
      title: "Generatore di Nomi",
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
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
