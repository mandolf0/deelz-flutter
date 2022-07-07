import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:deelz/api/client.dart';
import 'package:deelz/data/store.dart';
// import 'package:deelz/features/auth/data/model/user.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  authenticating,
  unauthenticated,
}

class AccountProvider extends ChangeNotifier {
  Client client = Client();

  AuthStatus _status = AuthStatus.uninitialized;
  final Teams _teams = ApiClient.teams;
  RealtimeSubscription? subscription;
  Realtime? realtime;

  String? _error;

  User? _current;
  User? get current => _current;

  Session? _session;
  Session? get session => _session;

  bool _signedIn = false;
  bool? get signedIn => _signedIn;

  //getters
  // bool get isLoggedIn => _isLoggedIn;
  // User? user() => _user;
/*   set setUser(User user) {
    _user = user;
    notifyListeners();
  } */

  AuthStatus get status => _status;
  set setStatus(AuthStatus state) => state;

  String? get error => _error;

//!todo subcribe to account and logout if session is terminated.

  subscribe() {
    realtime = Realtime(client);

    subscription = realtime!.subscribe(['account']);
    subscription!.stream.listen((response) {
      print(response.events);

      if (response.payload.isNotEmpty) {
        print(response.payload);
        /* switch (data.event) {
        case 'account.':
        } */
      }
    });
  }

  void forgotPassword({required String email}) async {
    try {
      await ApiClient.account.createRecovery(
          email: email, url: 'https://deelz.herokuapp.com/reset_password.html');
      await ApiClient.account.deleteSession(sessionId: 'current');
      AuthStatus.unauthenticated;

      // _user = null;
    } on AppwriteException catch (e) {
      print(e);
    }
  }

/* 
  static AuthState get instance {
    _instance ??= AuthState._internal();
    return _instance!;
  }
 */
/*   Future<User> getUser() async {
    final res = await _account.get();

    return User.fromMap(res.toMap());
  }
 */
/*   Future _getAccount() async {
    if (checkIsLoggedIn()) {
      //final res1 = account.get();
      print("Running get Account API");
      try {
        Future<User> res1 = _account.get();
        return res1;
      } on AppwriteException catch (e) {
        print(e.message);
      }
    }
  } */

  Future<Session?> get _cachedSession async {
    // Store.remove("session");
    final cached = await Store.get("session");
    if (cached == null) {
      return null;
    }

    try {
      _current = await ApiClient.account.get();
    } on AppwriteException catch (e) {
      rethrow;
    }
    return Session.fromMap(json.decode(cached));
  }

  Future<bool> isValid() async {
    if (session == null) {
      final cached = await _cachedSession;

      if (cached == null) {
        _signedIn = false;
        return false;
      }
      _signedIn = true;
      // _current = await ApiClient.account.get();

      _session = cached;
      // ApiClient.account.getSession(sessionId: _session.$id);

      notifyListeners();
    }
    return _session != null;
  }

  Future<void> login({required String email, required String password}) async {
    try {
      final result = await ApiClient.account
          .createEmailSession(email: email, password: password)
          .then((value) async {
        _session = value;
        _current = await ApiClient.account.get();

        Store.set("session", json.encode(value.toMap()));
        notifyListeners();
      });
    } catch (e) {
      _session = null;
      throw 'Error login in: ' + e.toString();
    }
    return;

    //new up
    /* try {
      Future<Session> result = ApiClient.account
          .createEmailSession(email: email, password: password);
      _status = AuthStatus.authenticating;
      notifyListeners();
      result.then((value) async {
        _current = await ApiClient.account.get();
        _signedIn = true;
        _session = Session.fromMap(value.toMap());

        Store.set("session", json.encode(value.toMap()));
        notifyListeners();
      }).onError((error, stackTrace) => _session = null);
      //_current = await ApiClient.account.get();
      notifyListeners();
    } catch (e) {
      _session = null;
      rethrow;
    } */
  }

  logout() async {
    Future result = ApiClient.account.deleteSession(sessionId: 'current');

    result.then((response) {
      Store.remove("session");
      print("session destroyed");
      // print(result.toString());
      _signedIn = false;
      _session = null;

      notifyListeners();
    }).catchError((error) {
      print(error.response);
      notifyListeners();
    });
  }

  Future<User> createAccount(String? name, String email, String password) {
    try {
      final result = ApiClient.account.create(
          name: name, email: email, password: password, userId: 'unique()');
      print(result.toString());
      result.then((value) {
        _current = value;
      });
      notifyListeners();
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<Team> createTeam({required String teamName}) {
    // Teams teams = Teams(client);

    try {
      var result = _teams.create(name: teamName, teamId: 'unique()');
      return result;
    } on AppwriteException catch (e) {
      rethrow;
    }
  }

  ///List Teams
  ///
  ///Get a list of all the current user teams.
  Future<TeamList> listTeams() {
    return _teams.list();

    // '620c6e12b9278e4aa747');
  }

  ///  Delete Team
  ///
  ///Delete a team by its unique ID. Only team owners have write access for this resource.
  Future<dynamic> deleteTeam({required String teamId}) {
    try {
      var result = _teams.delete(teamId: teamId);
      return result;
    } on AppwriteException catch (e) {
      rethrow;
    }
  }

  ///Get a List\<MembershipList\> by the team $Id;
  Future<MembershipList> membershipList({required String teamId}) {
    try {
      return _teams.getMemberships(teamId: teamId);
    } on AppwriteException catch (e) {
      rethrow;
    }
  }

  ///very email. sends email

  Future verifyEmail() {
    return ApiClient.account.createVerification(
        url: 'https://deelz.herokuapp.com/complete_verify/');
  }

  /// add membership
  Future<Membership> membershipAdd(
    String? name, {
    required String teamId,
    required String email,
    required List<dynamic> roles,
  }) {
    try {
      var result = _teams.createMembership(
          teamId: teamId,
          email: email,
          roles: roles,
          url: 'http://192.168.0.108:5500');
      return result;
    } on AppwriteException catch (e) {
      rethrow;
    }
  }

  void notify() {
    notifyListeners();
  }

  /*  Future<MembershipList> updateMembership({required String teamId ,
      required String membershipId,
  required String userId,
  required String secret,}) {
    try {
      return _teams.updateMembershipStatus(teamId: teamId,
        membershipId:  membershipId,
      userId: userId,
      secret: secret
      
      );
    } on AppwriteException catch (e) {
      rethrow;
    }
  } */
}
