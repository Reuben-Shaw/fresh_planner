import 'package:flutter/material.dart';
import 'package:fresh_planner/source/database/database_helper_user.dart';
import 'package:fresh_planner/source/objects/user.dart';

class DatabaseUser {
  final _database = DatabaseHelperUser();

  Future<(bool, User?)> loginUser(String email, String password) async {
    try {
      debugPrint('Attempting login');
      final response = await _database.loginUserAPI(email, password);

      bool success = response['success'] as bool? ?? false;
      if (success) {
        debugPrint('Login successful: ${response['message']}');

        final userData = response['user'];
        final User user = User.fromJson(userData);
        return (success, user);
      } else {
        debugPrint('Login failed: ${response['message'] ?? response['error'] ?? '!!NO ERROR OR MESSAGE!!'}');
      }
      return (success, null);
    } catch (e) {
      debugPrint('Login data caused a crash: $e');
      return (false, null);
    }
  }

  Future<(bool, bool)> checkEmailExists(String email) async {
    try {
      debugPrint('Checking email');
      final response = await _database.checkEmailExistsAPI(email);

      bool success = response['success'] as bool? ?? false;
      if (success) {
        debugPrint('Check was successful: ${response['message']}');
        return (success, response['exists'] as bool);
      } else {
        debugPrint('Check failed: ${response['message'] ?? response['error'] ?? '!!NO ERROR OR MESSAGE!!'}');
      }
      return (success, false);
    } catch (e) {
      debugPrint('Email check data caused a crash: $e');
      return (false, false);
    }
  }

  Future<(bool, String?)> addNewUser(String email, String username, String password) async {
    try {
      debugPrint('Adding new user');
      final response = await _database.addUserAPI(email, username, password);
      
      bool success = response['success'] as bool? ?? false;
      if (success) {
        debugPrint('User added successfully: ${response['message']}');
        return (true, response['uid'] as String?);
      } else {
        debugPrint('User addition failed: ${response['message'] ?? response['error'] ?? '!!NO ERROR OR MESSAGE!!'}');
      }

      return (false, null);
    } catch (e) {
      debugPrint('Adding new user caused a crash: $e');
      return (false, null);
    }
  }

  Future<bool> addDefaultIngredients(String uid) async {
    try {
      debugPrint('Adding default ingredients');

      String json = r'{"uid":"''$uid'r'","ingredients":[{"name":"flour","metric":"grams","type":"baking","cost":0.78,"costAmount":1500},{"name":"white sugar","metric":"grams","type":"baking","cost":1.49,"costAmount":1000},{"name":"brown sugar","metric":"grams","type":"baking","cost":1.6,"costAmount":500},{"name":"baking powder","metric":"grams","type":"baking","cost":0.61,"costAmount":160},{"name":"cocoa","metric":"grams","type":"baking","cost":3.15,"costAmount":250},{"name":"yeast","metric":"item","type":"baking","cost":1.5,"costAmount":8},{"name":"vanilla","metric":"ml","type":"baking","cost":1.3,"costAmount":60},{"name":"milk","metric":"ml","type":"dairy","cost":1.65,"costAmount":2270},{"name":"cheddar","metric":"percentage","type":"dairy","cost":3.15,"costAmount":400},{"name":"double cream","metric":"ml","type":"dairy","cost":1.39,"costAmount":300},{"name":"heavy cream","metric":"ml","type":"dairy","cost":1.9,"costAmount":300},{"name":"parmesan","metric":"grams","type":"dairy","cost":3.75,"costAmount":200},{"name":"egg","metric":"item","type":"dairy","cost":3.15,"costAmount":12},{"name":"mozzarella","metric":"item","type":"dairy","cost":1.5,"costAmount":1},{"name":"pasta","metric":"percentage","type":"driedGood","cost":1.29,"costAmount":100},{"name":"spaghetti","metric":"percentage","type":"driedGood","cost":0.75,"costAmount":100},{"name":"macaroni","metric":"percentage","type":"driedGood","cost":1.44,"costAmount":100},{"name":"rice","metric":"percentage","type":"driedGood","cost":1.79,"costAmount":100},{"name":"noodles","metric":"item","type":"driedGood","cost":0.81,"costAmount":3},{"name":"bread","metric":"percentage","type":"driedGood","cost":1.15,"costAmount":100},{"name":"tomato","metric":"grams","type":"fruitNut","cost":0.85,"costAmount":325},{"name":"apple","metric":"item","type":"fruitNut","cost":1.7,"costAmount":6},{"name":"banana","metric":"item","type":"fruitNut","cost":0.78,"costAmount":5},{"name":"orange","metric":"item","type":"fruitNut","cost":1.5,"costAmount":5},{"name":"lemon","metric":"item","type":"fruitNut","cost":1.5,"costAmount":5},{"name":"lime","metric":"item","type":"fruitNut","cost":1.19,"costAmount":5},{"name":"cherry tomato","metric":"grams","type":"fruitNut","cost":2.25,"costAmount":250},{"name":"cashew","metric":"item","type":"fruitNut","cost":2.75,"costAmount":200},{"name":"olive oil","metric":"ml","type":"liquid","cost":6.5,"costAmount":1000},{"name":"vegetable oil","metric":"ml","type":"liquid","cost":1.99,"costAmount":1000},{"name":"sesame seed oil","metric":"ml","type":"liquid","cost":2.6,"costAmount":250},{"name":"vinegar","metric":"ml","type":"liquid","cost":1.15,"costAmount":250},{"name":"white vinegar","metric":"ml","type":"liquid","cost":1.95,"costAmount":500},{"name":"balsamic vinegar","metric":"ml","type":"liquid","cost":1.55,"costAmount":250},{"name":"apple juice","metric":"ml","type":"liquid","cost":1.5,"costAmount":1000},{"name":"orange juice","metric":"percentage","type":"liquid","cost":1.8,"costAmount":1000},{"name":"soy sauce","metric":"ml","type":"liquid","cost":0.59,"costAmount":150},{"name":"brown sauce","metric":"percentage","type":"liquid","cost":3.4,"costAmount":100},{"name":"tomato sauce","metric":"percentage","type":"liquid","cost":4.5,"costAmount":100},{"name":"fish sauce","metric":"ml","type":"liquid","cost":2.4,"costAmount":725},{"name":"white wine","metric":"ml","type":"liquid","cost":4.65,"costAmount":750},{"name":"red wine","metric":"ml","type":"liquid","cost":5.45,"costAmount":750},{"name":"mirin","metric":"ml","type":"liquid","cost":1.9,"costAmount":150},{"name":"beer","metric":"item","type":"liquid","cost":15,"costAmount":18},{"name":"cider","metric":"item","type":"liquid","cost":10.5,"costAmount":10},{"name":"chicken breast","metric":"item","type":"meat","cost":2.4,"costAmount":2},{"name":"chicken thigh","metric":"item","type":"meat","cost":6.5,"costAmount":6},{"name":"chicken whole","metric":"item","type":"meat","cost":5.35,"costAmount":1},{"name":"sausage","metric":"item","type":"meat","cost":3,"costAmount":6},{"name":"bacon","metric":"item","type":"meat","cost":1.89,"costAmount":10},{"name":"pork chop","metric":"item","type":"meat","cost":3.75,"costAmount":2},{"name":"pork loin","metric":"item","type":"meat","cost":4.5,"costAmount":2},{"name":"steak","metric":"item","type":"meat","cost":4.5,"costAmount":1},{"name":"minced meat","metric":"grams","type":"meat","cost":4.49,"costAmount":500},{"name":"salami","metric":"item","type":"meat","cost":1.6,"costAmount":16},{"name":"chorizo","metric":"item","type":"meat","cost":1.4,"costAmount":34},{"name":"pepperoni","metric":"percentage","type":"meat","cost":1,"costAmount":32},{"name":"lamb","metric":"item","type":"meat","cost":10.5,"costAmount":1},{"name":"salmon","metric":"item","type":"meat","cost":8.95,"costAmount":4},{"name":"cod","metric":"item","type":"meat","cost":5.5,"costAmount":2},{"name":"haddock","metric":"item","type":"meat","cost":5.25,"costAmount":2},{"name":"sea bass","metric":"item","type":"meat","cost":4.65,"costAmount":2},{"name":"basa","metric":"item","type":"meat","cost":2.19,"costAmount":2},{"name":"salt and vinegar crisps","metric":"item","type":"snack","cost":2.2,"costAmount":6},{"name":"salted crisps","metric":"item","type":"snack","cost":2.2,"costAmount":6},{"name":"cheese and onion crisps","metric":"item","type":"snack","cost":2.2,"costAmount":6},{"name":"prawn cocktail crisps","metric":"item","type":"snack","cost":2.2,"costAmount":6},{"name":"chocolate bar","metric":"item","type":"snack","cost":1.5,"costAmount":1},{"name":"biscuits","metric":"item","type":"snack","cost":0.5,"costAmount":24},{"name":"peanuts","metric":"grams","type":"snack","cost":0.59,"costAmount":200},{"name":"seeds","metric":"grams","type":"snack","cost":3,"costAmount":250},{"name":"thyme","metric":"percentage","type":"herbSpice","cost":1.1,"costAmount":100},{"name":"rosemary","metric":"percentage","type":"herbSpice","cost":1.1,"costAmount":100},{"name":"mint","metric":"percentage","type":"herbSpice","cost":1.2,"costAmount":100},{"name":"parsley","metric":"percentage","type":"herbSpice","cost":1,"costAmount":100},{"name":"paprika","metric":"ml","type":"herbSpice","cost":1.1,"costAmount":100},{"name":"cayenne pepper","metric":"ml","type":"herbSpice","cost":1.2,"costAmount":100},{"name":"red chili pepper","metric":"ml","type":"herbSpice","cost":1.1,"costAmount":100},{"name":"salt","metric":"percentage","type":"herbSpice","cost":0.65,"costAmount":100},{"name":"black pepper","metric":"percentage","type":"herbSpice","cost":2.15,"costAmount":100},{"name":"tumeric","metric":"ml","type":"herbSpice","cost":1.1,"costAmount":100},{"name":"dill","metric":"percentage","type":"herbSpice","cost":1.1,"costAmount":100},{"name":"oregano","metric":"ml","type":"herbSpice","cost":1.1,"costAmount":100},{"name":"sage","metric":"percentage","type":"herbSpice","cost":1.2,"costAmount":100},{"name":"star anise","metric":"percentage","type":"herbSpice","cost":1.3,"costAmount":100},{"name":"cloves","metric":"percentage","type":"herbSpice","cost":1.3,"costAmount":100},{"name":"baked beans","metric":"item","type":"preserve","cost":5.25,"costAmount":6},{"name":"tinned tomato","metric":"item","type":"preserve","cost":0.47,"costAmount":1},{"name":"olive","metric":"percentage","type":"preserve","cost":1.25,"costAmount":100},{"name":"tomato soup","metric":"item","type":"preserve","cost":0.65,"costAmount":1},{"name":"mayonnaise","metric":"ml","type":"preserve","cost":0.99,"costAmount":500},{"name":"lentils","metric":"item","type":"preserve","cost":0.55,"costAmount":1},{"name":"kidney beans","metric":"item","type":"preserve","cost":0.49,"costAmount":1},{"name":"hoummus","metric":"item","type":"preserve","cost":0.99,"costAmount":1},{"name":"white onion","metric":"item","type":"vegetable","cost":0.95,"costAmount":3},{"name":"red onion","metric":"item","type":"vegetable","cost":0.95,"costAmount":3},{"name":"peas","metric":"percentage","type":"vegetable","cost":1.75,"costAmount":100},{"name":"carrot","metric":"item","type":"vegetable","cost":0.69,"costAmount":9},{"name":"cabbage","metric":"item","type":"vegetable","cost":0.79,"costAmount":1},{"name":"shallot","metric":"item","type":"vegetable","cost":1.5,"costAmount":7},{"name":"courgette","metric":"item","type":"vegetable","cost":1.45,"costAmount":3},{"name":"cauliflower","metric":"item","type":"vegetable","cost":1.19,"costAmount":1},{"name":"celery","metric":"item","type":"vegetable","cost":0.75,"costAmount":1},{"name":"spring onion","metric":"item","type":"vegetable","cost":0.69,"costAmount":6},{"name":"parsnip","metric":"item","type":"vegetable","cost":1.48,"costAmount":4},{"name":"baby potato","metric":"grams","type":"vegetable","cost":1,"costAmount":385},{"name":"jacket potato","metric":"item","type":"vegetable","cost":0.79,"costAmount":4},{"name":"potato","metric":"item","type":"vegetable","cost":0.19,"costAmount":1},{"name":"sweet potato","metric":"item","type":"vegetable","cost":1.44,"costAmount":9},{"name":"bell pepper","metric":"item","type":"vegetable","cost":0.69,"costAmount":1},{"name":"red cabbage","metric":"item","type":"vegetable","cost":0.79,"costAmount":1},{"name":"lettuce","metric":"item","type":"vegetable","cost":0.89,"costAmount":1},{"name":"spinach","metric":"grams","type":"vegetable","cost":1.35,"costAmount":200},{"name":"leek","metric":"item","type":"vegetable","cost":1.39,"costAmount":3},{"name":"mushrooms","metric":"percentage","type":"vegetable","cost":1.15,"costAmount":100}]}';

      final response = await _database.addIngredientJSONAPI(json);

      bool success = response['success'] as bool? ?? false;
      if (success) {
        debugPrint('Default ingredients added successfully');
        return true;
      } else {
        debugPrint('Adding default ingredients failed: ${response['message'] ?? response['error'] ?? '!!NO ERROR OR MESSAGE!!'}');
        return false;
      }
    } catch (e) {
      debugPrint('Adding default ingredients caused a crash: $e');
      return false;
    }
  }
}