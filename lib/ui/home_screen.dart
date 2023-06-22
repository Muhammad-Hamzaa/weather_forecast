import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late String temperature = '';
  late String humidity;
  late String windSpeed;
  late String weatherDescription;
  bool isCelsius = true;
  List<WeatherForecast> forecastList = [
    WeatherForecast(
      date: DateTime.now().add(Duration(days: 1)),
      temperature: 25.0,
      weatherDescription: 'Sunny',
    ),
    WeatherForecast(
      date: DateTime.now().add(Duration(days: 2)),
      temperature: 22.5,
      weatherDescription: 'Cloudy',
    ),
    WeatherForecast(
      date: DateTime.now().add(Duration(days: 3)),
      temperature: 20.0,
      weatherDescription: 'Rainy',
    ),
    WeatherForecast(
      date: DateTime.now().add(Duration(days: 4)),
      temperature: 18.0,
      weatherDescription: 'Thunderstorms',
    ),
    WeatherForecast(
      date: DateTime.now().add(Duration(days: 5)),
      temperature: 23.5,
      weatherDescription: 'Partly Cloudy',
    ),
  ];

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
    fetchForecastData();
  }

  Future<void> fetchWeatherData() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;

      String apiKey = 'YOUR_WEATHER_API_KEY';
      String url =
          'https://api.example.com/weather?lat=$latitude&lon=$longitude&appid=$apiKey';
      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);

        setState(() {
          temperature = jsonData['main']['temp'].toString();
          humidity = jsonData['main']['humidity'].toString();
          windSpeed = jsonData['wind']['speed'].toString();
          weatherDescription = jsonData['weather'][0]['description'];
        });
      } else {
        setState(() {
          temperature = 'N/A';
          humidity = 'N/A';
          windSpeed = 'N/A';
          weatherDescription = 'Failed to fetch weather data';
        });
      }
    } catch (e) {
      setState(() {
        temperature = 'N/A';
        humidity = 'N/A';
        windSpeed = 'N/A';
        weatherDescription = 'Error occurred: ${e.toString()}';
      });
    }
  }

  Future<void> fetchForecastData() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;

      String apiKey = 'YOUR_FORECAST_API_KEY';
      String url =
          'https://api.example.com/forecast?lat=$latitude&lon=$longitude&appid=$apiKey';
      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);

        List<dynamic> forecastData = jsonData['list'];
        List<WeatherForecast> forecasts = [];

        for (var data in forecastData) {
          WeatherForecast forecast = WeatherForecast(
            date: DateTime.fromMillisecondsSinceEpoch(data['dt'] * 1000),
            temperature: data['main']['temp'].toDouble(),
            weatherDescription: data['weather'][0]['description'],
          );
          forecasts.add(forecast);
        }

        setState(() {
          forecastList = forecasts;
        });
      } else {
        setState(() {
          forecastList = [];
        });
      }
    } catch (e) {
      setState(() {
        forecastList = [];
      });
    }
  }

  void toggleTemperatureUnit() {
    setState(() {
      isCelsius = !isCelsius;
    });
  }

  String getTemperatureDisplay(double temperature) {
    if (isCelsius) {
      return '${temperature.round()}°C';
    } else {
      double fahrenheit = (temperature * 9 / 5) + 32;
      return '${fahrenheit.round()}°F';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              'Weather App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.thermostat_rounded,
                        color: Colors.purpleAccent,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.purpleAccent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'Temperature Unit:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Fahrenheit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          value: isCelsius,
                          onChanged: (value) => toggleTemperatureUnit(),
                          activeColor: Colors.purpleAccent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Celsius',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),


          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Current Weather',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.all(8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: Container(
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: const Icon(Icons.wb_sunny, size: 40, color: Colors.deepPurple),
                    ),
                    title: Text(
                      'Temperature: ${temperature != null ? getTemperatureDisplay(double.tryParse(temperature) ?? 0.0) : 'N/A'}',
                      style: TextStyle(fontSize: 18, color: Colors.deepPurple),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Humidity: $humidity%', style: TextStyle(fontSize: 18, color: Colors.deepPurple)),
                        Text('Wind Speed: $windSpeed km/h', style: TextStyle(fontSize: 18, color: Colors.deepPurple)),
                        Text('Weather Description: $weatherDescription', style: TextStyle(fontSize: 18, color: Colors.deepPurple)),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '5-Day Forecast',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
               Column(
                 children: [
                   Container(
                     height: 50,
                     decoration: BoxDecoration(
                       color: Colors.white,
                       borderRadius: BorderRadius.circular(10),
                       boxShadow: [
                         BoxShadow(
                           color: Colors.purple.withOpacity(0.3),
                           spreadRadius: 2,
                           blurRadius: 4,
                           offset: Offset(0, 2),
                         ),
                       ],
                     ),
                     child: TextButton(
                       onPressed: () {
                         DatePicker.showDatePicker(context,
                             showTitleActions: true,
                             minTime: DateTime(2018, 3, 5),
                             maxTime: DateTime(2023, 6, 22), onChanged: (date) {
                               print('change $date');
                             }, onConfirm: (date) {
                               print('confirm $date');
                             }, currentTime: DateTime.now(), locale: LocaleType.en);
                       },
                       child: Text(
                         'show date time picker',
                         style: TextStyle(color: Colors.blue),
                       ),
                     ),
                   )
                 ],
               )

              ],
            ),
          ),

        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(
                Icons.home,
                color: Colors.purple,
              ),
              onPressed: () {
              },
            ),
            IconButton(
              icon: Icon(
                Icons.favorite,
                color: Colors.purple,
              ),
              onPressed: () {},
            ),
            SizedBox(width: 32),
            IconButton(
              icon: Icon(
                Icons.location_city,
                color: Colors.purple,
              ),
              onPressed: () {


              },
            ),
            SizedBox(width: 32),
            IconButton(
              icon: Icon(
                Icons.share,
                color: Colors.purple,
              ),
              onPressed: () {


              },
            ),
            SizedBox(width: 32),
            IconButton(
              icon: Icon(
                Icons.settings,
                color: Colors.purple,
              ),
              onPressed: () {


              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purpleAccent,
        child: Icon(Icons.add),
        onPressed: () {


        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );

  }
}

class WeatherForecast {
  final DateTime date;
  final double temperature;
  final String weatherDescription;

  WeatherForecast({
    required this.date,
    required this.temperature,
    required this.weatherDescription,
  });
}
