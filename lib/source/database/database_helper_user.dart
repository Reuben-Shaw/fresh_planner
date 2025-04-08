import 'dart:convert';
import 'package:http/http.dart' as http;

class DatabaseHelperUser {
  static const String _standardUrl = "-mueafkqufq-nw.a.run.app";
  static const String _loginUrl = "attemptuserlogin";
  static const String _passwordCheckUrl = "checkemailexists";

  Future<Map<String, dynamic>> loginUserAPI(String email, String password) async {
    try {
      final Uri url = Uri.parse("https://$_loginUrl$_standardUrl?email=$email&password=$password");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          return body;
        } else {
          return {"error": "Unexpected response format"};
        }
      } else {
        return {"error": "Login failed with status code ${response.statusCode}"};
      }
    } catch (e) {
      return {"error": "An error occurred: $e"};
    }
  }

  Future<Map<String, dynamic>> checkEmailExistsAPI(String email) async {
    try {
      final Uri url = Uri.parse("https://$_passwordCheckUrl$_standardUrl?email=$email");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          return body;
        } else {
          return {"error": "Unexpected response format"};
        }
      } else {
        return {"error": "Password check failed with status code ${response.statusCode}"};
      }
    } catch (e) {
      return {"error": "An error occurred: $e"};
    }
  }
}