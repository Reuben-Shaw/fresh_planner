import 'package:flutter/material.dart';

class FlexiBox extends StatelessWidget {
  final double heightFactor;

  const FlexiBox({
    super.key,
    this.heightFactor = 0.1,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: FractionallySizedBox(
        heightFactor: heightFactor,
      ),
    );
  }
}
