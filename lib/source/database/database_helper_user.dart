import 'dart:convert';
import 'package:http/http.dart' as http;

class DatabaseHelperUser {
  static const String _standardUrl = '-mueafkqufq-nw.a.run.app';
  static const String _loginUrl = 'attemptuserlogin';
  static const String _passwordCheckUrl = 'checkemailexists';
  static const String _addUserUrl = 'adduser';
  static const String _addIngredientListUrl = 'addingredientsforuser';

  Future<Map<String, dynamic>> loginUserAPI(String email, String password) async {
    try {
      final Uri url = Uri.parse('https://$_loginUrl$_standardUrl?email=$email&password=$password');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          return body;
        } else {
          return {'error': 'Unexpected response format'};
        }
      } else {
        return {'error': 'Login failed with status code ${response.statusCode}'};
      }
    } catch (e) {
      return {'error': 'An error occurred: $e'};
    }
  }

  Future<Map<String, dynamic>> checkEmailExistsAPI(String email) async {
    try {
      final Uri url = Uri.parse('https://$_passwordCheckUrl$_standardUrl?email=$email');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          return body;
        } else {
          return {'error': 'Unexpected response format'};
        }
      } else {
        return {'error': 'Password check failed with status code ${response.statusCode}'};
      }
    } catch (e) {
      return {'error': 'An error occurred: $e'};
    }
  }

  Future<Map<String, dynamic>> addUserAPI(String email, String username, String password) async {
    try {
      final Uri url = Uri.parse('https://$_addUserUrl$_standardUrl');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final uid = data['uid'] as String?;
        if (uid != null) {
          return {'success': true, 'message': 'User added successfully', 'uid': uid};
        } else {
          return {'error': 'UID not found in the response'};
        }
      } else {
        return {'error': 'Failed with status code ${response.statusCode}'};
      }
    } catch (e) {
      return {'error': 'An error occurred: $e'};
    }
  }

  Future<Map<String, dynamic>> addIngredientJSONAPI(String json) async {
    try {
      final Uri url = Uri.parse('https://$_addIngredientListUrl$_standardUrl');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json,
      );

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Successfully added ingredients'};
      } else {
        return {'error': 'Failed with status code ${response.statusCode}'};
      }
    } catch (e) {
      return {'error': 'An error occurred: $e'};
    }
  }
}