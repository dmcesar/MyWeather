class WeatherDescriptor {

  final int idWeatherType;
  final String descWeatherTypeEN;
  final String descWeatherTypePT;

  WeatherDescriptor({
    this.idWeatherType,
    this.descWeatherTypeEN,
    this.descWeatherTypePT});

  factory WeatherDescriptor.fromJson(Map<String, dynamic> json) {

    return WeatherDescriptor(
        idWeatherType: json['idWeatherType'],
        descWeatherTypeEN: json['descIdWeatherTypeEN'],
        descWeatherTypePT: json['descIdWeatherTypePT']
    );
  }
}