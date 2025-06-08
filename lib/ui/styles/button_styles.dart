import 'package:flutter/material.dart';
class AppButtonStyles {
  static BoxDecoration curvedShadow = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(35)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.25),
        spreadRadius: 0,
        blurRadius: 6,
        offset: Offset(0, 6),
      ),
    ],
  );
  static BoxDecoration circularShadow = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(360)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.25),
        spreadRadius: 0,
        blurRadius: 4,
        offset: Offset(0, 4),
      ),
    ],
  );

  static ButtonStyle mainBackStyle = ButtonStyle(
    backgroundColor: WidgetStateProperty.all<Color>(Color(0xFF399E5A)),
  );

  static TextStyle mainTextStyle = TextStyle(
    fontSize: 20, 
    fontWeight: FontWeight.bold, 
    color: Colors.white,
    height: 2.5,
  );
}
