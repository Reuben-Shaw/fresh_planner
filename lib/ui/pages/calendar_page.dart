import 'package:flutter/material.dart';
import 'package:fresh_planner/ui/styles/text_styles.dart';

class EmptyPage extends StatefulWidget {
  const EmptyPage({super.key});

  @override
  State<EmptyPage> createState() => _EmptyPageState();
}

class _EmptyPageState extends State<EmptyPage> { 
  String _month = "January";
  String get month => _month;
  set month(String value) => setState(() => _month = value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget> [
                Text(
                  month
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
