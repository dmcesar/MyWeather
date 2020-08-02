import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:myweather/models/geo_json.dart';

class WeatherForecastScreen extends StatefulWidget {

  static const routeName = "/weather-forecast";

  WeatherForecastScreen({Key key}) : super(key: key);

  @override
  _WeatherForecastScreenState createState() => _WeatherForecastScreenState();
}

class _WeatherForecastScreenState extends State<WeatherForecastScreen> {

  GoogleMapController _mapController;

  Location location = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  LatLngBounds _bounds;
  LatLng _center;

  @override
  void initState() {

    _checkLocationPermission();

    if(_locationData != null) {

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
            ),
          ],
        )
    );
  }
}