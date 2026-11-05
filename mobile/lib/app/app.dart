import 'package:flutter/material.dart';
import 'package:protegelink/app/router.dart';
import 'package:protegelink/app/theme.dart';
import 'package:protegelink/core/platform/shared_link_service.dart';

class ProtegeLinkApp extends StatefulWidget {
  const ProtegeLinkApp({super.key});

  @override
  State<ProtegeLinkApp> createState() => _ProtegeLinkAppState();
}

class _ProtegeLinkAppState extends State<ProtegeLinkApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SharedLinkService.instance.initialize(_openSharedContent);
    });
  }

  void _openSharedContent(IncomingShare share) {
    appRouter.go('/check', extra: share);
  }

  @override
  void dispose() {
    SharedLinkService.instance.dispose();
    super.dispose();
  }

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
