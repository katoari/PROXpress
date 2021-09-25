import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/classes/customer_classes/courier_bookmarks_tile.dart';
import 'package:proxpress/classes/customer_classes/notif_counter_customer.dart';
import 'package:proxpress/classes/customer_classes/pin_widget.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/services/auth.dart';
import 'package:proxpress/services/database.dart';
import 'menu_drawer_customer.dart';
import 'notif_drawer_customer.dart';

class CourierBookmarks extends StatefulWidget {

  @override
  _CourierBookmarksState createState() => _CourierBookmarksState();
}

class _CourierBookmarksState extends State<CourierBookmarks> {

  String deliveryPriceUid;
  double deliveryFee = 0.0;
  bool notBookmarks = true;
  final GlobalKey<FormState> locKey = GlobalKey<FormState>();
  final textFieldPickup = TextEditingController();
  final textFieldDropOff = TextEditingController();

  void _openEndDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;
    bool approved = true;
    if(user != null){
      Stream<List<Delivery>> deliveryList = FirebaseFirestore.instance
          .collection('Deliveries')
          .where('Customer Reference', isEqualTo: FirebaseFirestore.instance.collection('Customers').doc(user.uid))
          .snapshots()
          .map(DatabaseService().deliveryDataListFromSnapshot);



      return user == null ? LoginScreen():StreamProvider<List<Courier>>.value(
        value: DatabaseService().courierList,
        child: Scaffold(
          drawerEnableOpenDragGesture: false,
          endDrawerEnableOpenDragGesture: false,
          key: _scaffoldKey,
          appBar: AppBar(
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(
              color: Color(0xfffb0d0d),
            ),
            actions: [
              StreamProvider<List<Delivery>>.value(
                  value: deliveryList,
                  initialData: [],
                  child: NotifCounterCustomer(scaffoldKey: _scaffoldKey, approved: approved,)
              ),
            ],
            flexibleSpace: Container(
              margin: EdgeInsets.only(top: 10),
              child: Image.asset(
                "assets/PROExpress-logo.png",
                height: 120,
                width: 120,
              ),
            ),
            //title: Text("PROExpress"),
          ),
          drawer: MainDrawerCustomer(),
          endDrawer: NotifDrawerCustomer(),
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child:  Text(
                      "Bookmarked Couriers",
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                  ),
                   PinLocation(
                    locKey: locKey, textFieldPickup: textFieldPickup,
                    textFieldDropOff: textFieldDropOff, isBookmarks: notBookmarks,
                  ),
                  Card(
                    margin: EdgeInsets.all(20),
                    shadowColor: Colors.black,
                    child: CourierBookmarkTile(appear: false,),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),

                  ),
                // Container(
                //   margin: EdgeInsets.only(
                //       top: 10, bottom: 10, left: 100, right: 100),
                //   child: TextFormField(
                //     decoration: InputDecoration(
                //         labelText: 'Search',
                //         prefixIcon: Icon(Icons.search_rounded)),
                //   ),
                // ),
                //CourierList(),
                ],
              ),
            ),
          )
        ),
      );
    } else{
      return LoginScreen();
    }
  }
}
