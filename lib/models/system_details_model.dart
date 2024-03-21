class SystemDetails {
  int? type;
  int? id;
  String? country;
  double? sunrise;
  double? sunset;

  SystemDetails({this.type, this.id, this.country, this.sunrise, this.sunset});

  SystemDetails.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    id = json['id'];
    country = json['country'];
    sunrise = json['sunrise'] != null ? json['sunrise'].toDouble() : 0;
    sunset = json['sunset'] != null ? json['sunset'].toDouble() : 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['id'] = id;
    data['country'] = country;
    data['sunrise'] = sunrise;
    data['sunset'] = sunset;
    return data;
  }
}
