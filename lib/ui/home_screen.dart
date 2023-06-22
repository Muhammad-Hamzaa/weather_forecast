import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share/share.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String temperature = '';
  String humidity = '';
  String windSpeed = '';
  String weatherDescription = '';
  String uvIndex = '';
  String sunriseTime = '';
  String sunsetTime = '';
  String precipitationChance = '';
  bool isCelsius = true;
  List<WeatherForecast> forecastList = [];
  List<String> favoriteLocations = [];

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
    fetchForecastData();
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
        uvIndex = jsonData['uvIndex'].toString();
        sunriseTime = jsonData['sys']['sunrise'].toString();
        sunsetTime = jsonData['sys']['sunset'].toString();
        precipitationChance = jsonData['precipitation']['chance'].toString();
      });
    } else {
      setState(() {
        temperature = 'N/A';
        humidity = 'N/A';
        windSpeed = 'N/A';
        weatherDescription = 'Failed to fetch weather data';
        uvIndex = 'N/A';
        sunriseTime = 'N/A';
        sunsetTime = 'N/A';
        precipitationChance = 'N/A';
      });
    }
  }

  Future<void> fetchForecastData() async {
    // Retrieve the user's current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Obtain the latitude and longitude of the user's location
    double latitude = position.latitude;
    double longitude = position.longitude;

    // Make a request to the forecast API using the obtained coordinates
    String apiKey = 'YOUR_FORECAST_API_KEY';
    String url = 'https://api.example.com/forecast?lat=$latitude&lon=$longitude&appid=$apiKey';
    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Parse the JSON response
      Map<String, dynamic> jsonData = json.decode(response.body);

      // Extract the forecast information for the next 5 days
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
      // Failed to fetch forecast data
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

  void addToFavorites() async {
    // Retrieve the user's current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Obtain the latitude and longitude of the user's location
    double latitude = position.latitude;
    double longitude = position.longitude;

    if (!favoriteLocations.contains('$latitude,$longitude')) {
      favoriteLocations.add('$latitude,$longitude');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location added to favorites')),
      );
    }
  }

  void shareForecast() {
    String forecast = '';
    for (var data in forecastList) {
      forecast += '${data.date.day.toString()}: ${getTemperatureDisplay(data.temperature)} - ${data.weatherDescription}\n';
    }
    Share.share('Weather forecast:\n\n$forecast');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: Column(
        children: [
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Temperature Unit: ',
                style: TextStyle(fontSize: 16),
              ),
              TextButton(
                onPressed: toggleTemperatureUnit,
                child: Text(
                  isCelsius ? 'Celsius' : 'Fahrenheit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
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
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.wb_sunny, size: 80),
                  title: Text(
                    'Temperature: ${getTemperatureDisplay(double.parse(temperature))}',
                    style: TextStyle(fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Humidity: $humidity%', style: TextStyle(fontSize: 18)),
                      Text('Wind Speed: $windSpeed km/h', style: TextStyle(fontSize: 18)),
                      Text('Weather Description: $weatherDescription', style: TextStyle(fontSize: 18)),
                      Text('UV Index: $uvIndex', style: TextStyle(fontSize: 18)),
                      Text('Sunrise: $sunriseTime', style: TextStyle(fontSize: 18)),
                      Text('Sunset: $sunsetTime', style: TextStyle(fontSize: 18)),
                      Text('Precipitation Chance: $precipitationChance%', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
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
                  physics: ClampingScrollPhysics(),
                  itemCount: forecastList.length,
                  itemBuilder: (context, index) {
                    WeatherForecast forecast = forecastList[index];
                    return ListTile(
                      leading: Text(
                        forecast.date.day.toString(),
                        style: TextStyle(fontSize: 18),
                      ),
                      title: Text(
                        'Temperature: ${getTemperatureDisplay(forecast.temperature)}',
                        style: TextStyle(fontSize: 18),
                      ),
                      subtitle: Text(
                        'Weather Description: ${forecast.weatherDescription}',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: addToFavorites,
                child: Text('Add to Favorites'),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: shareForecast,
                child: Text('Share Forecast'),
              ),
            ],
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
