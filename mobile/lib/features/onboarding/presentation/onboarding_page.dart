import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:protegelink/features/onboarding/data/onboarding_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  bool _saving = false;

  Future<void> _start() async {
    setState(() => _saving = true);
    await OnboardingPreferences().markCompleted();
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: constraints.maxHeight - 64),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 96,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Bienvenido a ProtegeLink',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'ProtegeLink te ayuda a revisar enlaces antes de abrirlos.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  const _OnboardingPoint(
                    icon: Icons.search,
                    text: 'Revisa la dirección antes de abrirla.',
                  ),
                  const SizedBox(height: 12),
                  const _OnboardingPoint(
                    icon: Icons.warning_amber_rounded,
                    text:
                        'Advierte cuando encuentra posibles señales de riesgo.',
                  ),
                  const SizedBox(height: 12),
                  const _OnboardingPoint(
                    icon: Icons.info_outline,
                    text:
                        'No puede garantizar la detección de todas las amenazas.',
                  ),
                  const SizedBox(height: 40),
                  FilledButton.icon(
                    onPressed: _saving ? null : _start,
                    icon: _saving
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.arrow_forward),
                    label: const Text('Comenzar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingPoint extends StatelessWidget {
  const _OnboardingPoint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
      ],
    );
  }
}
