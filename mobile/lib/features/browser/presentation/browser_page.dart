import 'package:flutter/material.dart';
import 'package:protegelink/features/url_check/domain/url_analysis.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BrowserPage extends StatefulWidget {
  const BrowserPage({required this.analysis, super.key});

  final UrlAnalysis analysis;

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.analysis.status == AnalysisStatus.safe) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.disabled)
        ..setNavigationDelegate(
          NavigationDelegate(
            // Toda navegación posterior deberá volver a analizarse antes de
            // habilitarse. Por ahora se bloquea salir de la URL ya aprobada.
            onNavigationRequest: (request) {
              return request.url == widget.analysis.url
                  ? NavigationDecision.navigate
                  : NavigationDecision.prevent;
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.analysis.url));
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      appBar: AppBar(title: Text(widget.analysis.domain)),
      body: controller == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Este enlace no puede abrirse porque no fue clasificado como seguro.',
                ),
              ),
            )
          : WebViewWidget(controller: controller),
    );
  }
}
