import 'package:flutter/material.dart';

import 'home_screen.dart';

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
        appBarTheme: AppBarTheme(
          color: Colors.grey.shade100,
          elevation: 1,
          actionsIconTheme: IconThemeData(color: Colors.grey.shade600),
          textTheme: TextTheme(
            headline6: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 26,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      home: HomeScreen(),
    );
  }
}
