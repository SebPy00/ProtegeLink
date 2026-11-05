class AppConfig {
  const AppConfig._();

  // URL incluida dentro del APK. Cambiar esta constante antes de compilar si
  // se conoce la IP que tendrá la notebook durante la demostración.
  static const bundledApiBaseUrl = 'http://172.20.10.2:8000';

  // API_BASE_URL sigue disponible como override opcional de compilación.
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: bundledApiBaseUrl,
  );

  static const requestTimeout = Duration(seconds: 10);
}
