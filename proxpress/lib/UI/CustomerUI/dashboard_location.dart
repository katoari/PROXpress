import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/classes/customer_classes/notif_counter_customer.dart';
import 'package:proxpress/classes/customer_classes/pin_widget.dart';
import 'package:proxpress/classes/verify.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/services/auth.dart';
import 'menu_drawer_customer.dart';
import 'notif_drawer_customer.dart';
import 'package:proxpress/services/database.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/models/customers.dart';
import 'dart:async';
import 'dart:math' show cos, sqrt, asin;

class DashboardLocation extends StatefulWidget{
  @override
  _DashboardLocationState createState() => _DashboardLocationState();
}

class _DashboardLocationState extends State<DashboardLocation>{

  final bool notBookmarks = false;
  int duration = 60;
  int flag = 0;
  final AuthService _auth = AuthService();
  final textFieldPickup = TextEditingController();
  final textFieldDropOff = TextEditingController();



  void _openEndDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }

  final GlobalKey<FormState> locKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // verifyCond(){
  //   if(flag <= 0){
  //     print("outside");
  //     VerifyEmail();
  //     flag++;
  //   }
  //   return Container();
  // }


  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    User user = auth.currentUser;
    bool approved = true;

    return user == null ? LoginScreen() : StreamBuilder<Customer>(
      stream: DatabaseService(uid: user.uid).customerData,
      builder: (context, snapshot) {
        if(snapshot.hasData){
          Customer customerData = snapshot.data;
          print("Email: ${user.emailVerified}");
          Stream<List<Delivery>> deliveryList = FirebaseFirestore.instance
              .collection('Deliveries')
              .where('Customer Reference', isEqualTo: FirebaseFirestore.instance.collection('Customers').doc(user.uid))
              .snapshots()
              .map(DatabaseService().deliveryDataListFromSnapshot);

          return WillPopScope(
            onWillPop: () async {
              print("Back Button pressed");
              return false;
            },
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
                  )
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
              body: Column(
                children: [
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Text("Welcome, ${customerData.fName}!",
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                  ),
                  !user.emailVerified ? Container(
                    margin: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black)
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.info,
                              color: Colors.red,
                            ),
                            title: Text(
                              "Kindly verify your email ${user.email} to use the app.",
                              style: TextStyle(
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold
                              ),
                            ),

                          ),
                        ),
                        //verifyCond(),
                        VerifyEmail()
                      ],
                    ),
                  )
                      : SingleChildScrollView(
                    child: Center(
                      child: Column(
                        children: [
                          PinLocation(
                            locKey: locKey,
                            textFieldPickup: textFieldPickup,
                            textFieldDropOff: textFieldDropOff,
                            isBookmarks: false,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return UserLoading();
        }
      }
    );
  }
}





