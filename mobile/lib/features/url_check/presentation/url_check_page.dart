import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:protegelink/core/platform/shared_link_service.dart';
import 'package:protegelink/core/utils/url_validator.dart';
import 'package:protegelink/features/url_check/presentation/url_check_controller.dart';

class UrlCheckPage extends ConsumerStatefulWidget {
  const UrlCheckPage({this.incomingShare, super.key});

  final IncomingShare? incomingShare;

  @override
  ConsumerState<UrlCheckPage> createState() => _UrlCheckPageState();
}

class _UrlCheckPageState extends ConsumerState<UrlCheckPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  String? _incomingMessage;

  @override
  void initState() {
    super.initState();
    _applyIncomingShare(widget.incomingShare);
  }

  @override
  void didUpdateWidget(covariant UrlCheckPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.incomingShare != widget.incomingShare) {
      _applyIncomingShare(widget.incomingShare);
    }
  }

  void _applyIncomingShare(IncomingShare? share) {
    if (share == null) return;
    _controller.text = share.url ?? '';
    _incomingMessage = share.message;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    if (ref.read(urlCheckControllerProvider).isLoading) return;
    if (!_formKey.currentState!.validate()) return;
    final normalizedUrl = normalizeUrlInput(_controller.text);
    _controller.text = normalizedUrl;
    final result = await ref
        .read(urlCheckControllerProvider.notifier)
        .analyze(normalizedUrl);
    if (result != null && mounted) context.push('/result', extra: result);
  }

  Future<void> _pasteUrl() async {
    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    final text = clipboard?.text;
    if (text == null || text.trim().isEmpty) {
      setState(() => _incomingMessage = 'El portapapeles no contiene texto.');
      return;
    }
    setState(() {
      _controller.text = normalizeUrlInput(text);
      _controller.selection =
          TextSelection.collapsed(offset: _controller.text.length);
      _incomingMessage = null;
    });
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
                onChanged: (_) {
                  if (_incomingMessage != null) {
                    setState(() => _incomingMessage = null);
                  }
                },
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
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: state.isLoading ? null : _pasteUrl,
                icon: const Icon(Icons.content_paste),
                label: const Text('Pegar enlace'),
              ),
              if (_incomingMessage != null) ...[
                const SizedBox(height: 16),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _incomingMessage!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: state.isLoading ? null : _analyze,
                icon: state.isLoading
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.shield_outlined),
                label: Text(
                  state.isLoading
                      ? 'Estamos revisando este enlace...'
                      : 'Revisar enlace',
                ),
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
