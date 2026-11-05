import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:protegelink/features/history/presentation/history_providers.dart';
import 'package:protegelink/features/url_check/domain/url_analysis.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyAnalysesProvider);
    final hasEntries = history.asData?.value.isNotEmpty ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        actions: [
          if (hasEntries)
            IconButton(
              tooltip: 'Borrar historial',
              onPressed: () => _confirmDelete(context, ref),
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _HistoryError(
          onRetry: () => ref.invalidate(historyAnalysesProvider),
        ),
        data: (analyses) {
          if (analyses.isEmpty) return const _EmptyHistory();
          return RefreshIndicator(
            onRefresh: () => ref.refresh(historyAnalysesProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: analyses.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final analysis = analyses[index];
                return _HistoryTile(
                  analysis: analysis,
                  onTap: () => context.push('/result', extra: analysis),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar todo el historial?'),
        content: const Text(
          'Esta acción eliminará todos los análisis guardados en el teléfono.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => context.pop(true),
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

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.analysis, required this.onTap});

  final UrlAnalysis analysis;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final presentation = _historyPresentation(analysis.status);
    return Card(
      child: ListTile(
        minVerticalPadding: 16,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(presentation.icon, color: presentation.color, size: 36),
        title: Text(
          analysis.domain,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            '${presentation.label} · ${_formatDate(analysis.analyzedAt)}',
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history, size: 72),
            const SizedBox(height: 20),
            Text(
              'Todavía no revisaste ningún enlace.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            const Text('No pudimos cargar el historial.'),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Intentar nuevamente'),
            ),
          ],
        ),
      ),
    );
  }
}

({String label, IconData icon, Color color}) _historyPresentation(
  AnalysisStatus status,
) {
  return switch (status) {
    AnalysisStatus.safe => (
        label: 'SEGURO',
        icon: Icons.verified_user_outlined,
        color: const Color(0xFF047857),
      ),
    AnalysisStatus.suspicious => (
        label: 'SOSPECHOSO',
        icon: Icons.warning_amber_rounded,
        color: const Color(0xFFB45309),
      ),
    AnalysisStatus.dangerous => (
        label: 'PELIGROSO',
        icon: Icons.gpp_bad_outlined,
        color: const Color(0xFFB91C1C),
      ),
  };
}

String _formatDate(DateTime dateTime) {
  final local = dateTime.toLocal();
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${twoDigits(local.day)}/${twoDigits(local.month)}/${local.year} '
      '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
}
