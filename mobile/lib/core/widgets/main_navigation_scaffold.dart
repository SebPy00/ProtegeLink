import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainNavigationScaffold extends StatelessWidget {
  const MainNavigationScaffold({
    required this.currentLocation,
    required this.child,
    super.key,
  });

  final String currentLocation;
  final Widget child;

  int get _selectedIndex => switch (currentLocation) {
    '/history' => 1,
    '/help' => 2,
    _ => 0,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          const locations = ['/home', '/history', '/help'];
          context.go(locations[index]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'Historial'),
          NavigationDestination(icon: Icon(Icons.help_outline), label: 'Ayuda'),
        ],
      ),
    );
  }
}
