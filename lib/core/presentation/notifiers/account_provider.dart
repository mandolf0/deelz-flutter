import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:appwrite/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deelz/api/client.dart';

class AccountProvider extends ChangeNotifier {
  User? _current;
  User? get current => _current;

  Session? _session;
  Session? get session => _session;

  Future<Session?> get _cachedSession async {
    final prefs = await SharedPreferences.getInstance();
    final cached = jsonDecode(prefs.getString("cached.session")!);
    if (cached == null) {
      return null;
    }
    return Session.fromMap(json.decode(cached));
  }

  Future<bool> isValid() async {
    if (session == null) {
      final cached = await _cachedSession;
      if (cached == null) {
        return false;
      }
      _session = cached;
    }
    return _session != null;
  }

  Future<void> register(String email, String password, String? name) async {
    try {
      final result = await ApiClient.account.create(
          userId: 'unique()', email: email, password: password, name: name);
      _current = result;
      notifyListeners();
    } catch (_e) {
      throw Exception("Failed to register");
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final result = await ApiClient.account
          .createEmailSession(email: email, password: password);
      _session = result;
      final prefs = await SharedPreferences.getInstance();
      prefs.setString("cached.session", json.encode(result.toMap()));
      _current = await ApiClient.account.get();
      notifyListeners();
    } catch (e) {
      _session = null;
    }
  }

  //logout
  Future<void> logout() async {
    try {
      final result =
          await ApiClient.account.deleteSession(sessionId: 'current');
    } catch (e) {}
    throw Exception("Failed to logout");
  }
}
