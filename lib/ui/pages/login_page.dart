import 'package:flutter/material.dart';
import 'package:fresh_planner/source/database/database_ingredients.dart';
import 'package:fresh_planner/source/database/database_user.dart';
import 'package:fresh_planner/ui/pages/main_page.dart';
import 'package:fresh_planner/ui/pages/shared/ingredients_page.dart';
import 'package:fresh_planner/ui/pages/shared/recipe_page.dart';
import 'package:fresh_planner/ui/styles/text_field_styles.dart';
import 'package:fresh_planner/ui/styles/text_styles.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final secondPasswordController = TextEditingController();

  final userDB = DatabaseUser();

  bool _isRegister = false;
  bool get isRegister => _isRegister;
  set isRegister(bool value) => setState(() => _isRegister = value);

  String _errorText = "";
  String get errorText => _errorText;
  set errorText(String value) => setState(() => _errorText = value);

  Future<void> checkPassword() async {
    final email = emailController.text;
    final password = passwordController.text;

    errorText = "";

    if (email.isEmpty || password.isEmpty) {
      errorText = "Please ensure all data is filled";
      return;
    }

    final userData = await userDB.loginUser(email, password);
    if (!userData.$1) {
      errorText = "Email or password is incorrect";
      return;
    }
    else if (userData.$2 == null) {
      errorText = "Internal server error, please try again";
      return;
    }
    final ingredientDB = DatabaseIngredients();
    final ingredientData = await ingredientDB.getAllIngredients(userData.$2!.uid!);
    if (ingredientData == null || !mounted) {
      errorText = "Internal server error, please try again";
      return;
    }
    
    ingredientData.sort();
    Navigator.push(
      context,
      //MaterialPageRoute(builder: (context) => IngredientsPage(user: userData.$2!, ingredients: ingredientData,)),
      MaterialPageRoute(builder: (context) => RecipePage(user: userData.$2!, ingredients: ingredientData,)),
    );
  }

  bool suitableEmail(String email) {
    final emailReg = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailReg.hasMatch(email);
  }

  Future<bool?> checkEmailExists() async {
    final data = await userDB.checkEmailExists(emailController.text);
    if (!data.$1) return null;
    return data.$2;
  }

  void registerAccount() async {
    final email = emailController.text;
    final username = usernameController.text;
    final firstPassword = passwordController.text;
    final secondPassword = secondPasswordController.text;

    errorText = "";

    if (email.isEmpty || username.isEmpty || firstPassword.isEmpty || secondPassword.isEmpty) {
      errorText = "Please ensure all data is filled";
      return;
    }

    if (!suitableEmail(email)) {
      errorText = "Please enter a suitable email";
      return;
    }

    if (firstPassword != secondPassword) {
      errorText = "Please ensure passwords match";
      return;
    }
    
    final emailCheck = await checkEmailExists();
    if (emailCheck == null) {
      errorText = "Internal server error, please try again";
      return;
    } else if (emailCheck) {
      errorText = "This email has already been registered";
      return;
    }

    final addingNewUser = await userDB.addNewUser(email, username, firstPassword);
    if (addingNewUser.$1 && addingNewUser.$2 != null) {
      await userDB.addDefaultIngredients(addingNewUser.$2!);
      isRegister = false;
    } else {
      errorText = "Internal server error, please try again";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Container(
                            transform: Matrix4.translationValues(
                              MediaQuery.of(context).size.width * .3, -35.0, 0.0
                            ),
                            child: RotationTransition(
                              turns: AlwaysStoppedAnimation(30 / 360),
                              child: Image(
                                image: AssetImage("assets/images/LogoHeart1.png"),
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 5,
                            left: 0,
                            right: 0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Login",
                                  style: AppTextStyles.mainTitle,
                                ),
                                SizedBox(height: 5,),
                                Text(
                                  "Welcome to Fresh Planning",
                                  style: AppTextStyles.subTitle,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Container(
                                decoration: AppTextFieldStyles.dropShadow,
                                child: TextField(
                                  controller: emailController,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  decoration: AppTextFieldStyles.primaryStyle("email")
                                ),
                              ),
                              Visibility(
                                visible: isRegister,
                                child: Column(
                                  children: [
                                    SizedBox(height: 20,),
                                    Container(
                                      decoration: AppTextFieldStyles.dropShadow,
                                      child: TextField(
                                        controller: usernameController,
                                        enableSuggestions: false,
                                        autocorrect: false,
                                        decoration: AppTextFieldStyles.primaryStyle("username")
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20,),
                              Container(
                                decoration: AppTextFieldStyles.dropShadow,
                                child: TextField(
                                  controller: passwordController,
                                  obscureText: true,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  decoration: AppTextFieldStyles.primaryStyle("password")
                                ),
                              ),
                              Visibility(
                                visible: isRegister,
                                child: Column(
                                  children: [
                                    SizedBox(height: 20,),
                                    Container(
                                      decoration: AppTextFieldStyles.dropShadow,
                                      child: TextField(
                                        controller: secondPasswordController,
                                        obscureText: true,
                                        enableSuggestions: false,
                                        autocorrect: false,
                                        decoration: AppTextFieldStyles.primaryStyle("re-enter password")
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                errorText,
                                style: TextStyle(
                                  fontSize: 14, 
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              ElevatedButton(
                                onPressed:
                                  isRegister ? registerAccount : checkPassword,
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all<Color>(Color(0xFF399E5A)),
                                ),
                                child: Text(
                                  isRegister ? '    Register    ' : '      Login      ',
                                  style: TextStyle(
                                    fontSize: 20, 
                                    fontWeight: FontWeight.bold, 
                                    color: Colors.white,
                                    height: 2.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20,),
                    ],
                  ),
                ),
              ),
              Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isRegister ? "Already a user? " : "New user? ",
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF979797),
                          ),
                      ),
                      GestureDetector(
                        onTap: () {
                          isRegister = !isRegister;
                        },
                        child: Text(
                          isRegister ? "Login here" : "Register here",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF399E5A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
