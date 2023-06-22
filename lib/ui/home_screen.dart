import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String temperature = '';
  String humidity = '';
  String windSpeed = '';
  String weatherDescription = '';

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    // Retrieve the user's current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Obtain the latitude and longitude of the user's location
    double latitude = position.latitude;
    double longitude = position.longitude;

    // Make a request to the weather API using the obtained coordinates
    String apiKey = 'YOUR_WEATHER_API_KEY';
    String url = 'https://api.example.com/weather?lat=$latitude&lon=$longitude&appid=$apiKey';
    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Parse the JSON response
      Map<String, dynamic> jsonData = json.decode(response.body);

      // Extract the weather information
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Current Weather',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Icon(
              Icons.wb_sunny,
              size: 80,
            ),
            SizedBox(height: 10),
            Text(
              'Temperature: $temperature°C',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Humidity: $humidity%',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Wind Speed: $windSpeed km/h',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Weather Description: $weatherDescription',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

