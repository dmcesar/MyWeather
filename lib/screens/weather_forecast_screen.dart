import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:myweather/blocs/weather_forecast.dart';
import 'package:myweather/models/geo_json.dart';
import 'package:myweather/models/meteorology_data.dart';

class WeatherForecastScreen extends StatefulWidget {

  static const routeName = "/weather-forecast";

  WeatherForecastScreen({Key key}) : super(key: key);

  @override
  _WeatherForecastScreenState createState() => _WeatherForecastScreenState();
}

class _WeatherForecastScreenState extends State<WeatherForecastScreen> {

  final _weatherForecast = WeatherForecast();

  GoogleMapController _mapController;

  Location location = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  LatLngBounds _bounds;
  LatLng _center;

  // Map elements
  Set<Marker> _markers = HashSet<Marker>();
  final Color _selectedColor = Colors.amber;

  // Map elements' Ids
  int _markerIdCnt = 1;

  @override
  void initState() {
    _checkLocationPermission();

    if (_locationData != null) {
      _center =
          LatLng(_locationData.latitude, _locationData.longitude);
    } else {
      _center =
          LatLng(GeoJson.CENTER_COORDINATES[0], GeoJson.CENTER_COORDINATES[1]);
    }
    _bounds = LatLngBounds(
        northeast: LatLng(
          GeoJson.NORTHEAST_BOUND[0],
          GeoJson.NORTHEAST_BOUND[1],
        ),
        southwest: LatLng(
          GeoJson.SOUTHWEST_BOUND[0],
          GeoJson.SOUTHWEST_BOUND[1],
        )
    );

    // Request weather data for the day
    _weatherForecast.requestMeteorologyDataUntil3DaysByDay(0);

    // Listen for async response from stream
    _weatherForecast.output.listen((data) {

      // Cast received data to List of MeteorologyData
      final List<MeteorologyData> meteorologyData = data as List;

      // Pin markers to map
      _pinMarkers(meteorologyData);
    });

    super.initState();
  }

  void _checkLocationPermission() async {

    _serviceEnabled = await location.serviceEnabled();
    if(!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if(!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if(_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if(_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();

    if(_mapController != null) {

      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              _locationData.latitude,
              _locationData.longitude,
            ),
            zoom: 6,
          ),
        ),
      );
    }
  }

  void _pinMarkers(List<MeteorologyData> data) {

    data.forEach( (element) {

      final String markerIdVal = 'marker_id_${_markerIdCnt++}';

      setState(() {

        print('Added Marker | Latitude: ${element
            .latitude} | Longitude: ${element.longitude}');

        _markers.add(Marker(
          markerId: MarkerId(markerIdVal),
          position: LatLng(
            double.parse(element.latitude),
            double.parse(element.longitude),
          ),
          consumeTapEvents: true,
        ));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(

        appBar: AppBar(
          title: const Text('MyWeather'),
        ),

        body: Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 6,
              ),
              mapType: MapType.satellite,
              cameraTargetBounds: CameraTargetBounds(
                _bounds,
              ),
              buildingsEnabled: false,
              trafficEnabled: false,
              compassEnabled: true,
              zoomControlsEnabled: false,
              markers: _markers,
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      color: Colors.white,
                      child: Text(
                        "TODAY",
                        style: TextStyle(color: _selectedColor),
                      ),
                    ),
                  ),
                  Expanded(
                    child: RaisedButton(
                      color: Colors.black54,
                      child: Text(
                        "TOMOROW",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Expanded(
                    child: RaisedButton(
                      color: Colors.black54,
                      child: Text(
                        "OVERMORROW",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
    );
  }

  @override
  void dispose() {

    _weatherForecast.dispose();
    super.dispose();
  }
}