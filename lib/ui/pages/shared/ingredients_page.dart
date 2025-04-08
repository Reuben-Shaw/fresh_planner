import 'package:flutter/material.dart';
import 'package:fresh_planner/ui/styles/text_styles.dart';

class IngredientsPage extends StatefulWidget {
  const IngredientsPage({super.key});

  @override
  State<IngredientsPage> createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Text(
                  "Ingredients"
                ),
                ElevatedButton(
                  onPressed: null, 
                  child: Text(
                    "+"
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
