import 'package:flutter/material.dart';
import 'package:protegelink/features/url_check/domain/url_analysis.dart';

class AnalysisStatusCard extends StatelessWidget {
  const AnalysisStatusCard({required this.analysis, super.key});

  final UrlAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final presentation = _presentationFor(analysis.status);
    return Semantics(
      label: 'Resultado: ${presentation.label}',
      child: Card(
        color: presentation.background,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(presentation.icon, size: 72, color: presentation.foreground),
              const SizedBox(height: 16),
              Text(
                presentation.label,
                key: ValueKey('status-${analysis.status.name}'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: presentation.foreground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                presentation.message,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: presentation.foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

_StatusPresentation _presentationFor(AnalysisStatus status) => switch (status) {
  AnalysisStatus.safe => const _StatusPresentation(
    label: 'SEGURO',
    message:
        'No encontramos señales de riesgo conocidas. Aun así, navegá con atención.',
    icon: Icons.verified_user_outlined,
    background: Color(0xFFD1FAE5),
    foreground: Color(0xFF065F46),
  ),
  AnalysisStatus.suspicious => const _StatusPresentation(
    label: 'SOSPECHOSO',
    message: 'Encontramos señales que conviene revisar antes de continuar.',
    icon: Icons.warning_amber_rounded,
    background: Color(0xFFFEF3C7),
    foreground: Color(0xFF78350F),
  ),
  AnalysisStatus.dangerous => const _StatusPresentation(
    label: 'PELIGROSO',
    message: 'Este enlace fue bloqueado para protegerte. No lo abras.',
    icon: Icons.gpp_bad_outlined,
    background: Color(0xFFFEE2E2),
    foreground: Color(0xFF991B1B),
  ),
};

class _StatusPresentation {
  const _StatusPresentation({
    required this.label,
    required this.message,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String label;
  final String message;
  final IconData icon;
  final Color background;
  final Color foreground;
}
