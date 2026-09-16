import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:protegelink/core/widgets/main_navigation_scaffold.dart';
import 'package:protegelink/features/browser/presentation/browser_page.dart';
import 'package:protegelink/features/help/presentation/help_page.dart';
import 'package:protegelink/features/history/presentation/history_page.dart';
import 'package:protegelink/features/home/presentation/home_page.dart';
import 'package:protegelink/features/onboarding/data/onboarding_preferences.dart';
import 'package:protegelink/features/onboarding/presentation/onboarding_page.dart';
import 'package:protegelink/features/settings/presentation/settings_page.dart';
import 'package:protegelink/features/url_check/domain/url_analysis.dart';
import 'package:protegelink/features/url_check/presentation/analysis_result_page.dart';
import 'package:protegelink/features/url_check/presentation/url_check_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    if (state.matchedLocation != '/') return null;
    final completed = await OnboardingPreferences().isCompleted();
    return completed ? '/home' : '/onboarding';
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const _LoadingPage()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    ShellRoute(
      builder: (context, state, child) =>
          MainNavigationScaffold(currentLocation: state.uri.path, child: child),
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomePage()),
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryPage(),
        ),
        GoRoute(path: '/help', builder: (context, state) => const HelpPage()),
      ],
    ),
    GoRoute(path: '/check', builder: (context, state) => const UrlCheckPage()),
    GoRoute(
      path: '/result',
      builder: (context, state) {
        final analysis = state.extra;
        if (analysis is! UrlAnalysis) {
          return const _InvalidRoutePage(
            message: 'No hay un análisis para mostrar.',
          );
        }
        return AnalysisResultPage(analysis: analysis);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/browser',
      builder: (context, state) {
        final analysis = state.extra;
        if (analysis is! UrlAnalysis) {
          return const _InvalidRoutePage(message: 'Primero revisá un enlace.');
        }
        return BrowserPage(analysis: analysis);
      },
    ),
  ],
);

class _LoadingPage extends StatelessWidget {
  const _LoadingPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _InvalidRoutePage extends StatelessWidget {
  const _InvalidRoutePage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ProtegeLink')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ),
    );
  }
}
