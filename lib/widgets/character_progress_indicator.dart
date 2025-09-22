import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/character_provider.dart';

class CharacterProgressIndicator extends StatelessWidget {
  const CharacterProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CharacterProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Titolo dello step corrente
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                provider.getStepTitle(provider.currentStep),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Barra di progresso
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: provider.progress,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Step ${provider.currentStep.index + 1} di ${CharacterCreationStep.values.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            // Indicatore modifiche non salvate
            if (provider.hasUnsavedChanges)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit, size: 16, color: Colors.orange),
                    SizedBox(width: 4),
                    Text(
                      'Modifiche non salvate',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

            // Indicatore di loading
            if (provider.isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: SizedBox(
                  height: 2,
                  child: LinearProgressIndicator(),
                ),
              ),
          ],
        );
      },
    );
  }
}