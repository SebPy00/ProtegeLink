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
          Text(
            'Protección de enlaces',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Revisá enlaces antes de abrirlos y detectá posibles señales de fraude.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(20),
              leading: Icon(
                Icons.shield_outlined,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Protección activa'),
              subtitle: const Text('Lista para revisar enlaces'),
            ),
          ),
          const SizedBox(height: 32),
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
            label: const Text('Consejos'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
            label: const Text('Configuración'),
          ),
        ],
      ),
    );
  }
}
