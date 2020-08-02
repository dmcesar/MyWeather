class RegionData {

  final int globalIdLocal;
  final String local;
  final int idRegion;
  final int idCounty;
  final int idDistrict;
  final int idWarningRegion;
  final String latitude;
  final String longitude;

  RegionData({
    this.globalIdLocal,
    this.local,
    this.idRegion,
    this.idCounty,
    this.idDistrict,
    this.idWarningRegion,
    this.latitude,
    this.longitude});

  factory RegionData.fromJson(Map<String, dynamic> json) {
    return RegionData(
      globalIdLocal: json['globalIdLocal'],
      local: json['local'],
      idRegion: json['idRegion'],
      idCounty: json['idCounty'],
      idDistrict: json['idDistrict'],
      idWarningRegion: json['idWarningRegion'],
      latitude: json['latitude'],
      longitude: json['longitude']
    );
  }
}