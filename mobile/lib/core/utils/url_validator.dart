String? validateHttpUrl(String? value) {
  final text = normalizeUrlInput(value ?? '');
  if (text.isEmpty) return 'Ingresá un enlace.';

  final uri = Uri.tryParse(text);
  if (uri == null ||
      !uri.hasScheme ||
      (uri.scheme != 'http' && uri.scheme != 'https') ||
      uri.host.isEmpty) {
    return 'El texto ingresado no parece ser un enlace válido.';
  }
  return null;
}

String normalizeUrlInput(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed.contains(RegExp(r'\s'))) return trimmed;

  final parsed = Uri.tryParse(trimmed);
  if (parsed != null && parsed.hasScheme) return trimmed;

  final withHttps = Uri.tryParse('https://$trimmed');
  if (withHttps != null &&
      withHttps.host.isNotEmpty &&
      withHttps.host.contains('.')) {
    return withHttps.toString();
  }
  return trimmed;
}

String? extractFirstHttpUrl(String text) {
  final match =
      RegExp(r'https?://[^\s]+', caseSensitive: false).firstMatch(text);
  if (match == null) return null;

  var candidate = match.group(0)!;
  const trailingPunctuation = '.,;:!?)]}';
  while (candidate.isNotEmpty &&
      trailingPunctuation.contains(candidate[candidate.length - 1])) {
    candidate = candidate.substring(0, candidate.length - 1);
  }

  return validateHttpUrl(candidate) == null ? candidate : null;
}
