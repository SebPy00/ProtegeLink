String? validateHttpUrl(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Ingresá un enlace.';

  final uri = Uri.tryParse(text);
  if (uri == null ||
      !uri.hasScheme ||
      (uri.scheme != 'http' && uri.scheme != 'https') ||
      uri.host.isEmpty) {
    return 'Ingresá una URL completa que comience con http:// o https://.';
  }
  return null;
}
