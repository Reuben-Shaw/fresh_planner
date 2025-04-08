import 'package:flutter/material.dart';
import 'package:fresh_planner/source/database/database_user.dart';
import 'package:fresh_planner/ui/pages/main_page.dart';
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

    final data = await userDB.loginUser(email, password);
    if (!data.$1) {
      errorText = "Email or password is incorrect";
      return;
    }
    else if (data.$2 == null || !mounted) {
      errorText = "Internal server error, please try again";
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MainPage(user: data.$2!,)),
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
    if (addingNewUser) {
      isRegister = false;
    } else {
      errorText = "Internal server error, please try again";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Login",
          style: AppTextStyles.mainTitle,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Welcome to Fresh Planning",
              style: AppTextStyles.subTitle,
            ),
            TextField(
              controller: emailController,
              cursorColor: Colors.black,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFFD7F1E0),
                hintText: 'email',
                hintStyle: TextStyle(
                  color: Color(0x33000000),
                  fontStyle: FontStyle.italic,
                ),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            Visibility(
              visible: isRegister,
              child: TextField(
                controller: usernameController,
                cursorColor: Colors.black,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFD7F1E0),
                  hintText: 'username',
                  hintStyle: TextStyle(
                    color: Color(0x33000000),
                    fontStyle: FontStyle.italic,
                  ),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
            ),
            TextField(
              controller: passwordController,
              cursorColor: Colors.black,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFFD7F1E0),
                hintText: 'password',
                hintStyle: TextStyle(
                  color: Color(0x33000000),
                  fontStyle: FontStyle.italic,
                ),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            Visibility(
              visible: isRegister,
              child: TextField(
                controller: secondPasswordController,
                cursorColor: Colors.black,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFD7F1E0),
                  hintText: 'confirm password',
                  hintStyle: TextStyle(
                    color: Color(0x33000000),
                    fontStyle: FontStyle.italic,
                  ),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
            ),
            Text(
              errorText
            ),
            ElevatedButton(
              onPressed:
                  isRegister ? registerAccount : checkPassword,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(
                    Colors.white),
                foregroundColor:
                    WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.hovered)) {
                      return Colors.white;
                    }
                    return const Color.fromARGB(
                        255, 30, 30, 30);
                  },
                ),
                overlayColor:
                    WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.hovered)) {
                      return Colors.blue;
                    }
                    return null;
                  },
                ),
              ),
              child: Text(
                isRegister ? 'Register' : 'Login',
              ),
            ),
            GestureDetector(
              onTap: () {
                isRegister = !isRegister;
              },
              child: Text(
                isRegister ? 'Login' : 'Register',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.red,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
