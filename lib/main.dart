import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        backgroundColor: Colors.grey.shade100,
        accentColor: Colors.white,
        fontFamily: 'Raleway',
        textTheme: TextTheme(
          bodyText2: TextStyle(color: Colors.grey.shade600),
        ),
      ),
    );
  }
}