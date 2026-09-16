import 'package:flutter/material.dart';
import 'package:protegelink/app/router.dart';
import 'package:protegelink/app/theme.dart';

class ProtegeLinkApp extends StatelessWidget {
  const ProtegeLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ProtegeLink',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: appRouter,
    );
  }
}
