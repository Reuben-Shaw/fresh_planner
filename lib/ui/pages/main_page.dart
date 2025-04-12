import 'package:flutter/material.dart';
import 'package:fresh_planner/source/objects/user.dart';
import 'package:fresh_planner/ui/widgets/flexi_box.dart';
import 'package:fresh_planner/ui/styles/text_styles.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.user});

  final User user;
  
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Main Page",
          style: AppTextStyles.mainTitle,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Adding a\nMeal",
                style: AppTextStyles.mainTitle,
              ),
              SizedBox(height: 5,),
              Row(
                children: [
                ],
              ),
              Text(
                "Welcome to Fresh Planning",
                style: AppTextStyles.subTitle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
