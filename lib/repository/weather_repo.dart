import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_app/config/app_config.dart';
import 'package:weather_app/models/weather_data_model.dart';

class WeatherRepository {
  Future<WeatherData> getWeather(String city, String unit, DateTime date) async {
    final unixTime = date.millisecondsSinceEpoch ~/ 1000;
    final response = await http
        .get(Uri.parse('${AppConfig.baseUrl}/weather?q=$city&dt=$unixTime&appid=${AppConfig.apiKey}&units=$unit'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return WeatherData.fromJson(json);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<List<WeatherData>> getForecastForSelectedPeriod(
    String city,
    DateTime startDay,
    DateTime endDay,
    String unit,
  ) async {
    final response =
        await http.get(Uri.parse('${AppConfig.baseUrl}/forecast?q=$city&appid=${AppConfig.apiKey}&units=$unit'));
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

  Future<List<WeatherData>> getFilteredForecastForSelectedPeriod(
    String city,
    DateTime startDay,
    DateTime endDay,
    String unit,
  ) async {
    final response =
        await http.get(Uri.parse('${AppConfig.baseUrl}/forecast?q=$city&appid=${AppConfig.apiKey}&units=$unit'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> list = json['list'];

      final Map<int, WeatherData> forecastMap = {}; // Map to store unique day values with corresponding WeatherData
      final List<WeatherData> forecastForPeriod = [];

      for (var item in list) {
        final weather = WeatherData.fromJson(item);
        final DateTime dt = DateTime.fromMillisecondsSinceEpoch(weather.dt! * 1000);
        final int dayValue = DateTime(dt.year, dt.month, dt.day).millisecondsSinceEpoch;

        if (dt.isAfter(startDay) && dt.isBefore(endDay)) {
          if (!forecastMap.containsKey(dayValue)) {
            forecastMap[dayValue] = weather;
          } else {
            // Update minTemp and maxTemp if necessary
            if (weather.mainDetails!.tempMin! < forecastMap[dayValue]!.mainDetails!.tempMin!) {
              forecastMap[dayValue]!.mainDetails!.tempMin = weather.mainDetails!.tempMin;
            }
            if (weather.mainDetails!.tempMax! > forecastMap[dayValue]!.mainDetails!.tempMax!) {
              forecastMap[dayValue]!.mainDetails!.tempMax = weather.mainDetails!.tempMax;
            }
          }
        }
      }

      forecastForPeriod.addAll(forecastMap.values);

      return forecastForPeriod;
    } else {
      throw Exception('Failed to load forecast data');
    }
  }
}
