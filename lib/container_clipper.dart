import 'package:flutter/material.dart';

class BackgroundClipper extends CustomClipper<Path> {

 
  BackgroundClipper({@required this.isPrevious});
  bool isPrevious;

  @override
  Path getClip(Size size) {
    var path = Path();
    if (isPrevious) {
      path.moveTo(0, 10);
      path.quadraticBezierTo(0, 0, 10, 0);
      path.lineTo(50, 0);
      path.quadraticBezierTo(50, 30, 80, 30);
      path.lineTo(80, 50);
      path.lineTo(10, 50);
      path.quadraticBezierTo(0, 50, 0, 40);
      path.lineTo(0, 10);
    } else {
      path.moveTo(0, 30);
      path.quadraticBezierTo(30, 30, 30, 0);
      path.lineTo(70, 0);
      path.quadraticBezierTo(80, 0, 80, 10);
      path.lineTo(80, 40);
      path.quadraticBezierTo(80, 50, 70, 50);
      path.lineTo(0, 50);
      path.lineTo(0, 30);
    }

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}