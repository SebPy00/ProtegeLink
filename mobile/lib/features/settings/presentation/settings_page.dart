import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:protegelink/core/constants/app_config.dart';
import 'package:protegelink/core/platform/shared_link_service.dart';
import 'package:protegelink/core/preferences/backend_preferences.dart';
import 'package:protegelink/core/utils/url_validator.dart';
import 'package:protegelink/features/history/presentation/history_providers.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _backendPreferences = BackendPreferences();
  String _apiBaseUrl = AppConfig.apiBaseUrl;

  @override
  void initState() {
    super.initState();
    _loadApiBaseUrl();
  }

  Future<void> _loadApiBaseUrl() async {
    final value = await _backendPreferences.getApiBaseUrl();
    if (mounted) setState(() => _apiBaseUrl = value);
  }

  @override
  Widget build(BuildContext context) {
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
            leading: const Icon(Icons.dns_outlined),
            title: const Text('Dirección del backend'),
            subtitle: Text(_apiBaseUrl),
            trailing: const Icon(Icons.edit_outlined),
            onTap: _editApiBaseUrl,
          ),
          ListTile(
            minVerticalPadding: 16,
            leading: const Icon(Icons.open_in_browser),
            title: const Text('Usar ProtegeLink para abrir enlaces'),
            subtitle: const Text(
              'Abrir la configuración de aplicaciones predeterminadas',
            ),
            onTap: _openLinkSettings,
          ),
          ListTile(
            minVerticalPadding: 16,
            leading: const Icon(Icons.delete_outline),
            title: const Text('Borrar historial'),
            subtitle: const Text(
              'Eliminar los análisis guardados en este teléfono',
            ),
            onTap: _confirmDeleteHistory,
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
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
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

  Future<void> _editApiBaseUrl() async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController(text: _apiBaseUrl);

    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dirección del backend'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ingresá la IP de la notebook en la red compartida y el puerto 8000.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.url,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'URL del backend',
                  hintText: 'http://192.168.100.72:8000',
                ),
                validator: validateHttpUrl,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(AppConfig.apiBaseUrl),
            child: const Text('Usar predeterminada'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(
                  normalizeUrlInput(controller.text),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (value == null || !mounted) return;
    if (value == AppConfig.apiBaseUrl) {
      await _backendPreferences.resetApiBaseUrl();
    } else {
      await _backendPreferences.setApiBaseUrl(value);
    }
    if (!mounted) return;
    setState(() => _apiBaseUrl = value);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('La dirección se guardó para los próximos análisis.'),
      ),
    );
  }

  Future<void> _openLinkSettings() async {
    final opened = await SharedLinkService.instance.openLinkSettings();
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No pudimos abrir la configuración de Android.'),
        ),
      );
    }
  }

  Future<void> _confirmDeleteHistory() async {
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
    if (confirmed != true || !mounted) return;

    try {
      await ref.read(historyRepositoryProvider).deleteAll();
      ref.invalidate(historyAnalysesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El historial fue eliminado.')),
        );
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No pudimos borrar el historial. Intentá nuevamente.',
            ),
          ),
        );
      }
    }
  }
}
