import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:myweather/app_localizations.dart';
import 'package:myweather/blocs/weather_forecast.dart';
import 'package:myweather/models/geo_json.dart';
import 'package:myweather/models/meteorology_data.dart';
import 'package:date_format/date_format.dart';
import 'package:myweather/models/weather_descriptor_data.dart';

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
  Set<Polygon> _polygons = HashSet<Polygon>();
  Set<Marker> _markers = HashSet<Marker>();

  BitmapDescriptor markerIcon;

  // Map elements' Ids
  int _polygonIdCnt = 1;
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

    _initMapArgs();

    // Request weather data for the day
    _weatherForecast.requestMeteorologyDataUntil3DaysByDay(0);

    // Listen for async response from stream
    _weatherForecast.output.listen((data) async {

      // Cast received data to List of MeteorologyData
      final List<MeteorologyData> meteorologyData = data as List;

      _createMarkers(meteorologyData);

      // Return from async thread
      return;
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
            zoom: 7,
          ),
        ),
      );
    }
  }

  void _initMapArgs() {
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

    for (int cntPolygons = 0; cntPolygons <
        GeoJson.BORDERS.length; cntPolygons++) {
      List<LatLng> points = List();

      for (int cntPoints = 0; cntPoints <
          GeoJson.BORDERS[cntPolygons].length; cntPoints++) {
        points.add(
            LatLng(
                GeoJson.BORDERS[cntPolygons][cntPoints][1],
                GeoJson.BORDERS[cntPolygons][cntPoints][0]
            )
        );
      }

      final String polygonIdVal = 'polygon_id_${_polygonIdCnt++}';

      _polygons.add(
          Polygon(
            polygonId: PolygonId(polygonIdVal),
            points: points,
            consumeTapEvents: true,
            strokeColor: _selectedButColor,
            strokeWidth: 1,
            fillColor: Colors.transparent,
          )
      );
    }
  }

  // Returns future list of markers
  void _createMarkers(List<MeteorologyData> data) async {

    // Await for weather descriptors list
    List<WeatherDescriptor> weatherDescriptors = await _weatherForecast.requestWeatherDescriptors();

    List<Marker> markers = List();

    // For each element received, create a marker
    for(MeteorologyData element in data) {

      // Generate marker ID
      final String markerIdVal = 'marker_id_${_markerIdCnt++}';

      // Get icon for marker according to element data
      final Uint8List markerIcon = await _weatherForecast.getMarkerIcon(weatherDescriptors, element);

      // Generate marker
      Marker marker = Marker(
        markerId: MarkerId(markerIdVal),
        position: LatLng(
          double.parse(element.latitude),
          double.parse(element.longitude),
        ),
        icon: BitmapDescriptor.fromBytes(markerIcon),
        consumeTapEvents: false,
      );

      // Add marker to list
      markers.add(marker);
    }


    // Update markers collection
    _pinMarkers(markers);
  }

  // Updates Collection of markers
  void _pinMarkers(List<Marker> markers) {

    setState(() {

      _markers.addAll(markers);
    });
  }

  String _getTodayDate() {

    final DateTime now = DateTime.now();

    return formatDate(
        now,
        [dd, "/", mm],
    );
  }

  String _getTomorrowDate() {

    final DateTime now = DateTime.now();

    final DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);

    return formatDate(
      tomorrow,
      [dd, "/", mm],
    );  }

  String _getOvermorrowDate() {

    final DateTime now = DateTime.now();

    final DateTime overmorrow = DateTime(now.year, now.month, now.day + 2);

    return formatDate(
      overmorrow,
      [dd, "/", mm],
    );
  }

  @override
  Widget build(BuildContext context) {

    // Create instance of AppLocalizations to internationalize app
    final AppLocalizations appLocalizations = AppLocalizations(Localizations.localeOf(context));

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
              ),
              minMaxZoomPreference: MinMaxZoomPreference(6.0, 7.0),
              mapType: MapType.satellite,
              cameraTargetBounds: CameraTargetBounds(
                _bounds,
              ),
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
              buildingsEnabled: false,
              trafficEnabled: false,
              compassEnabled: true,
              zoomControlsEnabled: false,
              markers: _markers,
              polygons: _polygons,
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      color: Colors.black54.withOpacity(0.25),
                      child: Text(
                        _getTodayDate(),
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
                      color: Colors.black54.withOpacity(0.25),
                      child: Text(
                        _getTomorrowDate(),
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
                      color: Colors.black54.withOpacity(0.25),
                      child: Text(
                        _getOvermorrowDate(),
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