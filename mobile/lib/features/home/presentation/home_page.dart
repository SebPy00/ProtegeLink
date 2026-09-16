import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ProtegeLink'),
        actions: [
          IconButton(
            tooltip: 'Configuración',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Protección', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Configuración pendiente',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push('/check'),
            icon: const Icon(Icons.link),
            label: const Text('Revisar un enlace'),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => context.go('/history'),
            icon: const Icon(Icons.history),
            label: const Text('Ver historial'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.go('/help'),
            icon: const Icon(Icons.help_outline),
            label: const Text('Consejos y ayuda'),
          ),
        ],
      ),
    );
  }
}
