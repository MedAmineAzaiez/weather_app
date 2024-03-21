import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:weather_app/config/app_color.dart';
import 'package:weather_app/helpers/cities_list_helper.dart';
import 'package:weather_app/helpers/unit_preferences.dart';
import 'package:weather_app/models/weather_data_model.dart';
import 'package:weather_app/repository/weather_repo.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:weather_app/helpers/extensions.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String _selectedCity = 'london';
  late Future<WeatherData> _weather = Future<WeatherData>(() async => WeatherData());
  late Future<List<WeatherData>> _todayWeatherForecast;
  late Future<List<WeatherData>> _weekWeatherForecast;
  late SharedPreferences _prefs;

  Future<SharedPreferences> _getSharedPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _prefs = prefs;
    });
    return _prefs;
  }

  Future<void> _fetchTodaysWeather(String city, DateTime dateTime) async {
    setState(() {
      _weather = WeatherRepository().getWeather(
        city,
        SharedPreferencesHelper.getApiUnit(_prefs),
        dateTime,
      );
    });
  }

  Future<void> _fetchTodayWeatherForecast(String city) async {
    setState(() {
      _todayWeatherForecast = WeatherRepository().getForecastForSelectedPeriod(
        city,
        DateTime.now(),
        DateTime.now().add(
          const Duration(hours: 28),
        ),
        SharedPreferencesHelper.getApiUnit(_prefs),
      );
    });
  }

  Future<void> _fetchWeekWeatherForecast(String city) async {
    setState(() {
      _weekWeatherForecast = WeatherRepository().getFilteredForecastForSelectedPeriod(
        city,
        DateTime.now(),
        DateTime.now().add(
          const Duration(days: 7),
        ),
        SharedPreferencesHelper.getApiUnit(_prefs),
      );
    });
  }

  _fetchWeather(String city, DateTime dateTime) async {
    await _fetchTodaysWeather(_selectedCity, dateTime);
    await _fetchTodayWeatherForecast(_selectedCity);
    await _fetchWeekWeatherForecast(_selectedCity);
  }

  @override
  void initState() {
    super.initState();
    _getSharedPrefs().then((_) {
      _fetchWeather(_selectedCity, DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: _buildSearchWeatherPerCityNameFieldWidget(),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _fetchWeather(_selectedCity, DateTime.now());
          },
          child: FutureBuilder<WeatherData>(
            future: _weather,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                final weather = snapshot.data!;
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildTemperatureUnitToggleWidget(),
                      _buildDayNameWidget(weather.dt!, size),
                      _buildCityNameWidget(_selectedCity, size),
                      _buildCUrrentTempWidget(weather.mainDetails!.temp!.round(), size),
                      _buildDividerWidget(size),
                      _buildWeatherConditionWidget(size),
                      _buildMinAndMaxTempWidget(
                        size,
                        weather.mainDetails!.tempMin!.round(),
                        weather.mainDetails!.tempMax!.round(),
                      ),
                      const SizedBox(height: 10.0),
                      _buildForcastForTodayWidget(size),
                      _buildSevenDaysForecastWidget(
                        size,
                        weather.mainDetails!.tempMin!.round(),
                        weather.mainDetails!.tempMax!.round(),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDayNameWidget(int dateTime, Size size) => Padding(
        padding: EdgeInsets.only(
          top: size.height * 0.01,
        ),
        child: Text(
          DateFormat('EEEE, MMMM d, y').format(DateTime.fromMillisecondsSinceEpoch(dateTime * 1000)),
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: size.height * 0.03,
          ),
        ),
      );

  Widget _buildSearchWeatherPerCityNameFieldWidget() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          children: [
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                return CitiesListHelper.cities.where((String option) {
                  return option.toLowerCase().startsWith(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) {
                setState(() {
                  _selectedCity = selection.toCapitalized();
                });
                _fetchWeather(_selectedCity, DateTime.now());
              },
              fieldViewBuilder: (
                BuildContext context,
                TextEditingController textEditingController,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted,
              ) {
                textEditingController.text = _selectedCity;
                return TextField(
                  decoration: const InputDecoration(
                    hintText: 'Enter city name',
                    border: InputBorder.none,
                  ),
                  controller: textEditingController,
                  focusNode: focusNode,
                  onSubmitted: (String value) {
                    onFieldSubmitted();
                  },
                );
              },
            ),
          ],
        ),
      );

  Widget _buildTemperatureUnitToggleWidget() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Current Temperature Unit: ${SharedPreferencesHelper.getTemperatureUnit(_prefs)}'),
            const SizedBox(height: 10.0),
            ToggleSwitch(
              minWidth: 90.0,
              initialLabelIndex: SharedPreferencesHelper.getTemperatureUnit(_prefs) == 'C' ? 0 : 1,
              labels: const ['C', 'F'],
              onToggle: (index) async {
                await SharedPreferencesHelper.setTemperatureUnit(_prefs, index == 0 ? 'C' : 'F');
                await _fetchWeather(_selectedCity, DateTime.now());
              },
            ),
          ],
        ),
      );

  Widget _buildSevenDaysForecastWidget(Size size, int minTemp, int maxTemp) => FutureBuilder<List<WeatherData>>(
        future: _weekWeatherForecast,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final weekWeatherForecast = snapshot.data!;
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
                vertical: size.height * 0.02,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                  color: Colors.blueGrey.withOpacity(0.09),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: size.height * 0.02,
                        left: size.width * 0.03,
                      ),
                      child: Text(
                        '7-day forecast',
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: size.height * 0.025,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(color: AppColors.primaryColor),
                    ListView.builder(
                      itemCount: weekWeatherForecast.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final weather = weekWeatherForecast[index];
                        return buildSevenDayForecast(
                          weather.dt!,
                          weather.mainDetails!.tempMin!.round(),
                          weather.mainDetails!.tempMax!.round(),
                          _buildWeatherIcon(weather.weather![0].id!),
                          size,
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        },
      );

  Widget _buildForcastForTodayWidget(Size size) => FutureBuilder<List<WeatherData>>(
        future: _todayWeatherForecast,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final todayWeatherForecast = snapshot.data!;
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                  color: Colors.black.withOpacity(0.05),
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: size.height * 0.01,
                          left: size.width * 0.03,
                        ),
                        child: Text(
                          'Forecast for the next 24 hours',
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: size.height * 0.025,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.36,
                      child: ListView.builder(
                        itemCount: todayWeatherForecast.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final weather = todayWeatherForecast[index];
                          return buildForecastToday(
                            DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(weather.dt! * 1000)),
                            weather.mainDetails!.temp!.round(),
                            weather.wind!.speed!.round(),
                            weather.mainDetails!.humidity!.round(),
                            weather.mainDetails!.pressure!.round(),
                            _buildWeatherIcon(weather.weather![0].id!),
                            size,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      );

  Widget _buildMinAndMaxTempWidget(Size size, int minTemp, int maxTemp) => Padding(
        padding: EdgeInsets.only(
          top: size.height * 0.03,
          bottom: size.height * 0.01,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$minTemp˚${SharedPreferencesHelper.getTemperatureUnit(_prefs)}',
              style: TextStyle(
                color: minTemp <= 0
                    ? Colors.blue
                    : minTemp > 0 && minTemp <= 15
                        ? Colors.indigo
                        : minTemp > 15 && minTemp < 30
                            ? Colors.deepPurple
                            : Colors.pink,
                fontSize: size.height * 0.03,
              ),
            ),
            Text(
              '/',
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: size.height * 0.03,
              ),
            ),
            Text(
              '$maxTemp˚${SharedPreferencesHelper.getTemperatureUnit(_prefs)}', //max temperature
              style: TextStyle(
                color: maxTemp <= 0
                    ? Colors.blue
                    : maxTemp > 0 && maxTemp <= 15
                        ? Colors.indigo
                        : maxTemp > 15 && maxTemp < 30
                            ? Colors.deepPurple
                            : Colors.pink,
                fontSize: size.height * 0.03,
              ),
            ),
          ],
        ),
      );

  Widget _buildWeatherConditionWidget(Size size) => Padding(
        padding: EdgeInsets.only(
          top: size.height * 0.005,
        ),
        child: Text(
          'Sunny', // weather
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: size.height * 0.03,
          ),
        ),
      );

  Widget _buildDividerWidget(Size size) => Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.25),
        child: const Divider(
          color: AppColors.primaryColor,
        ),
      );

  Widget _buildCUrrentTempWidget(int currTemp, Size size) => Text(
        '$currTemp˚${SharedPreferencesHelper.getTemperatureUnit(_prefs)}',
        style: TextStyle(
          color: currTemp <= 0
              ? Colors.blue
              : currTemp > 0 && currTemp <= 15
                  ? Colors.indigo
                  : currTemp > 15 && currTemp < 30
                      ? Colors.deepPurple
                      : Colors.pink,
          fontSize: size.height * 0.13,
        ),
      );

  Widget _buildCityNameWidget(String cityName, Size size) => Text(
        cityName,
        style: TextStyle(
          color: AppColors.textColor,
          fontSize: size.height * 0.06,
          fontWeight: FontWeight.bold,
        ),
      );

  Widget buildForecastToday(
    String time,
    int temp,
    int wind,
    int humidity,
    int pressure,
    IconData weatherIcon,
    size,
  ) =>
      Padding(
        padding: EdgeInsets.all(size.width * 0.025),
        child: Column(
          children: [
            Text(
              time,
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: size.height * 0.02,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: size.height * 0.005,
              ),
              child: FaIcon(
                weatherIcon,
                color: AppColors.primaryColor,
                size: size.height * 0.03,
              ),
            ),
            Text(
              '$temp˚${SharedPreferencesHelper.getTemperatureUnit(_prefs)}',
              style: TextStyle(
                color: temp <= 0
                    ? Colors.blue
                    : temp > 0 && temp <= 15
                        ? Colors.indigo
                        : temp > 15 && temp < 30
                            ? Colors.deepPurple
                            : Colors.pink,
                fontSize: size.height * 0.025,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: size.height * 0.01,
              ),
              child: FaIcon(
                FontAwesomeIcons.wind,
                color: AppColors.primaryColor,
                size: size.height * 0.03,
              ),
            ),
            Text(
              '$wind km/h',
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: size.height * 0.02,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: size.height * 0.01,
              ),
              child: FaIcon(
                FontAwesomeIcons.droplet,
                color: AppColors.primaryColor,
                size: size.height * 0.03,
              ),
            ),
            Text(
              '$humidity %',
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: size.height * 0.02,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: size.height * 0.01,
              ),
              child: FaIcon(
                FontAwesomeIcons.gaugeHigh,
                color: AppColors.primaryColor,
                size: size.height * 0.03,
              ),
            ),
            Text(
              '$pressure hPa',
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: size.height * 0.02,
              ),
            ),
          ],
        ),
      );

  Widget buildSevenDayForecast(int dateTime, int minTemp, int maxTemp, IconData weatherIcon, size) => Padding(
        padding: EdgeInsets.all(
          size.height * 0.005,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.02,
                  ),
                  child: Text(
                    DateFormat.E().format(DateTime.fromMillisecondsSinceEpoch(dateTime * 1000)),
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: size.height * 0.025,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.25,
                  ),
                  child: FaIcon(
                    weatherIcon,
                    color: AppColors.primaryColor,
                    size: size.height * 0.03,
                  ),
                ),
                Align(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: size.width * 0.15,
                    ),
                    child: Text(
                      '$minTemp˚${SharedPreferencesHelper.getTemperatureUnit(_prefs)}',
                      style: TextStyle(
                        color: minTemp <= 0
                            ? Colors.blue
                            : minTemp > 0 && minTemp <= 15
                                ? Colors.indigo
                                : minTemp > 15 && minTemp < 30
                                    ? Colors.deepPurple
                                    : Colors.pink,
                        fontSize: size.height * 0.025,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                    ),
                    child: Text(
                      '$maxTemp˚${SharedPreferencesHelper.getTemperatureUnit(_prefs)}',
                      style: TextStyle(
                        color: maxTemp <= 0
                            ? Colors.blue
                            : maxTemp > 0 && maxTemp <= 15
                                ? Colors.indigo
                                : maxTemp > 15 && maxTemp < 30
                                    ? Colors.deepPurple
                                    : Colors.pink,
                        fontSize: size.height * 0.025,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(
              color: AppColors.primaryColor,
            ),
          ],
        ),
      );
  IconData _buildWeatherIcon(int weatherId) {
    switch (weatherId ~/ 100) {
      case 2: // Thunderstorm
        return WeatherIcons.thunderstorm;
      case 3: // Drizzle
        return WeatherIcons.raindrops;
      case 5: // Rain
        return WeatherIcons.rain;
      case 6: // Snow
        return WeatherIcons.snow;
      case 7: // Atmosphere (Fog, Mist, Smoke, etc.)
        return WeatherIcons.fog;
      case 8: // Clear or Clouds
        return weatherId == 800 ? WeatherIcons.day_sunny : WeatherIcons.cloudy;
      default:
        return WeatherIcons.na;
    }
  }
}
