import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:deelz/core/presentation/notifiers/auth_state.dart';
import 'package:deelz/core/presentation/notifiers/transaction_state.dart';
import 'package:deelz/core/res/app_constants.dart';
import 'package:deelz/data/model/transaction.dart';
import 'package:deelz/extensions.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TransactionList extends StatefulWidget {
  const TransactionList({Key? key}) : super(key: key);

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  // Create an instance variable.
  // this helps avoid endless fetch
  late final Future<List<Transaction>> myFuture;

  List<Transaction> txs = [];
  //the tx to edit in the modal bottom sheet

  Transaction? myTransaction;
  late bool _show;
  int _txType = 1;
  //TextControllers kept changing value with the one from the listview when loading a Transaction onto the bottomSheet
  bool allowEdits = false;

  @override
  void initState() {
    super.initState();
    _show = false;
    myFuture = _getTransactions();
  }
/* 
  @override
  void dispose() {
    super.dispose();
    // TransactionState().dispose();
  } */

  Future<List<Transaction>> _getTransactions() async {
    List<Transaction> transactions = [];
    Future data = TransactionState().transactions().then((datos) {
      for (var el in datos) {
        transactions.add(el);
      }
    });

    // data.forEach((el) => transactions.add(el));
    return transactions;
  }

  void resetInputControls() {
    _txtTitle.clear();
    _txtDescription.clear();
    _txtAmount.clear();
  }

  //model vars
  TextEditingController _txtTitle = TextEditingController();
  TextEditingController _txtDescription = TextEditingController();
  TextEditingController _txtTxType = TextEditingController();
  TextEditingController _txtTxDate = TextEditingController();
  TextEditingController _txtAmount = TextEditingController();

  @override
  Widget build(BuildContext context) {
    TransactionState state =
        Provider.of<TransactionState>(context, listen: true);

    return Scaffold(
      // backgroundColor: const Color(0xff496684),
      floatingActionButton: _buildFAB(),
      body: FutureBuilder(
          future: myFuture,
          builder: (BuildContext context,
              AsyncSnapshot<List<Transaction>> snapshot) {
            if (snapshot.connectionState == AsyncSnapshot.waiting()) {
              return CircularProgressIndicator();
            } else if (snapshot.hasData) {
              // List<Transaction> statuses = snapshot ;
              print('future of Transactions fetched');
              return buildTransactionList(context, snapshot);
            } else {
              return Container(
                child: Center(child: Text('no data')),
              );
            }
          }),
      //load transaction onto bottomsheet
      bottomSheet: _showBottomSheet(),
    );
  }

  Widget buildTransactionList(BuildContext context, AsyncSnapshot snapshot) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: snapshot.data!.length,
      itemBuilder: (context, index) {
        Transaction transaction = snapshot.data![index];
        final Key? key;
        return Card(
          // color: Colors.white.withOpacity(0.03),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 1.0),
            child: Slidable(
              key: const ValueKey(3),
              startActionPane: ActionPane(
                // A motion is a widget used to control how the pane animates.
                motion: const ScrollMotion(),

                // A pane can dismiss the Slidable.
                /* dismissible: DismissiblePane(
                                      key: widget.key,
                                      onDismissed: () {
                                        setState(() {});
                                      }), */

                // All actions are defined in the children parameter.
                children: [
                  // A SlidableAction can have an icon and/or a label.
                  SlidableAction(
                    onPressed: (BuildContext contex) =>
                        _removeItem(context, transaction.id.toString()),
                    backgroundColor: const Color(0xFFFE4A49),
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                  SlidableAction(
                    onPressed: (BuildContext ctx) {
                      _show = true;
                      myTransaction = transaction;
                      allowEdits = true;
                      // setState(() {});
                      _showBottomSheet();
                    },
                    //lambda
                    /* (BuildContext context) =>
                                        _showBottomSheet(context,
                                            transaction: transaction), */

                    backgroundColor: const Color(0xFF21B7CA),
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: 'Edit',
                  ),
                ],
              ),
              //blank bottomsheet
              child: buildListTile(transaction),
            ),
          ),
        );
      },
    );
  }

  FloatingActionButton _buildFAB() {
    return _show
        ? FloatingActionButton(
            onPressed: () {
              setState(() {
                _show = !_show;
              });
            },
            child: const Icon(Icons.close),
          )
        : FloatingActionButton(
            onPressed: () {
              setState(() {
                _show = !_show;
              });
            },
            child: const Icon(Icons.add));
  }

  Widget buildListTile(Transaction transaction) {
    return Container(
      child: ListTile(
        leading: Icon(transaction.transactionType == 2
            ? Icons.account_balance_wallet
            : Icons.view_list),
        title: Text(transaction.title ?? "n/a"),
        subtitle: Text(DateFormat.yMMMEd()
            .format(transaction.transactionDate as DateTime)),
        trailing:
            // padding: const EdgeInsets.only(bottom: 18.0),
            Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(transaction.amount.toString()),
            InkWell(
              onTap: () {
                /*   var res =
                    TransactionState().deleteTx(tx: transaction.id.toString()); */
                //call your onpressed function here
                print('Button Pressed');
              },
              child: const Icon(Icons.delete),
            ),
          ],
        ),
      ),
    ).addNeumorphism();
  }

  void _popSheet(BuildContext ctx) {
    _show = true;
  }

  _removeItem(BuildContext ctx, String item) async {
    //remove item from db

    var res = await TransactionState().deleteTx(tx: item);
    if (res) {
      print('we have deleted $item');
    }
  }

  Widget? _showBottomSheet() {
    if (myTransaction != null && allowEdits == true) {
      _txType = myTransaction!.transactionType!;
      _txtTitle.text = myTransaction!.title!;
      _txtDescription.text = myTransaction!.description!.toString();
      _txtTxType.text = myTransaction!.transactionType!.toString();
      _txtAmount.text = myTransaction!.amount.toString();
    }
    allowEdits = false;
    //
    /*  String? title,
      String? description,
      double? amount,
      int? txType */
    if (_show) {
      return BottomSheet(
        // backgroundColor: Colors.teal,
        onClosing: () {},
        builder: (context) {
          return SingleChildScrollView(
            child: Container(
              // height: 200,
              width: double.infinity,
              // color: Colors.grey.shade200,
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 22),
                    TextField(
                      controller: _txtTitle,
                      decoration: InputDecoration(
                        labelText: "Title",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13.0)),
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _txtDescription,
                      decoration: InputDecoration(
                        labelText: "Description",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13.0)),
                      ),
                    ),

                    Row(
                      children: [
                        const Icon(
                          Icons.list,
                          color: Colors.red,
                        ),
                        Radio<int>(
                            value: 1,
                            groupValue: _txType,
                            onChanged: (value) => setState(() {
                                  _txType = 1;
                                })),
                        const Spacer(),
                        const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Colors.green,
                        ),
                        Radio<int>(
                            value: 2,
                            groupValue: _txType,
                            onChanged: (value) => setState(() {
                                  _txType = 2;
                                })),
                        const Spacer(),
                        Text(_txType == 1 ? "Expense" : "Income"),
                      ],
                    ),
                    const Text('Transaction Date'),

                    TextField(
                      controller: _txtAmount,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Amount",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13.0)),
                      ),
                    ),

                    ///save button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          child: const Text("Save"),
                          style: ElevatedButton.styleFrom(
                            onPrimary: Colors.white,
                            primary: Colors.blue,
                          ),
                          onPressed: () async {
                            //same button for create and update
                            _show = true;
                            TransactionState().saveTransaction(
                                _txtTitle.text,
                                _txtDescription.text,
                                double.parse(_txtAmount.text),
                                _txType,
                                DateTime.now(),
                                txId: myTransaction);

                            allowEdits = false;
                            //clear the input form
                            resetInputControls();
                            setState(() {
                              _show = !_show;
                            });
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else {
      return null;
    }
  }
}
