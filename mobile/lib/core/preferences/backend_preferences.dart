import 'package:protegelink/core/constants/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackendPreferences {
  static const _apiBaseUrlKey = 'api_base_url';

  Future<String> getApiBaseUrl() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_apiBaseUrlKey) ?? AppConfig.apiBaseUrl;
  }

  Future<void> setApiBaseUrl(String value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_apiBaseUrlKey, value);
  }

  Future<void> resetApiBaseUrl() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_apiBaseUrlKey);
  }
}
