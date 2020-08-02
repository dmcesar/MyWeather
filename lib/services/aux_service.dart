import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myweather/models/region_data.dart';

class AuxService {

  final _baseURL = "https://api.ipma.pt/open-data";

  Future<List<LocationData>> fetchLocationDataList() async {

    final endpointURL = "${this._baseURL}/distrits-islands.json";

    final response = await http.get(this._baseURL + endpointURL);

    if(response.statusCode == 200) {

      var responseJSON = json.decode(response.body);

      return(responseJSON as List)
        .map((o) => LocationData.fromJson(o))
        .toList();

    } else {

      throw Exception('Failed to load Locations Data');
    }
  }
}