import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_app/config/app_config.dart';
import 'package:weather_app/models/weather_data_model.dart';

class WeatherRepository {
  Future<WeatherData> getWeather(String city) async {
    final response =
        await http.get(Uri.parse('${AppConfig.baseUrl}/weather?q=$city&appid=${AppConfig.apiKey}&units=metric'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return WeatherData.fromJson(json);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<List<WeatherData>> getForecastForSelectedPeriod(String city, DateTime startDay, DateTime endDay) async {
    final response =
        await http.get(Uri.parse('${AppConfig.baseUrl}/forecast?q=$city&appid=${AppConfig.apiKey}&units=metric'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> list = json['list'];

      final List<WeatherData> forecastForPeriod = list.map((item) => WeatherData.fromJson(item)).where((weather) {
        final DateTime dt = DateTime.fromMillisecondsSinceEpoch(weather.dt! * 1000);
        return dt.isAfter(startDay) && dt.isBefore(endDay);
      }).toList();

      return forecastForPeriod;
    } else {
      throw Exception('Failed to load forecast data');
    }
  }

  Future<List<WeatherData>> getFiltredForecastForSelectedPeriod(String city, DateTime startDay, DateTime endDay) async {
    final response =
        await http.get(Uri.parse('${AppConfig.baseUrl}/forecast?q=$city&appid=${AppConfig.apiKey}&units=metric'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> list = json['list'];

      final Set<int> uniqueDays = {}; // Set to store unique day values
      final List<WeatherData> forecastForPeriod = [];

      for (var item in list) {
        final weather = WeatherData.fromJson(item);
        final DateTime dt = DateTime.fromMillisecondsSinceEpoch(weather.dt! * 1000);
        final int dayValue = DateTime(dt.year, dt.month, dt.day).millisecondsSinceEpoch;

        if (dt.isAfter(startDay) && dt.isBefore(endDay) && !uniqueDays.contains(dayValue)) {
          forecastForPeriod.add(weather);
          uniqueDays.add(dayValue);
        }
      }

      return forecastForPeriod;
    } else {
      throw Exception('Failed to load forecast data');
    }
  }
}
