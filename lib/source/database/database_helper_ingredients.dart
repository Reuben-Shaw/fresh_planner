import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fresh_planner/source/enums/ingredient_food_type.dart';
import 'package:fresh_planner/source/enums/ingredient_metric.dart';
import 'package:http/http.dart' as http;

class DatabaseHelperIngredients {
  static const String _standardUrl = "-mueafkqufq-nw.a.run.app";
  static const String _getAllIngredientsUrl = "getingredients";
  static const String _removeIngredientUrl = "removeingredientforuser";
  static const String _addIngredientUrl = "addingredient";

  Future<Map<String, dynamic>> getAllIngredientsAPI(String uid) async {
    try {
      final Uri url = Uri.parse("https://$_getAllIngredientsUrl$_standardUrl?uid=$uid");
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

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

  Future<Map<String, dynamic>> removeIngredientAPI(String uid, String ingredientID) async {
    try {
      debugPrint("Ready to send off uid: $uid and id: $ingredientID");
      final Uri url = Uri.parse("https://$_removeIngredientUrl$_standardUrl?uid=$uid&ingredientID=$ingredientID");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          return body;
        } else {
          return {"error": "Unexpected response format"};
        }
      } else {
        return {"error": "Removal failed with status code ${response.statusCode}"};
      }
    } catch (e) {
      return {"error": "An error occurred: $e"};
    }
  }

  Future<Map<String, dynamic>> addIngredientAPI(String uid, String name, double? cost, IngredientMetric metric, IngredientType? type) async {
  try {
    final Uri url = Uri.parse("https://$_addIngredientUrl$_standardUrl");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'uid': uid,
        'name': name,
        'cost': cost,
        'metric': metric,
        'type': type,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final id = data['id'] as String?;
      if (id != null) {
        return {"success": true, "message": "New ingredient added successfully", "id": id};
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
