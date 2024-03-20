import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/models/weather_data_model.dart';
import 'package:weather_app/repository/weather_repo.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String cityName = 'London';
  late Future<WeatherData> _weather;
  late Future<List<WeatherData>> _todayWeatherForecast;
  late Future<List<WeatherData>> _weekWeatherForecast;

  Future<void> _fetchWeather() async {
    setState(() {
      _weather = WeatherRepository().getWeather(cityName);
    });
  }

  Future<void> _fetchTodayWeatherForecast() async {
    setState(() {
      _todayWeatherForecast = WeatherRepository().getForecastForSelectedPeriod(
        cityName,
        DateTime.now(),
        DateTime.now().add(const Duration(days: 1)),
      );
    });
  }

  Future<void> _fetchWeekWeatherForecast() async {
    setState(() {
      _weekWeatherForecast = WeatherRepository().getFiltredForecastForSelectedPeriod(
        cityName,
        DateTime.now(),
        DateTime.now().add(const Duration(days: 7)),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
    _fetchTodayWeatherForecast();
    _fetchWeekWeatherForecast();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
      ),
      body: FutureBuilder<WeatherData>(
        future: _weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final weather = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('EEEE').format(DateTime.now()),
                  style: const TextStyle(fontSize: 24),
                ),
                Text(
                  weather.weather!.first.description!,
                  style: const TextStyle(fontSize: 18),
                ),
                Image.network(
                  'https://openweathermap.org/img/w/${weather.weather!.first.icon}.png',
                  scale: 1.5,
                ),
                Text(
                  '${weather.mainDetails!.temp}°C',
                  style: const TextStyle(fontSize: 48),
                ),
                Text('Humidity: ${weather.mainDetails!.humidity}%'),
                Text('Pressure: ${weather.mainDetails!.pressure} hPa'),
                Text('Wind: ${weather.wind!.speed} m/s'),
              ],
            );
          }
        },
      ),
    );
  }
}
