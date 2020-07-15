import 'package:arduino_controller/splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';

import 'home_screen/home_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xff302b63),
        backgroundColor: Colors.grey.shade100,
        accentColor: Colors.white,
        fontFamily: 'Raleway',
        textTheme: TextTheme(
          bodyText2: TextStyle(color: Colors.grey.shade600),
        ),
      ),
      home: SplashScreen(),
    );
  }
}


