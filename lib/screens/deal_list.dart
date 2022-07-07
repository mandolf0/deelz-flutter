// import 'dart:convert';

import 'package:appwrite/appwrite.dart';
//import 'package:appwrite/models.dart' as appwrite;
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:deelz/api/client.dart';
import 'package:deelz/core/presentation/notifiers/auth_state.dart';
import 'package:deelz/core/res/app_constants.dart';
import 'package:deelz/data/model/deal.dart';
import 'package:deelz/data/model/status.dart';
import 'package:deelz/data/model/transaction.dart';
import 'package:deelz/extensions.dart';
import 'package:deelz/screens/deal_manage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DealsList extends StatefulWidget {
  const DealsList({Key? key}) : super(key: key);

  @override
  _DealsListState createState() => _DealsListState();
}

class _DealsListState extends State<DealsList> {
  Databases db =
      Databases(ApiClient.account.client, databaseId: '62c0bae01d3a8399f7e6');

  List<Deal> items = [];
  // ran once to load items. Used to set deal.statusId based on id match.
  List<Status> statuses = [];

  late Deal? itemToEdit;
  late String? currentItemStatus;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _desciptionController = TextEditingController();
  RealtimeSubscription? subscription;
  // late final Client client;
  final itemsCollection = '62c0bbe9476a14177668';
  final AccountProvider authState = AccountProvider();

  late final User _user; //= AuthState.current as User;

  @override
  void initState() {
    super.initState();

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
        await db.listDocuments(collectionId: '62c0ea8e2ea38765ea3e');
    //declared as List<Status>=[];
    statuses = List<Document>.from(lookupStatus.documents)
        .map((e) => Status.fromMap(e.data))
        .toList();

    res.documents.forEach((deal) async {
      // interpolate Status colletion and set values for ```deal```
      deal.data['ststus'] =
          statuses.firstWhere((item) => item.id!.contains(deal.data['ststus']));
    });
    var result = List<Document>.from(res.documents)
        .map((e) => Deal.fromMap(e.data))
        .toList();
    items = result;
    // subscribe();
    //setState(() {});
  }

  void subscribe() {
    var realtime = Realtime(ApiClient.account.client);

    subscription = realtime.subscribe([
      'collections.$itemsCollection.documents'
    ]); //replace <collectionId> with the ID of your items collection, which can be found in your collection's settings page.

    // listen to changes
    subscription!.stream.listen((data) {
      // data will consist of `event` and a `payload`
      if (data.payload.isNotEmpty) {
        //start for loop

        for (var i = 0; i < data.events.length; i++) {
          if (data.events.contains("database.documents.create")) {
            var item = data.payload;
            items.add(
              Deal(
                id: item['\$id'],
                statusId: statuses.firstWhere(
                    (item) => item.id!.contains(data.payload['ststus'])),
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
            var item = data.payload;
            items.removeWhere((it) => it.id == item['\$id']);
            setState(() {});
          } else if (data.events.contains("database.documents.update")) {
            var item = data.payload;
            // print(item['ststus']);
            //!atempting to update list item
            final oldItem = items
                .indexWhere((element) => element.id == data.payload['\$id']);
            setState(() {
              //TODO! set permission here too
              items[oldItem] = Deal(
                id: item['\$id'],
                statusId: statuses
                    .firstWhere((lstItem) => lstItem.id == item['ststus']),

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
    return Scaffold(
      // backgroundColor: Color(0xfffafafa),
      // backgroundColor: Color(0xff8cc5ff),

      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FloatingActionButton(
              heroTag: 'refreshdeals',
              child: Text('load'),
              onPressed: () async => await loadItems(),
            ),
            Center(
              child: Text(
                'Deals',
                style: TextStyle(
                    fontFamily: GoogleFonts.montserrat.toString(),
                    fontSize: 33),
              ),
            ),
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
        child: Icon(Icons.add),
        onPressed: () {
          // dialog to add new item set editing to false
          itemToEdit = null;
          //default to a new status
          currentItemStatus = statuses
              .firstWhere((status) => status.id == "6230ca4eaae5d4cbc204")
              .id;
          showMyDialog(context);
        },
      ),
    );
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
                decoration: InputDecoration(label: Text('Customer Name')),
                controller: _nameController,
              ),
              TextField(
                decoration: InputDecoration(
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
                            style: TextStyle(fontSize: 16),
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
            child: Text('Cancel'),
            onPressed: () {
              itemToEdit = null;
              currentItemStatus = '';
              Navigator.of(context).pop();
            },
          ),
          MaterialButton(
            color: AppConstants.kcSecondaryLight,
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
              onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DealManage(
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
                    items[index].statusId.status ?? 'N/A',
                    style: Theme.of(context).textTheme.caption,
                  )
                ],
              ),
              subtitle: Text(items[index].address.isNotEmpty
                  ? items[index].address
                  : 'n/a'),
              trailing: IconButton(
                icon: Icon(Icons.delete),
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
                currentItemStatus = itemToEdit!.statusId.id;
                //set controllers to the item values
                _nameController.text = itemToEdit!.customerName;
                _desciptionController.text = itemToEdit!.address;

                showMyDialog(context, editing: true);
              }).addNeumorphism(),
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
              value: e.id,
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
          'status_id': 'some status',
          'phone': '78787',
          'address': address,
          'signed_date': DateTime.now().millisecondsSinceEpoch.toString(),
          'adjusters_date': DateTime.now().millisecondsSinceEpoch.toString(),
          'claim_no': 'new val',
          'carrier_id': 'new val',
          'sales_rep_id': _user.$id,
        },
        read: [
          ///! use this when payload create
          'user:${_user.$id}',
          'team:620c6e12b9278e4aa747',
          // 'team:' + teams.list().
        ],
        write: ['user:${_user.$id}'],
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
          'ststus': currentItemStatus
        },
        read: [
          ///! use this when payload create
          'user:${_user.$id}',
          'team:620c6e12b9278e4aa747'
          // 'team:' + teams.list().
        ],
        write: ['user:${_user.$id}'],
        // documentId: 'unique()',
      );
      itemToEdit = null;
    } on AppwriteException catch (e) {
      print(e.message);
    }
  }
}