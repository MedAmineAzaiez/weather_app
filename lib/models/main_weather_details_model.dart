class MainWeatherDetails {
  double? temp;
  double? feelsLike;
  double? tempMin;
  double? tempMax;
  double? pressure;
  double? humidity;
  double? seaLevel;
  double? grndLevel;

  MainWeatherDetails(
      {this.temp,
      this.feelsLike,
      this.tempMin,
      this.tempMax,
      this.pressure,
      this.humidity,
      this.seaLevel,
      this.grndLevel});

  MainWeatherDetails.fromJson(Map<String, dynamic> json) {
    temp = json['temp'] != null ? json['temp'].toDouble() : 0;
    feelsLike = json['feels_like'] != null ? json['feels_like'].toDouble() : 0;
    tempMin = json['temp_min'] != null ? json['temp_min'].toDouble() : 0;
    tempMax = json['temp_max'] != null ? json['temp_max'].toDouble() : 0;
    pressure = json['pressure'] != null ? json['pressure'].toDouble() : 0;
    humidity = json['humidity'] != null ? json['humidity'].toDouble() : 0;
    seaLevel = json['sea_level'] != null ? json['sea_level'].toDouble() : 0;
    grndLevel = json['grnd_level'] != null ? json['grnd_level'].toDouble() : 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['temp'] = temp;
    data['feels_like'] = feelsLike;
    data['temp_min'] = tempMin;
    data['temp_max'] = tempMax;
    data['pressure'] = pressure;
    data['humidity'] = humidity;
    data['sea_level'] = seaLevel;
    data['grnd_level'] = grndLevel;
    return data;
  }
}
