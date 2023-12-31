import 'package:flutter/material.dart';
import 'package:weather_forecast/ui/home_screen.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: HomeScreen.id,

      routes: {
        HomeScreen.id: (context) =>  HomeScreen(),
      },


    );
  }
}
