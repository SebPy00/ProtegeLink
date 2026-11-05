const _reasonMessages = <String, String>{
  'insecure_http': 'El sitio no utiliza una conexión segura.',
  'ip_address_host':
      'El enlace utiliza una dirección numérica en lugar de un nombre de sitio habitual.',
  'suspicious_keywords':
      'La dirección contiene palabras utilizadas frecuentemente en páginas que solicitan datos sensibles.',
  'too_many_subdomains': 'La dirección utiliza una estructura poco habitual.',
  'very_long_url': 'La dirección del enlace es inusualmente larga.',
  'suspicious_characters':
      'La dirección contiene caracteres que conviene revisar con atención.',
  'unicode_or_punycode':
      'La dirección contiene caracteres que pueden utilizarse para imitar otros sitios.',
  'safe_browsing_match':
      'Este sitio fue identificado como peligroso por un servicio de reputación.',
  'brand_impersonation':
      'La dirección podría estar intentando parecerse a una empresa conocida.',
  'demo_mode_case':
      'Este resultado corresponde a un caso de demostración controlado.',
};

String translateAnalysisReason(String reason) {
  return _reasonMessages[reason] ??
      'El análisis encontró una señal que conviene revisar antes de continuar.';
}
