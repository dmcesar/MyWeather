import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myweather/models/meteorology_data.dart';

class MeteorologyService {

  String _baseURL = "https://api.ipma.pt/open-data/forecast/meteorology/cities/daily";

  Future<List<MeteorologyData>> fetchMeteorologyDataUntil5DaysByLocal(int globalLocalID) async {

    final endpointURL = "${this._baseURL}/$globalLocalID.json";

    final response = await http.get(this._baseURL + endpointURL);

    if(response.statusCode == 200) {

      var responseJSON = json.decode(response.body);

      return(responseJSON as List)
          .map((o) => MeteorologyData.fromJson(o))
          .toList();

    } else {

      throw Exception('Failed to load Meteorology Data');
    }
  }

  Future<List<MeteorologyData>> fetchMeteorologyDataUntil3DaysByDay(int dayID) async {

    final endpointURL = "${this._baseURL}/hp-daily-forecast-day/$dayID.json";

    final response = await http.get(this._baseURL + endpointURL);

    if(response.statusCode == 200) {

      var responseJSON = json.decode(response.body);

      return(responseJSON as List)
          .map((o) => MeteorologyData.fromJson(o))
          .toList();

    } else {

      throw Exception('Failed to load Meteorology Data');
    }
  }
}