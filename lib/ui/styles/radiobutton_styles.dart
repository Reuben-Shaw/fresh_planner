import 'package:flutter/material.dart';

class AppRadiobuttonStyle {
  static Row tileDec(BuildContext context, String title, Radio radioButton){
    return Row(
      children: <Widget>[
        Theme(
          data: Theme.of(context).copyWith(
            radioTheme: RadioThemeData(
              fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF26693C);
                }
                return const Color(0xFF26693C);
              }),
              visualDensity: VisualDensity.compact,
            ),
          ),
          child: radioButton,
        ),
        Text(title),
      ],
    );
  }
}

