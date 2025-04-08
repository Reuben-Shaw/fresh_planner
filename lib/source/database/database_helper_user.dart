import 'dart:convert';
import 'package:http/http.dart' as http;

class DatabaseHelperUser {
  static const String _loginUrl = "http://10.0.2.2:5001/fresh-planner-backend/us-central1/attemptUserLogin";

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final Uri url = Uri.parse("$_loginUrl?email=$email&password=$password");
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
}