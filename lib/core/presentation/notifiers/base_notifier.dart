import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/widgets.dart';
import 'package:deelz/core/res/app_constants.dart';

class BaseController extends ChangeNotifier {
  static BaseController? instance;
  Client client = Client();
  late final Account _account;
  // late Database? _database;
  Teams? teams;
  late final String collection;
  String? _error;

  // getters
  String? get error => _error;
  // Databases? get db => _database;

  BaseController get getInstance {
    instance ??= BaseController.internal();
    return instance!;
  }

  BaseController.internal() {
    client
        .setEndpoint(AppConstants.endPoint)
        .setSelfSigned()
        .setProject(AppConstants.projectId);
    _account = Account(client);
    // _database = Databases(client);
    teams = Teams(client);
  }
}
