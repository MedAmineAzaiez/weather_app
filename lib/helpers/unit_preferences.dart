import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static String getTemperatureUnit(SharedPreferences prefs) {
    final String unit = prefs.getString('temperatureUnit') ?? 'C';
    return unit;
  }

  static String getApiUnit(SharedPreferences prefs) {
    final String unit = prefs.getString('apiUnit') ?? 'metric';
    return unit;
  }

  static Future<void> setTemperatureUnit(SharedPreferences prefs, String unit) async {
    await prefs.setString('temperatureUnit', unit);
    if (unit == 'C') {
      await prefs.setString('apiUnit', 'metric');
    } else if (unit == 'F') {
      await prefs.setString('apiUnit', 'imperial');
    }
  }
}
