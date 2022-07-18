// import 'dart:convert';

import 'package:appwrite/appwrite.dart';
//import 'package:appwrite/models.dart' as appwrite;
import 'package:appwrite/models.dart';
import 'package:deelz/data/store.dart';
import 'package:flutter/material.dart';
import 'package:deelz/api/client.dart';
import 'package:deelz/core/presentation/notifiers/auth_state.dart';
import 'package:deelz/core/res/app_constants.dart';
import 'package:deelz/data/model/deal.dart';
import 'package:deelz/data/model/status.dart';
import 'package:deelz/data/model/transaction.dart';
import 'package:deelz/extensions.dart';
import 'package:deelz/screens/deal_manage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:yo_ui/yo_ui.dart';

class DealsList extends StatefulWidget {
  const DealsList({Key? key}) : super(key: key);

  @override
  _DealsListState createState() => _DealsListState();
}

class _DealsListState extends State<DealsList> {
  Databases db = Databases(ApiClient.account.client,
      databaseId: ApiClient.database.databaseId);

  List<Deal> items = [];
  // ran once to load items. Used to set deal.statusId based on id match.
  List<Status> statuses = [];

  late Deal? itemToEdit;
  String currentItemStatus = '';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _desciptionController = TextEditingController();
  RealtimeSubscription? subscription;
  // late final Client client;
  final itemsCollection = '62c0bbe9476a14177668';
  final String statusCollectionId = '62c0ea8e2ea38765ea3e';

  final AccountProvider authState = AccountProvider();

  late final User user; //= AuthState.current as User;

  @override
  void initState() {
    super.initState();
    user = context.read<AccountProvider>().current!;

    loadItems();
    subscribe();

    //! todo subscribe to status changes.
    //
  }

  loadItems() async {
    // items.clear();

    DocumentList res = await db.listDocuments(
      collectionId: itemsCollection,
    );
    // lookup status collectiong for later traversing

    final lookupStatus =
        await db.listDocuments(collectionId: statusCollectionId);
    //declared as List<Status>=[];
    statuses = List<Document>.from(lookupStatus.documents)
        .map((e) => Status.fromMap(e.data))
        .toList();

    if (res.documents.isNotEmpty) {
      res.documents.forEach((deal) async {
        // interpolate Status colletion and set values for ```deal```
        deal.data['status_id'] = statuses
            .firstWhere((item) => item.id!.contains(deal.data['status_id']));
      });
    }
    var result = List<Document>.from(res.documents)
        .map((e) => Deal.fromMap(e.data))
        .toList();
    items = result;
    items.forEach((element) {
      print(element.customerName);
    });
    // subscribe();
    setState(() {});
  }

  void subscribe() {
    var realtime = Realtime(ApiClient.account.client);
    final String subscribePath =
        'databases.62c0bae01d3a8399f7e6.collections.${itemsCollection}.documents';
    subscription = realtime.subscribe([
      subscribePath
    ]); //replace <collectionId> with the ID of your items collection, which can be found in your collection's settings page.
    print('SUBSCRIBE PATH = ${subscribePath}');

    // listen to changes
    subscription?.stream.listen((data) {
      // data will consist of `event` and a `payload`
      if (data.payload.isNotEmpty) {
        var item = data.payload;
        //start for loop
        print('payload detected');

        for (var i = 0; i < data.events.length; i++) {
          if (data.events.contains("$subscribePath.create")) {
            items.add(
              Deal(
                id: item['\$id'],
                statusId: statuses.firstWhere(
                    (item) => item.id!.contains(data.payload['status_id'])),
                customerName: item['cust_name'],
                address: item['address'],
                phone: item['phone'],
                signedDate: int.parse(item['signed_date'] ?? 0),
                adjusterDate: int.parse(item['adjusters_date'] ?? 0),
                claimNo: item['claim_no'],
                carrierId: item['carrier_id'],
                salesRepId: item['sales_rep_id'],
                permissions:
                    Permissions(write: ['role:all'], read: ['role:all']),
              ),
            );
            setState(() {});
          } else if (data.events.contains("database.documents.delete")) {
            items.removeWhere((it) => it.id == item['\$id']);
            setState(() {});
          } else if (data.events
              .contains('databases.*.collections.*.documents.*.update')) {
            // print(item['ststus']);
            //!atempting to update list item
            final oldItem = items
                .indexWhere((element) => element.id == data.payload['\$id']);
            setState(() {
              //TODO! set permission here too
              items[oldItem] = Deal(
                id: item['\$id'],
                statusId: statuses.firstWhere(
                    (lstStatusItem) => lstStatusItem.id == item['status_id']),

                /* statusId: statuses.firstWhere(
                    (element) => data.payload['ststus'] == element.id), */
                customerName: item['cust_name'],
                address: item['address'],
                phone: item['phone'],
                signedDate: int.parse(item['signed_date'].toString()),
                adjusterDate: int.parse(item['adjusters_date'].toString()),
                claimNo: item['claim_no'],
                carrierId: item['carrier_id'],
                salesRepId: item['sales_rep_id'],
              );
            });
          }
          //end for loop
        }
      }
    });
  }

  @override
  void dispose() {
    subscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountProvider>(builder: (context, user, child) {
      return Scaffold(
        bottomNavigationBar: BottomNavigationBar(items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Everyone'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Tasks'),
        ]),
        // backgroundColor: Color.fromARGB(255, 88, 117, 175),
        // backgroundColor: Color(0xff8cc5ff),

        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              items.isEmpty
                  ? Center(
                      child: Text(
                        'So much empty. Need Deals',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    )
                  : buildListViewBuilder(context, itemList: items),
            ],
          ),
        ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          elevation: 6,
          child: const Icon(Icons.add),
          onPressed: () {
            // dialog to add new item set editing to false
            itemToEdit = null;
            //default to a new status
            if (statuses.isEmpty) {
              Fluttertoast.showToast(msg: 'At least one status is needed');
              Navigator.pushNamed(context, '/settingsStatus');
            } else {
              currentItemStatus = statuses.first.id.toString();
              showMyDialog(context);
            }
            // statuses.firstWhere((status) => statuses.first.id.toString());
          },
        ),
      );
    });
  }

  void showMyDialog(BuildContext context, {bool editing = false}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Text(editing ? 'Update' : 'Add new'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(label: Text('Customer Name')),
                controller: _nameController,
              ),
              TextField(
                decoration: const InputDecoration(
                    label: Text('Address'), prefix: Icon(Icons.map)),
                controller: _desciptionController,
              ),
              //dropdown button
              Row(
                children: [
                  Text(
                    'Status',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2!
                        .copyWith(color: Colors.black54),
                  ),
                  Expanded(
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return ButtonTheme(
                          alignedDropdown: true,
                          child: DropdownButtonFormField(
                            // focusColor: Colors.white,
                            style: const TextStyle(fontSize: 16),
                            value: currentItemStatus,
                            items: buildStatusDropDown(),

                            onChanged: (String? value) {
                              setState(() {
                                currentItemStatus = value!;
                                print(value);
                              });
                            },
                            // style: const TextStyle(color: Colors.blue),
                            selectedItemBuilder: (BuildContext context) {
                              return statuses.map((status) {
                                late Color? bgColor;
                                bgColor = currentItemStatus == status.id
                                    ? Colors.white
                                    : Colors.white;
                                return Container(
                                  color: bgColor,
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  child: Text(
                                    status.status!,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            // style: ButtonStyle(backgroundColor:  ),
            child: const Text('Cancel'),
            onPressed: () {
              itemToEdit = null;
              currentItemStatus = '';
              Navigator.of(context).pop();
            },
          ),
          MaterialButton(
            color: Color(0xffC8162B),
            shape: const StadiumBorder(),
            child: Text(editing ? 'Update' : 'Add',
                style: TextStyle(color: Colors.white)),
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
      {required List<Deal> itemList}) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          // color: Colors.white.w,
          elevation: 2.0,
          shadowColor: const Color(0xff909090),
          child: ListTile(
              //todo! use ternary operator to show list of deals or dealsManage based on itemtoedit
              onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DealManage(
                        collectionId: itemsCollection,
                        deal: items[index],
                      ),
                    ),
                  ),
              // Navigator.pushNamed(context, '/dealpage',                  arguments: {'deal': items[index]}),
              //onTap: () => print(items[index].statusId.status),
              // isThreeLine: true,
              title: Row(
                children: [
                  Expanded(
                    child: Text(items[index].customerName),
                  ),
                  // Text(niceTime(items[index].signedDate).toString()),
                  Text(
                    items[index].salesRepId,
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                ],
              ),
              subtitle: Text(items[index].address.isNotEmpty
                  ? items[index].address
                  : 'n/a'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  await db.deleteDocument(
                    collectionId: itemsCollection,
                    documentId: items[index].id!,
                  );
                },
              ),
              onLongPress: () {
                //update an item
                itemToEdit = items[index];
                currentItemStatus = itemToEdit!.statusId.id!;
                //set controllers to the item values
                _nameController.text = itemToEdit!.customerName;
                _desciptionController.text = itemToEdit!.address;

                showMyDialog(context, editing: true);
              }),
        );
      },
    );
  }

  String niceTime(int? epochTimeStamp) {
    if (epochTimeStamp != null && epochTimeStamp > 0) {
      var date = DateTime.fromMillisecondsSinceEpoch(epochTimeStamp);
      return DateFormat('EEEE d MMM yyyy').format(date);
    }
    //TODO! return blank on production
    return '';
  }

  List<DropdownMenuItem<String>> buildStatusDropDown() {
    return statuses
        .map((e) => DropdownMenuItem(
              value: e.id,
              child: ListTile(
                dense: true,
                tileColor: currentItemStatus == e.id!
                    ? AppConstants.kcPrimaryLight
                    : Colors.grey[100],
                title: Text(e.status!,
                    style: TextStyle(
                        color: currentItemStatus == e.id!
                            ? AppConstants.kcPrimaryDark
                            : Colors.black,
                        fontSize: 12)),
              ),
            ))
        .toList();
  }

  void _addItem(String name, String? address) async {
    try {
      await db.createDocument(
        documentId: 'unique()',
        collectionId: itemsCollection,
        data: {
          'cust_name': name,
          //!TODO pick status Id from list.
          'status_id': currentItemStatus,
          'phone': 'needsfield phone',
          'address': address,
          'signed_date': DateTime.now().millisecondsSinceEpoch.toString(),
          'adjusters_date': DateTime.now().millisecondsSinceEpoch.toString(),
          'claim_no': 'new val',
          'carrier_id': 'new val',
          'sales_rep_id': user.$id,
        },
        read: [
          ///! use this when payload create
          'user:${AccountProvider().current!.$id}',
          "user:${user.$id}",

          "team:${Store.get('globalTeamId')}/owner"
          // 'team:' + teams.list().
        ],
        write: [
          'user:${AccountProvider().current!.$id}',
          "team:${Store.get('globalTeamId')}/owner"
        ],
        // documentId: 'unique()',
      );
    } on AppwriteException catch (e) {
      print(e.message);
    }
  }

  void _updateItem(String status, String? description) async {
    try {
      await db.updateDocument(
        documentId: itemToEdit!.id!,
        collectionId: itemsCollection,
        data: {
          'cust_name': status,
          'address': description,
          'signed_date': DateTime.now().millisecondsSinceEpoch,
          'status_id': currentItemStatus
        },
        /*  read: [
          ///! use this when payload create
          'user:${_user!.$id}',
          'team:620c6e12b9278e4aa747',
          'team:62c2710d77ab13f2c3af'
          // 'team:' + teams.list().
        ],
        write: ['user:${_user!.$id}', 'team:62c2710d77ab13f2c3af'], */
        // documentId: 'unique()',
      );
      itemToEdit = null;
      Fluttertoast.showToast(msg: 'Saved', backgroundColor: Colors.green);
    } on AppwriteException catch (e) {
      Fluttertoast.showToast(
        msg: e.message.toString(),
        backgroundColor: Colors.black,
      );
    }
  }
}
