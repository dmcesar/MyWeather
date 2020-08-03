import 'package:flutter/material.dart';
import 'package:myweather/app_localizations.dart';
import 'package:myweather/screens/weather_forecast_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(MyWeather());

class MyWeather extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      title: 'MyWeather',

      debugShowCheckedModeBanner: false,

      theme: ThemeData(primaryColor: Color.fromRGBO(58, 66, 86, 1.0)),

      home: WeatherForecastScreen(),

      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],

      supportedLocales: [
        const Locale('en', ''), // English, no country code
        const Locale('pt', ''), // Portuguese, no country code
      ],
    );
  }
}

