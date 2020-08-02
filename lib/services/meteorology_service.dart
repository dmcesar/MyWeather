import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myweather/models/meteorology_data.dart';

class MeteorologyService {

  String _baseURL = "https://api.ipma.pt/open-data/forecast/meteorology/cities/daily";

  StreamController _controller = StreamController();

  Sink get _input => _controller.sink;
  Stream get output => _controller.stream;

  void fetchMeteorologyDataUntil5DaysByLocal(int globalLocalID) async {

    final endpointURL = "${this._baseURL}/$globalLocalID.json";

    final response = await http.get(endpointURL);

    if(response.statusCode == 200) {

      var responseJSON = json.decode(response.body);

      List<dynamic> data = responseJSON["data"];

      _input.add(
          data
              .map((o) => MeteorologyData.fromJson(o))
              .toList()
      );

    } else {

      throw Exception('Failed to load Meteorology Data');
    }
  }

  void fetchMeteorologyDataUntil3DaysByDay(int dayID) async {

    final endpointURL = "${this._baseURL}/hp-daily-forecast-day$dayID.json";

    final response = await http.get(endpointURL);

    if(response.statusCode == 200) {

      var responseJSON = json.decode(response.body);

      List<dynamic> data = responseJSON["data"];

      _input.add(
          data
              .map((o) => MeteorologyData.fromJson(o))
              .toList()
      );

    } else {

      print(response.statusCode);

      throw Exception('Failed to load Meteorology Data');
    }
  }

  void dispose() => _controller.close();
}