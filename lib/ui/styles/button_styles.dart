import 'package:flutter/material.dart';
class AppButtonStyles {
  static BoxDecoration curvedShadow = BoxDecoration(
    borderRadius: const BorderRadius.all(Radius.circular(35)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.25),
        spreadRadius: 0,
        blurRadius: 6,
        offset: const Offset(0, 6),
      ),
    ],
  );
  static BoxDecoration circularShadow = BoxDecoration(
    borderRadius: const BorderRadius.all(Radius.circular(360)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.25),
        spreadRadius: 0,
        blurRadius: 4,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static ButtonStyle mainBackStyle = ButtonStyle(
    backgroundColor: WidgetStateProperty.all<Color>(const Color(0xFF399E5A)),
  );

  static TextStyle mainTextStyle = const TextStyle(
    fontSize: 20, 
    fontWeight: FontWeight.bold, 
    color: Colors.white,
    height: 2.5,
  );
}
