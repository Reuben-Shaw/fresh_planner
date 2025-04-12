import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DatabaseHelperCalendar {
  static const String _standardUrl = "-mueafkqufq-nw.a.run.app";
  static const String _addRecipeUrl = "addrecipe";
  
  Future<Map<String, dynamic>> addRecipeAPI(String uid, String name, String? link, List<(String, int)> ingredients, Color colour) async {
    try {
      final Uri url = Uri.parse("https://$_addRecipeUrl$_standardUrl");
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'uid': uid,
          'name': name,
          'link' : link,
          'ingredients': ingredients.map((e) => {'id': e.$1, 'amount': e.$2}).toList(),
          'colour' : colour.toString(),
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final id = data['id'] as String?;
        if (id != null) {
          return {"success": true, "message": "New recipe added successfully", "id": id};
        } else {
          return {"error": "ID not found in the response"};
        }
      } else {
        return {"error": "Failed with status code ${response.statusCode}"};
      }
    } catch (e) {
      return {"error": "An error occurred: $e"};
    }
  }
}
