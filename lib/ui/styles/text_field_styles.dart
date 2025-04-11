import 'package:flutter/material.dart';
class AppTextFieldStyles {
  static InputDecoration primaryStyle(String hint) { 
    return InputDecoration(filled: true,
      fillColor: Color(0xFFd7f1e0),
      hintText: hint,
      hintStyle: TextStyle(
        color: Color(0x33000000),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              width: 0,
              style: BorderStyle.none,
          ),
      ),
    );
  }

  static BoxDecoration dropShadow = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.25),
        spreadRadius: 0,
        blurRadius: 4,
        offset: Offset(0, 4),
      ),
    ],
  );
}