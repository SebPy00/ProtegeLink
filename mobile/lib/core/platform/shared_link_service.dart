import 'package:flutter/services.dart';
import 'package:protegelink/core/utils/url_validator.dart';

class IncomingShare {
  const IncomingShare({this.url, this.message});

  final String? url;
  final String? message;
}

class SharedLinkService {
  SharedLinkService._();

  static final instance = SharedLinkService._();
  static const _channel = MethodChannel('com.protegelink.mobile/shared_links');

  Future<void> initialize(void Function(IncomingShare) onShare) async {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'sharedText') {
        onShare(_parse(call.arguments as String?));
      }
    });

    try {
      final initialText =
          await _channel.invokeMethod<String>('getInitialSharedText');
      if (initialText != null) onShare(_parse(initialText));
    } on MissingPluginException {
      // Permite ejecutar tests y otras plataformas sin integración Android.
    } on PlatformException {
      onShare(
        const IncomingShare(
          message:
              'No pudimos leer el contenido compartido. Pegá el enlace manualmente.',
        ),
      );
    }
  }

  void dispose() {
    _channel.setMethodCallHandler(null);
  }

  Future<bool> openLinkSettings() async {
    try {
      return await _channel.invokeMethod<bool>('openLinkSettings') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  IncomingShare _parse(String? text) {
    final url = extractFirstHttpUrl(text ?? '');
    if (url != null) return IncomingShare(url: url);
    return const IncomingShare(
      message: 'El contenido compartido no contiene un enlace válido.',
    );
  }
}
