import 'package:appwrite/appwrite.dart';
import 'package:deelz/core/res/app_constants.dart';

/* From https://medium.com/@wesscope/almost-netflix-a-netflix-clone-built-with-flutter-appwrite-6be35c8d0ba8
 */

class ApiClient {
  Client get _client {
    Client client = Client();
    client
        .setEndpoint(AppConstants.endPoint)
        .setProject(AppConstants.projectId)
        .setSelfSigned();
    return client;
  }

  static Account get account => Account(_instance._client);
  static Databases get database => Databases(
        _instance._client,
        databaseId: '62c0bae01d3a8399f7e6',
      );
  static Storage get storage => Storage(_instance._client);
  static Teams get teams => Teams(_instance._client);

  static final ApiClient _instance = ApiClient._internal();
  ApiClient._internal();
  factory ApiClient() => _instance;
}
