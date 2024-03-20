import 'package:weather_app/models/clouds_model.dart';
import 'package:weather_app/models/coordiantion_model.dart';
import 'package:weather_app/models/main_weather_details_model.dart';
import 'package:weather_app/models/system_details_model.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/models/wind_model.dart';

class WeatherData {
  Coordination? coordination;
  List<Weather>? weather;
  String? base;
  MainWeatherDetails? mainDetails;
  int? visibility;
  Wind? wind;
  Clouds? clouds;
  int? dt;
  SystemDetails? systemDetails;
  int? timezone;
  int? id;
  String? name;
  int? cod;

  WeatherData(
      {this.coordination,
      this.weather,
      this.base,
      this.mainDetails,
      this.visibility,
      this.wind,
      this.clouds,
      this.dt,
      this.systemDetails,
      this.timezone,
      this.id,
      this.name,
      this.cod});

  WeatherData.fromJson(Map<String, dynamic> json) {
    coordination = json['coord'] != null ? Coordination.fromJson(json['coord']) : null;
    if (json['weather'] != null) {
      weather = <Weather>[];
      json['weather'].forEach((v) {
        weather!.add(Weather.fromJson(v));
      });
    }
    base = json['base'];
    mainDetails = json['main'] != null ? MainWeatherDetails.fromJson(json['main']) : null;
    visibility = json['visibility'];
    wind = json['wind'] != null ? Wind.fromJson(json['wind']) : null;
    clouds = json['clouds'] != null ? Clouds.fromJson(json['clouds']) : null;
    dt = json['dt'];
    systemDetails = json['sys'] != null ? SystemDetails.fromJson(json['sys']) : null;
    timezone = json['timezone'];
    id = json['id'];
    name = json['name'];
    cod = json['cod'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (coordination != null) {
      data['coord'] = coordination!.toJson();
    }
    if (weather != null) {
      data['weather'] = weather!.map((v) => v.toJson()).toList();
    }
    data['base'] = base;
    if (mainDetails != null) {
      data['main'] = mainDetails!.toJson();
    }
    data['visibility'] = visibility;
    if (wind != null) {
      data['wind'] = wind!.toJson();
    }
    if (clouds != null) {
      data['clouds'] = clouds!.toJson();
    }
    data['dt'] = dt;
    if (systemDetails != null) {
      data['sys'] = systemDetails!.toJson();
    }
    data['timezone'] = timezone;
    data['id'] = id;
    data['name'] = name;
    data['cod'] = cod;
    return data;
  }
}
