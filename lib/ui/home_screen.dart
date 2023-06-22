import 'package:flutter/material.dart';
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
  List<WeatherForecast> forecastList = [];

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
        backgroundColor: Colors.deepPurple,
        title: const Text('Weather App'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Temperature Unit: ',
                style: TextStyle(fontSize: 16),
              ),
              TextButton(
                onPressed: toggleTemperatureUnit,
                child: Text(
                  isCelsius ? 'Celsius' : 'Fahrenheit',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Current Weather',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.wb_sunny, size: 80),
                  title: Text(
                    'Temperature: ${temperature != null ? getTemperatureDisplay(double.tryParse(temperature) ?? 0.0) : 'N/A'}',
                    style: const TextStyle(fontSize: 18),
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Humidity: $humidity%', style: const TextStyle(fontSize: 18)),
                      Text('Wind Speed: $windSpeed km/h', style: const TextStyle(fontSize: 18)),
                      Text('Weather Description: $weatherDescription', style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    '5-Day Forecast',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: forecastList.length,
                  itemBuilder: (context, index) {
                    WeatherForecast forecast = forecastList[index];
                    return ListTile(
                      leading: Text(
                        forecast.date.day.toString(),
                        style: const TextStyle(fontSize: 18),
                      ),
                      title: Text(
                        'Temperature: ${getTemperatureDisplay(forecast.temperature)}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      subtitle: Text(
                        'Weather Description: ${forecast.weatherDescription}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
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

// void main() {
//   runApp(const MaterialApp(
//     home: HomeScreen(),
//   ));
// }
