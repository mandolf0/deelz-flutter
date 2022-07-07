import 'package:flutter/material.dart';
import 'package:deelz/core/presentation/notifiers/transaction_state.dart';
import 'package:deelz/data/model/transaction.dart';

class TxListPage extends StatefulWidget {
  const TxListPage({Key? key}) : super(key: key);

  @override
  State<TxListPage> createState() => _TxListPageState();
}

class _TxListPageState extends State<TxListPage> {
  Future<List<Transaction>> _getTransactions() async {
    var data = await TransactionState().transactions();

    List<Transaction> transactions = [];
    data.forEach((el) => transactions.add(el));
    return transactions;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: _getTransactions(),
        builder:
            (BuildContext context, AsyncSnapshot<List<Transaction>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.data != null) {
              if (snapshot.data!.length > 0) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, index) {
                    Transaction tran = snapshot.data![index];
                    return ListTile(
                      title: Text(tran.title!),
                    );
                  },
                );
              }
            } //snapshot has data

            return Container(
              child: Text('Something happened!'),
            );
          }
        },
      ),
    );
  }
}
