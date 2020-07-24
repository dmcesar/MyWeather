class MeteorologyData {

  final DateTime forecastDate;
  final DateTime dataUpdate;
  final int globalIdLocal;
  final int idWeatherType;
  final int tMin;
  final int tMax;
  final int classWindSpeed;
  final String predWindDir;
  final double probPrecipita;
  final int classPrecInt;
  final String latitude;
  final String longitude;

  MeteorologyData({
    this.forecastDate,
    this.dataUpdate,
    this.globalIdLocal,
    this.idWeatherType,
    this.tMin,
    this.tMax,
    this.classWindSpeed,
    this.predWindDir,
    this.probPrecipita,
    this.classPrecInt,
    this.latitude,
    this.longitude});

  factory MeteorologyData.fromJson(Map<String, dynamic> json) {
    return MeteorologyData(
      forecastDate: json['forecastDate'],
      dataUpdate: json['dataUpdate'],
      globalIdLocal: json['globalIdLocal'],
      idWeatherType: json['idWeatherType'],
      tMin: json['tMin'],
      tMax: json['tMax'],
      classWindSpeed: json['classWindSpeed'],
      predWindDir: json['predWindDir'],
      probPrecipita: json['probPrecipita'],
      classPrecInt: json['classPrecInt'],
      latitude: json['latitude'],
      longitude: json['longitude']
    );
  }
}