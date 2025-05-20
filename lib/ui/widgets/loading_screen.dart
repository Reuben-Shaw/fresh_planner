import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Color(0x33000000),
      child: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF26693C),
          ),
        ),
    );
  }
}


