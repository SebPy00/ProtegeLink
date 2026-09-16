import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:protegelink/features/url_check/domain/url_analysis.dart';
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
                title: Text(reason),
              ),
            ),
          const SizedBox(height: 20),
          if (analysis.status == AnalysisStatus.safe)
            FilledButton.icon(
              onPressed: () => context.push('/browser', extra: analysis),
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Abrir sitio'),
            )
          else
            FilledButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.home_outlined),
              label: const Text('Volver a un lugar seguro'),
            ),
        ],
      ),
    );
  }
}
