import 'dart:async';

import 'package:myweather/services/aux_service.dart';
import 'package:myweather/services/meteorology_service.dart';

class WeatherForecast {

  final _auxService = AuxService();
  final _meteorologyService = MeteorologyService();

  // content...

  StreamController _controller = StreamController();

  Sink get _input => _controller.sink;
  Stream get output => _controller.stream;

  void requestMeteorologyDataUntil3DaysByDay(int dayID) {

    _meteorologyService.fetchMeteorologyDataUntil3DaysByDay(dayID);

    _meteorologyService.output.listen((data) {

      _input.add(data);
    });
  }

  void _onRegionDataReceived(List data) {

    /*
    // Request data to service
    _auxService.fetchRegionDataList();

    // Wait for data to be written in stream
    _auxService.output.listen((data) {

      // Cast received data to List of RegionData
      List<RegionData> regionData = data as List;

      _onRegionDataReceived(regionData);
    });
     */
  }

  void dispose() {

    _auxService.dispose();

    _controller.close();
  }
}