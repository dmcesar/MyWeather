import 'package:flutter/material.dart';
import 'package:myweather/screens/weather_forecast_screen.dart';

void main() => runApp(MyWeather());

class MyWeather extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'MyWeather',

      theme: ThemeData(primaryColor: Color.fromRGBO(58, 66, 86, 1.0)),
      
      home: WeatherForecastScreen(),
    );
  }
}

