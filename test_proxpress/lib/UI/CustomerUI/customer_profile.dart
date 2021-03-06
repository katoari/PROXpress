import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/services/auth.dart';
import 'package:proxpress/services/default_profile_pic.dart';
import 'notif_drawer_customer.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/models/customers.dart';

class CustomerProfile extends StatefulWidget {

  @override
  _CustomerProfileState createState() => _CustomerProfileState();
}
class _CustomerProfileState extends State<CustomerProfile> {

  void _openEndDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }
  // Future _getDefaultProfile(BuildContext context, String imageName) async {
  //   Image image;
  //   await FireStorageService.loadImage(context, imageName).then((value) {
  //     image = Image.network(
  //       value.toString(),
  //       // fit: BoxFit.scaleDown,
  //     );
  //   });
  //   return image;
  // }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _auth = AuthService();
  static Timer _sessionTimer;
  static Timer _sessionTimerPrint;
  int count = 0;
  int duration = 1;
  void handleTimeOut() async{
    await _auth.signOut();
  }
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);

      return new GestureDetector(
        onTap: (){
          if(count != 0){
            print("Session Revived");
          } else {
            print("Session Started");
            count=1;
          }
          _sessionTimer?.cancel();
          _sessionTimer = new Timer(Duration(minutes: duration), handleTimeOut);
          _sessionTimerPrint?.cancel();
          _sessionTimerPrint = new Timer(Duration(minutes: duration), () {
            print("Session Expired");
          });

        },
        child: user == null ? LoginScreen() : Scaffold(
            drawerEnableOpenDragGesture: false,
            endDrawerEnableOpenDragGesture: false,
            key:_scaffoldKey,
            appBar: AppBar(
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(color: Color(0xfffb0d0d),),
              leading: IconButton(icon: Icon(
                Icons.arrow_back,
              ),
                onPressed: (){
                  Navigator.pop(context, false);


                },
                iconSize: 25,
              ),
              actions: [
                IconButton(icon: Icon(
                  Icons.notifications_none_rounded,
                ),
                  onPressed: (){
                    _openEndDrawer();
                  },
                  iconSize: 25,
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
            endDrawer: NotifDrawerCustomer(),
            body: SingleChildScrollView(
              child: StreamBuilder<Customer>(
                  stream: DatabaseService(uid: user.uid).customerData,
                  builder: (context,snapshot){
                    if(snapshot.hasData){
                      Customer customerData = snapshot.data;
                      return Center(
                        child: SizedBox(
                          width: 300,
                          height: 500,
                          child: Card(
                            margin: EdgeInsets.fromLTRB(0, 100, 0, 0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  child: ClipOval(
                                    child: Image.network(customerData.avatarUrl,
                                      width:100,
                                      height: 100,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  child: Text(
                                    '${customerData.fName} ${customerData.lName}',
                                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  child: Text(
                                      customerData.address,
                                      style: TextStyle(fontSize: 15)
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  child: Text(
                                      customerData.email,
                                      style: TextStyle(fontSize: 15)
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  child: Text(
                                      customerData.contactNo,
                                      style: TextStyle(fontSize: 15)
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
                                  child: ElevatedButton.icon(
                                    icon: Icon(Icons.edit_rounded),
                                    label: Text('Edit Profile'),
                                    style : ElevatedButton.styleFrom(primary: Color(0xfffb0d0d)),
                                    onPressed: (){
                                      Navigator.pushNamed(context, '/customerUpdate');
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    else{
                      return UserLoading();
                    }
                  }
              ),

            )
        ),
      );
  }
}