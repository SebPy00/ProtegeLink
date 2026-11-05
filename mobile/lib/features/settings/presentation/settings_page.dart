import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:protegelink/core/platform/shared_link_service.dart';
import 'package:protegelink/features/history/presentation/history_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            minVerticalPadding: 16,
            leading: Icon(Icons.shield_outlined),
            title: Text('Estado de protección'),
            subtitle: Text('Protección activa'),
          ),
          ListTile(
            minVerticalPadding: 16,
            leading: const Icon(Icons.open_in_browser),
            title: const Text('Usar ProtegeLink para abrir enlaces'),
            subtitle: const Text(
                'Abrir la configuración de aplicaciones predeterminadas'),
            onTap: () => _openLinkSettings(context),
          ),
          ListTile(
            minVerticalPadding: 16,
            leading: const Icon(Icons.delete_outline),
            title: const Text('Borrar historial'),
            subtitle:
                const Text('Eliminar los análisis guardados en este teléfono'),
            onTap: () => _confirmDeleteHistory(context, ref),
          ),
          const AboutListTile(
            icon: Icon(Icons.info_outline),
            applicationName: 'ProtegeLink',
            applicationVersion: '0.1.0',
            applicationLegalese: 'Proyecto académico y educativo.',
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'ProtegeLink es una herramienta de apoyo y no puede garantizar la detección de todas las amenazas.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openLinkSettings(BuildContext context) async {
    final opened = await SharedLinkService.instance.openLinkSettings();
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No pudimos abrir la configuración de Android.'),
        ),
      );
    }
  }

  Future<void> _confirmDeleteHistory(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar todo el historial?'),
        content: const Text(
          'Esta acción eliminará todos los análisis guardados en el teléfono.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(historyRepositoryProvider).deleteAll();
      ref.invalidate(historyAnalysesProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El historial fue eliminado.')),
        );
      }
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('No pudimos borrar el historial. Intentá nuevamente.'),
          ),
        );
      }
    }
  }
}
