import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:myweather/app_localizations.dart';
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

  // BLoC
  final _weatherForecast = WeatherForecast();

  // Handles map events
  GoogleMapController _mapController;

  // Location related
  Location location = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  // Map's center coordinates and bounds
  LatLngBounds _bounds;
  LatLng _center;

  // Map elements
  Set<Marker> _markers = HashSet<Marker>();

  // Map elements' Ids
  int _markerIdCnt = 1;

  // Used to toggle buttons' states
  bool _todayButSelected = true;
  bool _tomorrowButSelected = false;
  bool _overmorrowButSelected = false;

  // Button's selected color
  final Color _selectedButColor = Colors.amber;

  // Button's default color
  final Color _defaultButColor = Colors.white;


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

    // Get devices localization
    final Locale myLocale = Localizations.localeOf(context);

    // Create instance of AppLocalizations to internationalize app
    final AppLocalizations appLocalizations = AppLocalizations(myLocale);

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
                      color: Colors.black54,
                      child: Text(
                        appLocalizations.today,
                        style: TextStyle(
                            color: _todayButSelected ? _selectedButColor : _defaultButColor,
                        ),
                      ),
                      onPressed: () => setState(() =>
                      // ignore: sdk_version_set_literal
                      {
                        _todayButSelected = !_todayButSelected,
                        _tomorrowButSelected = false,
                        _overmorrowButSelected = false,
                      }),
                    ),
                  ),
                  Expanded(
                    child: RaisedButton(
                      color: Colors.black54,
                      child: Text(
                        appLocalizations.tomorrow,
                        style: TextStyle(
                            color: _tomorrowButSelected ? _selectedButColor : _defaultButColor,
                        ),
                      ),
                      onPressed: () => setState(() =>
                      // ignore: sdk_version_set_literal
                      {
                        _tomorrowButSelected = !_tomorrowButSelected,
                        _todayButSelected = false,
                        _overmorrowButSelected = false,
                      }),
                    ),
                  ),
                  Expanded(
                    child: RaisedButton(
                      color: Colors.black54,
                      child: Text(
                        appLocalizations.overmorrow,
                        style: TextStyle(
                            color: _overmorrowButSelected ? _selectedButColor : _defaultButColor,
                        ),
                      ),
                      onPressed: () => setState(() =>
                      // ignore: sdk_version_set_literal
                      {
                        _overmorrowButSelected = !_overmorrowButSelected,
                        _todayButSelected = false,
                        _tomorrowButSelected = false,
                      }),
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