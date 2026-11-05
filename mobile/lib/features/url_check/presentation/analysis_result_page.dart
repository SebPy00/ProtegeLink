import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:protegelink/features/url_check/domain/url_analysis.dart';
import 'package:protegelink/features/url_check/presentation/analysis_reason_translator.dart';
import 'package:protegelink/features/url_check/presentation/analysis_status_card.dart';

class AnalysisResultPage extends StatelessWidget {
  const AnalysisResultPage({required this.analysis, super.key});

  final UrlAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultado del análisis')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          AnalysisStatusCard(analysis: analysis),
          const SizedBox(height: 16),
          SelectableText(
            analysis.domain,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            'Puntaje orientativo: ${analysis.riskScore} de 100',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          Text('Motivos', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (analysis.reasons.isEmpty)
            const Text('No se detectaron señales heurísticas de riesgo.')
          else
            ...analysis.reasons.map(
              (reason) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.info_outline),
                title: Text(translateAnalysisReason(reason)),
              ),
            ),
          const SizedBox(height: 20),
          ..._actions(context),
        ],
      ),
    );
  }

  List<Widget> _actions(BuildContext context) {
    switch (analysis.status) {
      case AnalysisStatus.safe:
        return [
          FilledButton.icon(
            onPressed: () => context.push('/browser', extra: analysis),
            icon: const Icon(Icons.open_in_browser),
            label: const Text('Abrir sitio'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _goBack(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Volver'),
          ),
        ];
      case AnalysisStatus.suspicious:
        return [
          FilledButton.icon(
            onPressed: () => _goBack(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Volver'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _showDetails(context),
            icon: const Icon(Icons.info_outline),
            label: const Text('Ver detalles'),
          ),
        ];
      case AnalysisStatus.dangerous:
        return [
          FilledButton.icon(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.home_outlined),
            label: const Text('Volver a un lugar seguro'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _showDetails(context),
            icon: const Icon(Icons.info_outline),
            label: const Text('Ver detalles'),
          ),
        ];
    }
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Detalles del análisis',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Text('Dirección', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              SelectableText(analysis.url),
              const SizedBox(height: 16),
              Text(
                'Puntaje orientativo: ${analysis.riskScore} de 100',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'Este puntaje combina señales sencillas y no garantiza que un sitio sea legítimo o fraudulento.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
