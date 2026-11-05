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
  bool _showLimitationNotice = true;

  @override
  void initState() {
    super.initState();
    if (widget.analysis.status == AnalysisStatus.safe) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.disabled)
        ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (request) {
              final uri = Uri.tryParse(request.url);
              final isWebUrl = uri != null &&
                  (uri.scheme == 'http' || uri.scheme == 'https');
              return isWebUrl
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
          : Column(
              children: [
                if (_showLimitationNotice)
                  MaterialBanner(
                    content: const Text(
                      'ProtegeLink revisó la página inicial. Esta versión académica todavía no vuelve a analizar cada redirección o enlace interno.',
                    ),
                    leading: const Icon(Icons.info_outline),
                    actions: [
                      TextButton(
                        onPressed: () {
                          setState(() => _showLimitationNotice = false);
                        },
                        child: const Text('Entendido'),
                      ),
                    ],
                  ),
                Expanded(child: WebViewWidget(controller: controller)),
              ],
            ),
    );
  }
}
