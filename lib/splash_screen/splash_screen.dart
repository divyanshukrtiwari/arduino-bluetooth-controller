import 'dart:async';

import 'package:arduino_controller/home_screen/home_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    Timer(
        Duration(seconds: 5),
        () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
            ));

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            tileMode: TileMode.clamp,
            colors: [
              Color(0xff0f0c29),
              Color(0xff302b63),
              Color(0xff24243e),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: buildRow('assets/images/nitr.png',
                    'NATIONAL INSTITUTE OF TECHNOLOGY, RAIPUR'),
              ),
              Center(child: sizedBox('AND', 18, 40)),
              Center(child: buildRow('assets/images/img1.jpg', 'AAYUSHMAN SOLUTIONS')),
              sizedBox('PRESENTS', 18, 40),
              Container(
                height: 160,
                width: 280,
                margin: EdgeInsets.symmetric(vertical: 50),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey,
                  image: DecorationImage(
                      image: AssetImage('assets/images/img2.jpg'),
                      fit: BoxFit.cover),
                ),
              ),
              sizedBox('CONTACTLESS UV DISINFECTING BOX', 22, 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget sizedBox(String text, double font, double height) {
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: Text(
          '$text',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: font,
            fontWeight: FontWeight.bold,
          ),
          softWrap: true,
        ),
      ),
    );
  }

  Widget buildRow(String path, String name) {
    return Row(
      //mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image:
                DecorationImage(image: AssetImage('$path'), fit: BoxFit.fill),
          ),
        ),
        SizedBox(width: 15),
        Text(
          '$name',
          softWrap: true,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
