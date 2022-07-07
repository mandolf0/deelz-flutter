import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:deelz/api/client.dart';
import 'package:deelz/core/presentation/notifiers/auth_state.dart';
import 'package:deelz/core/presentation/notifiers/status_controller.dart';
import 'package:deelz/core/res/app_constants.dart';
import 'package:deelz/data/model/status.dart';
import 'package:deelz/data/model/transaction.dart';
import 'package:deelz/extensions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ManageStatus extends StatefulWidget {
  const ManageStatus({Key? key}) : super(key: key);

  @override
  _ManageStatusState createState() => _ManageStatusState();
}

class _ManageStatusState extends State<ManageStatus> {
  List<Status> items = [];
  late Status? itemToEdit;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _desciptionController = TextEditingController();
  RealtimeSubscription? subscription;
  // late final Client client;
  late final User user;
  final itemsCollection = '62c0ea8e2ea38765ea3e';

  @override
  void initState() {
    super.initState();

    user = context.read<AccountProvider>().current!;
    loadItems();
    subscribe();
  }

  loadItems() async {
    try {
      // final res = await database.listDocuments(collectionId: itemsCollection);
      final res = await StatusController().statuses();
      // user = context.read<AccountProvider>().current!;

      setState(() {
        items = res;
      });
    } on AppwriteException catch (e) {
      print(e.message);
    }
  }

  void subscribe() {
    final realtime = Realtime(ApiClient.account.client);

    subscription = realtime.subscribe([
      'collections.$itemsCollection.documents'
    ]); //replace <collectionId> with the ID of your items collection, which can be found in your collection's settings page.

    // listen to changes
    subscription!.stream.listen((data) {
      // data will consist of `event` and a `payload`
      if (data.payload.isNotEmpty) {
        var event;

        for (var i = 0; i < data.events.length; i++) {
          if (data.events.contains("database.documents.create")) {
            var item = data.payload;
            items.add(
              Status(
                  id: item['\$id'],
                  status: item['status'],
                  description: item['description'],
                  permissions:
                      Permissions(write: ['role:all'], read: ['role:all'])),
            );
            setState(() {});
          } else if (data.events.contains("database.documents.delete")) {
            var item = data.payload;
            items.removeWhere((it) => it.id == item['\$id']);
            setState(() {});
          } else if (data.events.contains("database.documents.update")) {
            var item = data.payload;
            print(item);
            //!atempting to update list item
            final oldItem = items
                .indexWhere((element) => element.id == data.payload['\$id']);
            setState(() {
              //TODO! set permission here too
              items[oldItem] = Status(
                  id: data.payload['\$id'],
                  status: data.payload['status'],
                  description: data.payload['description']);

              // items.removeWhere((it) => it.id == item['\$id']);
            });
          }
        }
      }

      /*  switch (data.events) {
         /*  case   "database.documents.create" :
            var item = data.payload;
            items.add(
              Status(
                  id: item['\$id'],
                  status: item['status'],
                  description: item['description'],
                  permissions:
                      Permissions(write: ['role:all'], read: ['role:all'])),
            );
            setState(() {});
            break; */
         // case "database.documents.delete":
           
          //  break;
          case "database.documents.update":
           
            break;
          default:
            break;
        } */
    });
  }

  @override
  void dispose() {
    subscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User user = context.read<AccountProvider>().current!;

    return Scaffold(
      // backgroundColor: Color(0xfffafafa),
      // backgroundColor: Color(0xff8cc5ff),
      appBar: AppBar(
        title: Text(
          'Manage Statuses',
          style: TextStyle(
            fontFamily: GoogleFonts.ubuntu().toString(),
          ),
        ),
        actions: [
          IconButton(onPressed: () => loadItems(), icon: Icon(Icons.refresh))
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Text(
                'So much empty',
                style: Theme.of(context).textTheme.bodyText1,
              ),
            )
          : buildListViewBuilder(context, itemList: items),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // dialog to add new item set editing to false
          itemToEdit = null;
          showMyDialog(context);
        },
      ),
    );
  }

  void showMyDialog(BuildContext context, {bool editing = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(editing ? 'Update' : 'Add new item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(label: Text('Title')),
              controller: _nameController,
            ),
            TextField(
              decoration: InputDecoration(label: Text('Description')),
              controller: _desciptionController,
            ),
          ],
        ),
        actions: [
          TextButton(
            // style: ButtonStyle(backgroundColor:  ),
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          MaterialButton(
            color: AppConstants.kcPrimaryLight,
            shape: StadiumBorder(),
            child: Text(editing ? 'Update' : 'Add'),
            onPressed: () {
              // add new item
              final name = _nameController.text.trim();
              final description = _desciptionController.text.trim();
              // final desc = _desciptionController.text;

              if (name.isNotEmpty) {
                switch (editing) {
                  case true:
                    _updateItem(name, description);
                    _nameController.clear();
                    _desciptionController.clear();
                    itemToEdit = null;
                    break;
                  case false:
                    _addItem(name, description);
                    _nameController.clear();
                    _desciptionController.clear();
                    break;

                  default:
                }
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget buildListViewBuilder(BuildContext context,
      {required List<Status> itemList}) {
    //User user = context.read<AccountProvider>().current!;

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          // color: Colors.white.w,
          elevation: 2.0,
          shadowColor: Color(0xff909090),
          child: ListTile(
              // isThreeLine: true,
              title: Text(items[index].status!),
              subtitle: Text(items[index].description ?? ''),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  await ApiClient.database.deleteDocument(
                    collectionId: itemsCollection,
                    documentId: items[index].id!,
                  );
                },
              ),
              onLongPress: () {
                //update an item
                itemToEdit = items[index];
                //set controllers to the item values
                _nameController.text = itemToEdit!.status!;
                _desciptionController.text = itemToEdit!.description ?? '';

                showMyDialog(context, editing: true);
              }).addNeumorphism(),
        );
      },
    );
  }

  void _addItem(String name, String? description) async {
    try {
      await ApiClient.database.createDocument(
        documentId: 'unique()',
        collectionId: itemsCollection,
        data: {'status': name, 'description': description},
        read: [
          ///! use this when payload create
          'user:${user.$id}',
          'team:62c0fe9a6a8722834ef7'
          // 'team:' + teams.list().
        ],
        write: ['user:${user.$id}', 'team:62c0fe9a6a8722834ef7'],
        // documentId: 'unique()',
      );
      loadItems();
    } on AppwriteException catch (e) {
      print(e.message);
    }
  }

  void _updateItem(String status, String? description) async {
    try {
      await ApiClient.database.updateDocument(
        documentId: itemToEdit!.id!,
        collectionId: itemsCollection,
        data: {'status': status, 'description': description},
        read: [
          ///! use this when payload create
          'user:${user.$id}',
          'team:62c0fe9a6a8722834ef7'
          // 'team:' + teams.list().
        ],
        write: ['user:${user.$id}', 'team:62c0fe9a6a8722834ef7'],
        // documentId: 'unique()',
      );
      itemToEdit = null;
    } on AppwriteException catch (e) {
      print(e.message);
    }
  }
}
