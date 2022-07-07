import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/widgets.dart';
import 'package:deelz/api/client.dart';
import 'package:deelz/core/res/app_constants.dart';
import 'package:deelz/core/presentation/notifiers/auth_state.dart';
import 'package:deelz/data/model/transaction.dart';

class TransactionState extends ChangeNotifier {
  final String collectionId = "61d7fe9acef7d41d3f4b";
  Client client = Client();

  final AccountProvider authState = AccountProvider();

  String _error = "";

  String get error => _error;

  /* Future<List<Transaction>>? get transactions {
    return fetchTransactions();
  } */

  TransactionState() {
    _init();
    // fetchTransactions();
  }

  _init() {}

  Stream<List<Transaction>> get txs async* {
    final res = ApiClient.database.listDocuments(collectionId: collectionId);
    List<Transaction> trans = [];
    res.then((value) {
      trans = value.documents.map((e) => Transaction.fromMap(e.data)).toList();
    });
    yield trans;

    // return transactions();
  }

  Future<List> transactions() async {
    try {
      Future<DocumentList> res =
          ApiClient.database.listDocuments(collectionId: collectionId);
      var items = [];
      res.then((data) {
        items = List<Transaction>.from(
            data.documents.map((e) => Transaction.fromJson(e.data))).toList();
      });
      return items;
    } on AppwriteException catch (e) {
      rethrow;
    }
  }

  ///
  /*  final res = await db.listDocuments(collectionId: collectionId);
    notifyListeners();
    return List<Document>.from(res.documents)
        .map((e) => Transaction.fromMap(e.data))
        .toList();
  }*/

  Future<bool> deleteTx({required String tx}) async {
    try {
      await ApiClient.database
          .deleteDocument(collectionId: collectionId, documentId: tx);
      return true;
    } on AppwriteException catch (e) {
      print(e.message);
      rethrow;
    }
  }

  Future<bool> saveTransaction(String title, String description,
      double txAmount, int txType, DateTime txDate,
      {Transaction? txId}) async {
    Map<String, dynamic> data = {
      "title": title,
      "description": description,
      "amount": txAmount,
      "transaction_type": txType,
      "transaction_date": txDate.millisecondsSinceEpoch.toString(),
      "created_at": DateTime.now().millisecondsSinceEpoch.toString(),
      "updated_at": DateTime.now().millisecondsSinceEpoch.toString(),
      "user_id": authState.current!.$id,
      /* "permissions": {
        
      } */
    };
    try {
      if (txId != null) {
        Future<Document> doc = ApiClient.database.updateDocument(
          collectionId: collectionId,
          documentId: txId.id!,
          data: data,
          read: ['user:${authState.current!.$id}'],
          write: ['user:${authState.current!.$id}'],
        );
        doc.then((value) => notifyListeners());
      } else {
        Future<Document> doc = ApiClient.database.createDocument(
          documentId: 'unique()',
          collectionId: collectionId,
          data: data,
          read: ['user:${authState.current!.$id}'],
          write: ['user:${authState.current!.$id}'],
          // documentId: '',
        );
        doc.then((value) => notifyListeners());
      }
      return true;
    } on AppwriteException catch (e) {
      print(e.message);
      rethrow;
    }
  }

  /* Future<List<Transaction>> transactions() async {
    DocumentList res = await db!.listDocuments(collectionId: collectionId);
    if (res.documents.isNotEmpty) {
      //  return List<Map<String, dynamic>>.fromjson(res.documents);
      return List<Transaction>.from(
        res.documents
            .map(
              (tr) => Transaction.fromJson(tr.toMap()),
            )
            .toList(),
      );
    } else {
      throw ('No documents found');
    }
  } */
}
