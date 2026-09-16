import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _notReady(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Esta función se implementará en una próxima clase.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            minVerticalPadding: 16,
            leading: const Icon(Icons.shield_outlined),
            title: const Text('Estado de protección'),
            subtitle: const Text('Configuración pendiente'),
            onTap: () => _notReady(context),
          ),
          ListTile(
            minVerticalPadding: 16,
            leading: const Icon(Icons.delete_outline),
            title: const Text('Borrar historial'),
            subtitle: const Text(
              'El historial local todavía no está habilitado',
            ),
            onTap: () => _notReady(context),
          ),
          const AboutListTile(
            icon: Icon(Icons.info_outline),
            applicationName: 'ProtegeLink',
            applicationVersion: '0.1.0',
            applicationLegalese: 'Proyecto académico y educativo.',
          ),
        ],
      ),
    );
  }
}
