import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../factory_pg_base.dart';
import '../../widgets/mobile/mobile_scaffold.dart';

class StepLivelloScreen extends StatefulWidget {
  final PGBaseFactory factory;

  const StepLivelloScreen({super.key, required this.factory});

  @override
  State<StepLivelloScreen> createState() => _StepLivelloScreenState();
}

class _StepLivelloScreenState extends State<StepLivelloScreen> {
  int? livelloSelezionato;

  void _conferma() {
    if (livelloSelezionato == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Seleziona un livello prima di continuare."),
        ),
      );
      return;
    }

    widget.factory.setLivello(livelloSelezionato!);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return MobileScaffold(
      title: "Step: Seleziona il Livello",
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Text(
              "Scegli il livello iniziale del personaggio",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            DropdownButton<int>(
              hint: const Text("Livello"),
              value: livelloSelezionato,
              onChanged: (val) {
                setState(() {
                  livelloSelezionato = val;
                });
              },
              items: List.generate(
                20,
                (index) => DropdownMenuItem(
                  value: index + 1,
                  child: Text("Livello ${index + 1}"),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _conferma,
              child: const Text("Conferma Livello"),
            ),
          ],
        ),
      ),
    );
  }
}
