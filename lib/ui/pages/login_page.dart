import 'package:flutter/material.dart' hide TimeOfDay;
import 'package:fresh_planner/source/database/database_calendar.dart';
import 'package:fresh_planner/source/database/database_ingredients.dart';
import 'package:fresh_planner/source/database/database_user.dart';
import 'package:fresh_planner/ui/pages/calendar/calendar_page.dart';
import 'package:fresh_planner/ui/styles.dart';
import 'package:fresh_planner/ui/widgets/loading_screen.dart';

/// Initial page shown by the program, manages loading all user data as well as validating login information
class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title, required this.userDB, required this.ingredientDB, required this.calendarDB});

  final String title;
  final DatabaseUser userDB;
  final DatabaseIngredients ingredientDB;
  final DatabaseCalendar calendarDB;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _secondPasswordController = TextEditingController();

  bool __isLoading = false;
  bool get _isLoading => __isLoading;
  set _isLoading(bool value) => setState(() => __isLoading = value);

  bool _isRegister = false;
  bool get isRegister => _isRegister;
  set isRegister(bool value) => setState(() => _isRegister = value);

  String _errorText = '';
  String get errorText => _errorText;
  set errorText(String value) => setState(() => _errorText = value);

  /// Performs login actions and error trapping to ensure that login is valid
  Future<void> _checkPassword() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    FocusManager.instance.primaryFocus?.unfocus();

    errorText = '';

    if (email.isEmpty || password.isEmpty) {
      errorText = 'Please ensure all data is filled';
      return;
    }

    _isLoading = true;

    final userData = await widget.userDB.loginUser(email, password);
    if (!userData.$1) {
      errorText = 'Email or password is incorrect';
      _isLoading = false;
      return;
    }
    else if (userData.$2 == null) {
      errorText = 'Internal server error, please try again';
      _isLoading = false;
      return;
    }

    // Tasks performed in parallel to reduce loading time
    final ingredientTask = widget.ingredientDB.getAllIngredients(userData.$2!.uid!);
    final recipeTask = widget.calendarDB.getAllRecipes(userData.$2!.uid!);
    final mealTask = widget.calendarDB.getAllMeals(userData.$2!.uid!);

    final ingredientData = await ingredientTask;
    final recipeData = await recipeTask;
    final mealData = await mealTask;

    if (ingredientData == null || recipeData == null || mealData == null || !mounted) {
      errorText = 'Internal server error, please try again';
      _isLoading = false;
      return;
    }
    
    _isLoading = false;

    ingredientData.sort();
    recipeData.sort();
    mealData.forEach((time, meals) {
      meals.sort();
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CalendarPage(user: userData.$2!, ingredients: ingredientData, recipes: recipeData, meals: mealData, calendarDB: widget.calendarDB,)),
    );
  }

  /// Assures that email has correct structure
  bool _suitableEmail(String email) {
    final emailReg = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailReg.hasMatch(email);
  }

  /// Database query to check if an email already exists when attempting to register a new one
  Future<bool?> _checkEmailExists() async {
    final data = await widget.userDB.checkEmailExists(_emailController.text);
    if (!data.$1) return null;
    return data.$2;
  }

  /// Performs all logic and error trapping for logging a new account with the systems
  void _registerAccount() async {
    final email = _emailController.text;
    final username = _usernameController.text;
    final firstPassword = _passwordController.text;
    final secondPassword = _secondPasswordController.text;

    FocusManager.instance.primaryFocus?.unfocus();

    errorText = '';

    if (email.isEmpty || username.isEmpty || firstPassword.isEmpty || secondPassword.isEmpty) {
      errorText = 'Please ensure all data is filled';
      return;
    }

    if (!_suitableEmail(email)) {
      errorText = 'Please enter a suitable email';
      return;
    }

    if (firstPassword != secondPassword) {
      errorText = 'Please ensure passwords match';
      return;
    }

    _isLoading = true;
    
    final emailCheck = await _checkEmailExists();
    if (emailCheck == null) {
      errorText = 'Internal server error, please try again';
      _isLoading = false;
      return;
    } else if (emailCheck) {
      errorText = 'This email has already been registered';
      _isLoading = false;
      return;
    }

    final addingNewUser = await widget.userDB.addNewUser(email, username, firstPassword);
    if (addingNewUser.$1 && addingNewUser.$2 != null) {
      await widget.userDB.addDefaultIngredients(addingNewUser.$2!);
      isRegister = false;
    } else {
      errorText = 'Internal server error, please try again';
    }
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Stack(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              // Static animation is used to offset the logo so part of it is cut off by the screen
                              Container(
                                transform: Matrix4.translationValues(
                                  MediaQuery.of(context).size.width * .3, -35.0, 0.0,
                                ),
                                child: const RotationTransition(
                                  turns: AlwaysStoppedAnimation(30 / 360),
                                  child: Image(
                                    image: AssetImage('assets/images/LogoHeart1.png'),
                                    fit: BoxFit.scaleDown,
                                  ),
                                ),
                              ),
                              const Positioned(
                                bottom: 5,
                                left: 0,
                                right: 0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Login',
                                      style: AppTextStyles.mainTitle,
                                    ),
                                    SizedBox(height: 5,),
                                    Text(
                                      'Welcome to Fresh Planning',
                                      style: AppTextStyles.subTitle,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Container(
                                    decoration: AppTextFieldStyles.dropShadow,
                                    child: TextField(
                                      key: const Key('email_textfield'),
                                      controller: _emailController,
                                      enableSuggestions: false,
                                      autocorrect: false,
                                      decoration: AppTextFieldStyles.primaryStyle('email'),
                                    ),
                                  ),
                                  Visibility(
                                    visible: isRegister,
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 20,),
                                        Container(
                                          decoration: AppTextFieldStyles.dropShadow,
                                          child: TextField(
                                            key: const Key('username_textfield'),
                                            controller: _usernameController,
                                            enableSuggestions: false,
                                            autocorrect: false,
                                            decoration: AppTextFieldStyles.primaryStyle('username'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20,),
                                  Container(
                                    decoration: AppTextFieldStyles.dropShadow,
                                    child: TextField(
                                      key: const Key('password_textfield'),
                                      controller: _passwordController,
                                      obscureText: true,
                                      enableSuggestions: false,
                                      autocorrect: false,
                                      decoration: AppTextFieldStyles.primaryStyle('password'),
                                    ),
                                  ),
                                  Visibility(
                                    visible: isRegister,
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 20,),
                                        Container(
                                          decoration: AppTextFieldStyles.dropShadow,
                                          child: TextField(
                                            key: const Key('reenter_password_textfield'),
                                            controller: _secondPasswordController,
                                            obscureText: true,
                                            enableSuggestions: false,
                                            autocorrect: false,
                                            decoration: AppTextFieldStyles.primaryStyle('re-enter password'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    errorText,
                                    style: const TextStyle(
                                      fontSize: 14, 
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Container(
                                    decoration: AppButtonStyles.curvedShadow,
                                    child: ElevatedButton(
                                      key: const Key('login_button'),
                                      onPressed:
                                        isRegister ? _registerAccount : _checkPassword,
                                      style: AppButtonStyles.mainBackStyle,
                                      child: Text(
                                        isRegister ? '    Register    ' : '      Login      ',
                                        style: AppButtonStyles.mainTextStyle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20,),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isRegister ? 'Already a user? ' : 'New user? ',
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
                              key: const Key('register_text'),
                              isRegister ? 'Login here' : 'Register here',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF399E5A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10,)
                    ],
                  ),
                ),
              ],
            ),
            Visibility(
              visible: _isLoading,
              child: const LoadingScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
