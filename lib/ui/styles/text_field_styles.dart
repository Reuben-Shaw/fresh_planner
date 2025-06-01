import 'package:flutter/material.dart';
import 'package:fresh_planner/ui/styles/text_styles.dart';
class AppTextFieldStyles {
  static InputDecoration primaryStyle(String hint, {Icon? icon}) { 
    return InputDecoration(filled: true,
      fillColor: Color(0xFFd7f1e0),
      hintText: hint,
      hintStyle: AppTextStyles.hint,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              width: 0,
              style: BorderStyle.none,
          ),
      ),
      prefixIcon: icon
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

  static BoxDecoration dropShadowWithColour = BoxDecoration(
    color: Color(0xFFd7f1e0),
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

  static BoxDecoration altDropShadowWithColour = BoxDecoration(
    color: Color(0xFF399E5A),
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