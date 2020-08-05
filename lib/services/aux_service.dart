import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myweather/models/region_data.dart';
import 'package:myweather/models/weather_descriptor_data.dart';

class AuxService {

  StreamController _controller = StreamController();

  Sink get _input => _controller.sink;
  Stream get output => _controller.stream;

  final _baseURL = "https://api.ipma.pt/open-data";

  void fetchRegionDataList() async {

    final endpointURL = "${this._baseURL}/distrits-islands.json";

    final response = await http.get(endpointURL);

    if (response.statusCode == 200) {
      var responseJSON = json.decode(response.body);

      List<dynamic> data = responseJSON["data"];

      _input.add(
          data
              .map((o) => RegionData.fromJson(o))
              .toList()
      );

    } else {

      throw Exception('Failed to load Regions Data');
    }
  }

  Future<List<WeatherDescriptor>> fetchWeatherDescriptors() async {

    final endpointURL = "${this._baseURL}/weather-type-classe.json";

    final response = await http.get(endpointURL);

    if (response.statusCode == 200) {
      var responseJSON = json.decode(response.body);

      List<dynamic> data = responseJSON["data"];

      return data
              .map((o) => WeatherDescriptor.fromJson(o))
              .toList();

    } else {

      throw Exception('Failed to load Weather Descriptors Data');
    }
  }

  void dispose() => _controller.close();
}