import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
              buildRow('assets/images/nitr.png',
                  'NATIONAL INSTITUTE OF TECHNOLOGY, RAIPUR'),
              sizedBox('AND'),
              buildRow('assets/images/img1.jpg', 'AAYUSHMAN SOLUTIONS'),
              sizedBox('PRESENTS'),
              Container(
                height: 150,
                width: 250,
                margin: EdgeInsets.symmetric(vertical:50),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey
                ),
              ),
              sizedBox('LOREM IPSUM')
            ],
          ),
        ),
      ),
    );
  }

  Widget sizedBox(String text) {
    return SizedBox(
      height: 40,
      child: Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: Text(
          '$text',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget buildRow(String path, String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
        Expanded(
          child: Text(
            '$name',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
