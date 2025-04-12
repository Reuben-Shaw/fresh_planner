import 'package:flutter/material.dart';
import 'package:fresh_planner/ui/styles/text_styles.dart';

class AddMealPage extends StatefulWidget {
  const AddMealPage({super.key});

  @override
  State<AddMealPage> createState() => _AddMealPageState();
}

class _AddMealPageState extends State<AddMealPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Adding a\nMeal",
              style: AppTextStyles.mainTitle,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.sunny,
                  color: Color(0xFF979797),
                ),
                Text(
                  " - Lunchtime: 17/10/24",
                  style: AppTextStyles.subTitle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
