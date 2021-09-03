import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/courier_tile.dart';
import 'package:proxpress/couriers.dart';
import 'package:proxpress/login_screen.dart';

class CourierList extends StatefulWidget {
  @override
  _CourierListState createState() => _CourierListState();
}

class _CourierListState extends State<CourierList> {
  @override
  Widget build(BuildContext context) {
    final courier = Provider.of<List<Courier>>(context);

    if (courier != null && courier.length > 0) {
      return SizedBox(
        child: ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return CourierTile(courier: courier[index]);
          },
          itemCount: courier.length,
        ),
      );
    } else return Container();
  }
}
