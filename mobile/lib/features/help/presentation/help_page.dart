import 'package:flutter/material.dart';
import 'package:protegelink/features/help/presentation/help_content.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayuda')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Consejos para cuidarte',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          ...phishingTips.map(
            (tip) => Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(20),
                leading: const Icon(Icons.lightbulb_outline, size: 36),
                title: Text(tip.title),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(tip.description),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
