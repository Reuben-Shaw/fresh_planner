import 'package:flutter/material.dart';
import 'package:fresh_planner/ui/pages/main_page.dart';
import 'package:fresh_planner/ui/widgets/flexi_box.dart';
import 'package:fresh_planner/ui/styles/text_styles.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final secondPasswordController = TextEditingController();

  bool _isRegister = false;
  bool get isRegister => _isRegister;
  set isRegister(bool value) => setState(() => _isRegister = value);

  void checkPassword() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MainPage()),
    );
  }

  bool suitableEmail(String email) {
    final emailReg = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailReg.hasMatch(email);
  }

  bool emailExists(String email) {
    return true;
  }

  void registerAccount() async {
    String email = emailController.text;
    String firstPassword = passwordController.text;
    String secondPassword = secondPasswordController.text;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
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
          ],
        ),
      ),
    );
  }
}
