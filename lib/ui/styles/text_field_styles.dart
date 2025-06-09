import 'package:flutter/material.dart';
import 'package:fresh_planner/ui/styles/text_styles.dart';

/// Styles for text entry in the program, contains the boxes that hold them with shadows as well as the entries themselves
class AppTextFieldStyles {
  static InputDecoration primaryStyle(String hint, {Icon? icon}) { 
    return InputDecoration(filled: true,
      fillColor: const Color(0xFFd7f1e0),
      hintText: hint,
      hintStyle: AppTextStyles.hint,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
              width: 0,
              style: BorderStyle.none,
          ),
      ),
      prefixIcon: icon
    );
  }

  static BoxDecoration dropShadow = BoxDecoration(
    borderRadius: const BorderRadius.all(Radius.circular(10)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.25),
        spreadRadius: 0,
        blurRadius: 4,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration dropShadowWithColour = BoxDecoration(
    color: const Color(0xFFd7f1e0),
    borderRadius: const BorderRadius.all(Radius.circular(10)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.25),
        spreadRadius: 0,
        blurRadius: 4,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration altDropShadowWithColour = BoxDecoration(
    color: const Color(0xFF399E5A),
    borderRadius: const BorderRadius.all(Radius.circular(10)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.25),
        spreadRadius: 0,
        blurRadius: 4,
        offset: const Offset(0, 4),
      ),
    ],
  );
}