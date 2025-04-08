import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DatabaseHelperIngredients {
  static const String _standardUrl = "-mueafkqufq-nw.a.run.app";
  static const String _getAllIngredientsUrl = "getingredients";

  Future<Map<String, dynamic>> getAllIngredientsAPI(String uid) async {
  try {
    final Uri url = Uri.parse("https://$_getAllIngredientsUrl$_standardUrl?uid=$uid");
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      debugPrint(body.toString());

      if (body is Map<String, dynamic>) {
        return body;
      } else {
        return {"error": "Unexpected response format"};
      }
    } else {
      return {"error": "Request failed with status code ${response.statusCode}"};
    }
  } catch (e) {
    return {"error": "An error occurred: $e"};
  }
}

}