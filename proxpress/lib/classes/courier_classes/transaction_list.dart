import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/classes/courier_classes/transaction_tile.dart';
import 'package:proxpress/models/deliveries.dart';

class TransactionList extends StatefulWidget {

  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  @override
  Widget build(BuildContext context) {
    final delivery = Provider.of<List<Delivery>>(context);

    if(delivery.length != 0){
      return delivery == null ? UserLoading() : ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: delivery.length,
        itemBuilder: (context, index) {
          return TransactionTile(delivery: delivery[index]);
        },
      );
    }
    else{
      return Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'You currently have no pending requests.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
}
