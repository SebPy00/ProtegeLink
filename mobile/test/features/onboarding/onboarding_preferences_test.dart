import 'package:flutter_test/flutter_test.dart';
import 'package:protegelink/features/onboarding/data/onboarding_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('onboarding starts pending and remains completed after saving',
      () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = OnboardingPreferences();

    expect(await preferences.isCompleted(), isFalse);

    await preferences.markCompleted();

    expect(await preferences.isCompleted(), isTrue);
  });
}
