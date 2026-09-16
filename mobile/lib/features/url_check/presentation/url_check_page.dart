import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:protegelink/core/utils/url_validator.dart';
import 'package:protegelink/features/url_check/presentation/url_check_controller.dart';

class UrlCheckPage extends ConsumerStatefulWidget {
  const UrlCheckPage({super.key});

  @override
  ConsumerState<UrlCheckPage> createState() => _UrlCheckPageState();
}

class _UrlCheckPageState extends ConsumerState<UrlCheckPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    if (!_formKey.currentState!.validate()) return;
    final result = await ref
        .read(urlCheckControllerProvider.notifier)
        .analyze(_controller.text.trim());
    if (result != null && mounted) context.push('/result', extra: result);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(urlCheckControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Revisar un enlace')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pegá la dirección completa del sitio que querés revisar.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _controller,
                keyboardType: TextInputType.url,
                autocorrect: false,
                enableSuggestions: false,
                decoration: const InputDecoration(
                  labelText: 'Enlace',
                  hintText: 'https://ejemplo.com',
                  prefixIcon: Icon(Icons.link),
                ),
                validator: validateHttpUrl,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: state.isLoading ? null : _analyze,
                icon: state.isLoading
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.shield_outlined),
                label: Text(state.isLoading ? 'Revisando…' : 'Revisar enlace'),
              ),
              if (state.hasError) ...[
                const SizedBox(height: 20),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    state.error.toString(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
