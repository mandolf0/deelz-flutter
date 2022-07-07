import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:deelz/api/client.dart';
import 'package:deelz/core/presentation/notifiers/auth_state.dart';
import 'package:deelz/data/model/status.dart';

class StatusController extends ChangeNotifier {
//!important: set the collection id
  final String collectionId = '62c0ea8e2ea38765ea3e';
  final AccountProvider authState = AccountProvider();

  Databases db =
      Databases(ApiClient.account.client, databaseId: '62c0bae01d3a8399f7e6');
  RealtimeSubscription? _subscription;

  RealtimeSubscription? get subscription => subscribe();

  Future<User> get user async {
    return await ApiClient.account.get();
  }

  //list of statuses
  Future<List<Status>> statuses() async {
    final res = await db.listDocuments(collectionId: collectionId);
    notifyListeners();
    return List<Document>.from(res.documents)
        .map((e) => Status.fromMap(e.data))
        .toList();
  }

  dynamic subscribe() {
    try {
      var realtime = Realtime(ApiClient.account.client);
      return realtime.subscribe(['collections.$collectionId.documents']);
    } on AppwriteException catch (e) {
      print(e.message ?? 'Major fail subscribing to $collectionId.status');
    }
  }

  Future<bool> deleteItem(String id) async {
    try {
      await db.deleteDocument(collectionId: collectionId, documentId: id);
      return true;
    } on AppwriteException catch (e) {
      print(e.message);
      rethrow;
    }
  }

  ///save a new state
  Future save({required String status, String? description}) async {
    try {
      //save document
      Future<Document> doc = db.createDocument(
        documentId: 'unique()',
        collectionId: collectionId,
        data: {
          "status": status,
          "description": description,
        },
        read: [
          'user:${authState.current!.$id}',
          'team:62c0fe9a6a8722834ef7'
          // 'team:' + teams.list().
        ],
        write: ['user:${authState.current!.$id}'],
        // documentId: '',
      );
      doc.then((response) {
        print(response.toString());
        notifyListeners();
        return response;
      }).catchError((error) {
        print(error.response);
      });
    } on AppwriteException catch (e) {
      rethrow;
    }
  }
}
