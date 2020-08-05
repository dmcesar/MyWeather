import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:date_format/date_format.dart';
import 'package:flutter/services.dart';
import 'package:myweather/models/meteorology_data.dart';
import 'package:myweather/models/weather_descriptor_data.dart';
import 'package:myweather/services/aux_service.dart';
import 'package:myweather/services/meteorology_service.dart';

class WeatherForecast {

  final _auxService = AuxService();
  final _meteorologyService = MeteorologyService();

  StreamController _controller = StreamController();

  Sink get _input => _controller.sink;
  Stream get output => _controller.stream;

  void requestMeteorologyDataUntil3DaysByDay(int dayID) {

    _meteorologyService.fetchMeteorologyDataUntil3DaysByDay(dayID);

    _meteorologyService.output.listen((data) {

      _input.add(data);
    });
  }

  Future<List<WeatherDescriptor>> requestWeatherDescriptors() async {

    // Request async weather descriptors
    return await _auxService.fetchWeatherDescriptors();
  }

  Future<Uint8List> getMarkerIcon(List<WeatherDescriptor> weatherDescriptors, MeteorologyData data) async {

    for(var cnt = 0; cnt < weatherDescriptors.length; cnt++)

      if(weatherDescriptors[cnt].idWeatherType == data.idWeatherType) {

        // IDs match.
        // TODO: Return associated asset
      }

    return await _getBytesFromAsset('lib/assets/cloudy.png', 90);
  }

  // Returns Uint8List from Asset to create GoogleMap's icons
  Future<Uint8List> _getBytesFromAsset(String path, int width) async {

    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();

    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
  }

  void dispose() {

    _auxService.dispose();
    _meteorologyService.dispose();
    _controller.close();
  }
}