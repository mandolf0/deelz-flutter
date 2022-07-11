import 'dart:convert';

import 'package:appwrite/models.dart';
import 'package:deelz/api/client.dart';
import 'package:deelz/core/presentation/notifiers/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Store {
  SharedPreferences? _prefs;

  static final Store _instance = Store._internal();

  factory Store() => _instance;

  Store._internal();

// set user list from db when loading the app.

  Future<void> storeCompanyUserList() async {
    List<Map<String, dynamic>>? myuserslist = [];

// use this to filter
    Future result =
        ApiClient.database.listDocuments(collectionId: 'company_users');

    result.then((response) async {
      response.users.forEach((element) {
        myuserslist.add(element);
      });
      //  AccountProvider().usersAvailable?.add( element);
      AccountProvider().setUsers(myuserslist);
      print(AccountProvider().usersAvailable);
    }).catchError((error) {
      print(error.response);
    });
  }

  Future<void> _insert(Map<String, dynamic> data) async {
    _prefs ??= await SharedPreferences.getInstance();

    data.forEach((key, value) {
      _prefs?.setString(key, value.toString());
    });
  }

  Future<void> _set(String key, dynamic value) async {
    _prefs ??= await SharedPreferences.getInstance();

    Map<String, dynamic> data = {
      "value": value,
      "type": "${value.runtimeType}",
    };

    _prefs?.setString(key, json.encode(data));
  }

  Future<dynamic> _get(String key) async {
    _prefs ??= await SharedPreferences.getInstance();

    Map<String, dynamic> data = json
        .decode(_prefs?.getString(key) ?? "{\"type\":\"Null\",\"value\":null}");

    switch (data["type"]) {
      case "String":
        return data["value"];
      case "int":
        return int.tryParse(data["value"]);
      case "double":
        return double.tryParse(data["value"]);
      case "bool":
        return data["value"] == "true" ? true : false;
      default:
        return null;
    }
  }

  Future<void> _remove(String key) async {
    _prefs ??= await SharedPreferences.getInstance();
    _prefs?.remove(key);
  }

  static Future<void> insert(Map<String, dynamic> data) async =>
      _instance._insert(data);
  static Future<void> set(String key, dynamic value) async =>
      Store._instance._set(key, value);
  static Future<dynamic> get(String key) async => Store._instance._get(key);
  static Future<void> remove(String key) async => Store._instance._remove(key);
}
