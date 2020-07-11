import 'package:flutter/material.dart';

BoxDecoration box = BoxDecoration(
  shape: BoxShape.circle,
  color: Colors.grey.shade100,
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.075),
      offset: Offset(10, 10),
      blurRadius: 10,
    ),
    BoxShadow(
      color: Colors.white,
      offset: Offset(-10, -10),
      blurRadius: 10,
    ),
  ],
);

BoxDecoration invertedbox = BoxDecoration(
  borderRadius: BorderRadius.circular(15),
  color: Colors.black.withOpacity(0.075),
  boxShadow: [
    BoxShadow(
        color: Colors.white,
        offset: Offset(3, 3),
        blurRadius: 3,
        spreadRadius: -3),
  ],
);
