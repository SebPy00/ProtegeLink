import 'package:flutter_test/flutter_test.dart';
import 'package:protegelink/core/constants/app_config.dart';
import 'package:protegelink/core/preferences/backend_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('uses the URL bundled in the APK by default', () async {
    final preferences = BackendPreferences();

    expect(await preferences.getApiBaseUrl(), AppConfig.apiBaseUrl);
  });

  test('persists and resets a backend URL selected on the phone', () async {
    final preferences = BackendPreferences();
    const customUrl = 'http://192.168.43.25:8000';

    await preferences.setApiBaseUrl(customUrl);
    expect(await preferences.getApiBaseUrl(), customUrl);

    await preferences.resetApiBaseUrl();
    expect(await preferences.getApiBaseUrl(), AppConfig.apiBaseUrl);
  });
}
