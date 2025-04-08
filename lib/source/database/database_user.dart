import 'package:flutter/material.dart';
import 'package:fresh_planner/source/database/database_helper_user.dart';
import 'package:fresh_planner/source/objects/user.dart';

class DatabaseUser {
  final _database = DatabaseHelperUser();

  Future<(bool, User?)> loginUser(String email, String password) async {
    try {
      debugPrint("Attempting login");
      final response = await _database.loginUserAPI(email, password);

      bool success = response['success'] ?? false;
      if (success == true) {
        debugPrint("Login successful: ${response['message']}");

        final userData = response['user'];
        final User user = User.fromJson(userData);
        return (success, user);
      } else {
        debugPrint("Login failed: ${response['message'] ?? response['error'] ?? "!!NO ERROR OR MESSAGE!!"}");
      }
      return (success, null);
    } catch (e) {
      debugPrint("Login data caused a crash: $e");
      return (false, null);
    }
  }

  Future<(bool, bool)> checkEmailExists(String email) async {
    try {
      debugPrint("Checking email");
      final response = await _database.checkEmailExistsAPI(email);

      bool success = response['success'] ?? false;
      if (success == true) {
        debugPrint("Check was successful: ${response['message']}");
        return (success, response['exists'] as bool);
      } else {
        debugPrint("Check failed: ${response['error'] ?? "!!NO ERROR!!"}");
      }
      return (success, false);
    } catch (e) {
      debugPrint("Email check data caused a crash: $e");
      return (false, false);
    }
  }

  Future<(bool, String?)> addNewUser(String email, String username, String password) async {
    try {
      debugPrint("Adding new user");
      final response = await _database.addUserAPI(email, username, password);

      final result = response['success'] ?? response['error'] ?? (false, "!!NO ERROR!!", null);
      return (result.$1, result.$3);
    } catch (e) {
      debugPrint("Adding new user caused a crash: $e");
      return (false, null);
    }
  }

  Future<bool> addDefaultIngredients(String uid) async {
    try {
      debugPrint("Adding default ingredients");
      String json = r'{"uid":"'"$uid"r'","ingredients":[{"name":"flour","metric":"grams","type":"baking"},{"name":"white sugar","metric":"grams","type":"baking"},{"name":"brown sugar","metric":"grams","type":"baking"},{"name":"baking powder","metric":"grams","type":"baking"},{"name":"cocoa","metric":"grams","type":"baking"},{"name":"yeast","metric":"item","type":"baking"},{"name":"vanilla","metric":"ml","type":"baking"},{"name":"milk","metric":"ml","type":"dairy"},{"name":"cheddar","metric":"percentage","type":"dairy"},{"name":"double cream","metric":"ml","type":"dairy"},{"name":"heavy cream","metric":"ml","type":"dairy"},{"name":"parmesan","metric":"percentage","type":"dairy"},{"name":"egg","metric":"item","type":"dairy"},{"name":"mozzarella","metric":"item","type":"dairy"},{"name":"pasta","metric":"percentage","type":"driedGood"},{"name":"spaghetti","metric":"percentage","type":"driedGood"},{"name":"macaroni","metric":"percentage","type":"driedGood"},{"name":"rice","metric":"percentage","type":"driedGood"},{"name":"noodles","metric":"percentage","type":"driedGood"},{"name":"bread","metric":"percentage","type":"driedGood"},{"name":"tomato","metric":"item","type":"fruitNut"},{"name":"apple","metric":"item","type":"fruitNut"},{"name":"banana","metric":"item","type":"fruitNut"},{"name":"orange","metric":"item","type":"fruitNut"},{"name":"lemon","metric":"item","type":"fruitNut"},{"name":"lime","metric":"item","type":"fruitNut"},{"name":"cherry tomato","metric":"item","type":"fruitNut"},{"name":"cashew","metric":"item","type":"fruitNut"},{"name":"olive oil","metric":"percentage","type":"liquid"},{"name":"vegetabl eoil","metric":"percentage","type":"liquid"},{"name":"sesame seed oil","metric":"percentage","type":"liquid"},{"name":"vinegar","metric":"percentage","type":"liquid"},{"name":"white vinegar","metric":"ml","type":"liquid"},{"name":"balsamic vinegar","metric":"ml","type":"liquid"},{"name":"apple juice","metric":"percentage","type":"liquid"},{"name":"orange juice","metric":"percentage","type":"liquid"},{"name":"soy sauce","metric":"ml","type":"liquid"},{"name":"brown sauce","metric":"percentage","type":"liquid"},{"name":"ketchup","metric":"percentage","type":"liquid"},{"name":"fish sauce","metric":"ml","type":"liquid"},{"name":"white wine","metric":"ml","type":"liquid"},{"name":"red wine","metric":"ml","type":"liquid"},{"name":"mirin","metric":"ml","type":"liquid"},{"name":"beer","metric":"item","type":"liquid"},{"name":"cider","metric":"item","type":"liquid"},{"name":"chicken breast","metric":"item","type":"meat"},{"name":"chicken thigh","metric":"item","type":"meat"},{"name":"chicken whole","metric":"item","type":"meat"},{"name":"sausage","metric":"item","type":"meat"},{"name":"bacon","metric":"item","type":"meat"},{"name":"pork chop","metric":"item","type":"meat"},{"name":"pork loin","metric":"item","type":"meat"},{"name":"steak","metric":"item","type":"meat"},{"name":"minced meat","metric":"grams","type":"meat"},{"name":"salami","metric":"percentage","type":"meat"},{"name":"chorizo","metric":"percentage","type":"meat"},{"name":"pepperoni","metric":"percentage","type":"meat"},{"name":"lamb","metric":"item","type":"meat"},{"name":"salmon","metric":"item","type":"meat"},{"name":"cod","metric":"item","type":"meat"},{"name":"haddock","metric":"item","type":"meat"},{"name":"sea bass","metric":"item","type":"meat"},{"name":"basa","metric":"item","type":"meat"},{"name":"salt and vinegar crisps","metric":"item","type":"snack"},{"name":"salted crisps","metric":"item","type":"snack"},{"name":"cheese and onion crisps","metric":"item","type":"snack"},{"name":"prawn cocktail crisps","metric":"item","type":"snack"},{"name":"chocolate bar","metric":"item","type":"snack"},{"name":"biscuits","metric":"percentage","type":"snack"},{"name":"peanuts","metric":"percentage","type":"snack"},{"name":"seeds","metric":"percentage","type":"snack"},{"name":"sweets","metric":"percentage","type":"snack"},{"name":"thyme","metric":"percentage","type":"herbSpice"},{"name":"rosemary","metric":"percentage","type":"herbSpice"},{"name":"mint","metric":"percentage","type":"herbSpice"},{"name":"parsley","metric":"percentage","type":"herbSpice"},{"name":"paprika","metric":"ml","type":"herbSpice"},{"name":"cayenne pepper","metric":"ml","type":"herbSpice"},{"name":"red chili pepper","metric":"ml","type":"herbSpice"},{"name":"salt","metric":"percentage","type":"herbSpice"},{"name":"black pepper","metric":"percentage","type":"herbSpice"},{"name":"tumeric","metric":"ml","type":"herbSpice"},{"name":"dill","metric":"percentage","type":"herbSpice"},{"name":"oregano","metric":"ml","type":"herbSpice"},{"name":"sage","metric":"percentage","type":"herbSpice"},{"name":"star anise","metric":"percentage","type":"herbSpice"},{"name":"cloves","metric":"percentage","type":"herbSpice"},{"name":"baked beans","metric":"item","type":"preserve"},{"name":"tinned tomato","metric":"item","type":"preserve"},{"name":"olive","metric":"percentage","type":"preserve"},{"name":"tomato soup","metric":"item","type":"preserve"},{"name":"mayonnaise","metric":"item","type":"preserve"},{"name":"lentils","metric":"percentage","type":"preserve"},{"name":"kidney beans","metric":"percentage","type":"preserve"},{"name":"humus","metric":"percentage","type":"preserve"},{"name":"white onion","metric":"item","type":"vegetable"},{"name":"red onion","metric":"item","type":"vegetable"},{"name":"peas","metric":"percentage","type":"vegetable"},{"name":"carrot","metric":"item","type":"vegetable"},{"name":"cabbage","metric":"item","type":"vegetable"},{"name":"shallot","metric":"item","type":"vegetable"},{"name":"courgette","metric":"item","type":"vegetable"},{"name":"cauliflower","metric":"item","type":"vegetable"},{"name":"celery","metric":"item","type":"vegetable"},{"name":"spring onion","metric":"item","type":"vegetable"},{"name":"parsnip","metric":"item","type":"vegetable"},{"name":"baby potato","metric":"item","type":"vegetable"},{"name":"jacket potato","metric":"item","type":"vegetable"},{"name":"potato","metric":"item","type":"vegetable"},{"name":"sweet potato","metric":"item","type":"vegetable"},{"name":"bell pepper","metric":"item","type":"vegetable"},{"name":"red cabbage","metric":"item","type":"vegetable"},{"name":"lettuce","metric":"item","type":"vegetable"},{"name":"spinach","metric":"item","type":"vegetable"},{"name":"leek","metric":"item","type":"vegetable"},{"name":"mushrooms","metric":"percentage","type":"vegetable"}]}';

      final response = await _database.addIngredientJSONAPI(json);

      (bool, String) success = response['success'] ?? response['error'] ?? (false, "!!NO ERROR!!");
      return success.$1;
    } catch (e) {
      debugPrint("Adding default ingredients caused a crash: $e");
      return false;
    }
  }
}