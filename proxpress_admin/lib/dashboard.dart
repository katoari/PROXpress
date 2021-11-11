import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/courier_list.dart';
import 'package:proxpress/couriers.dart';
import 'package:proxpress/database.dart';
import 'package:proxpress/delivery_price_list.dart';
import 'package:proxpress/delivery_prices.dart';
import 'package:proxpress/login_screen.dart';
import 'package:proxpress/report_list.dart';
import 'package:proxpress/reports.dart';
import 'package:url_launcher/url_launcher.dart';
import 'auth.dart';

class Dashboard extends StatefulWidget {
  final String savedPassword;
  Dashboard({this.savedPassword});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {
  final AuthService _auth = AuthService();
  int activeTab = 0;

  @override
  Widget build(BuildContext context) {



    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;

    return AdminScaffold(
      backgroundColor: Colors.white,
      sideBar: SideBar(
        iconColor: Colors.red,
        activeIconColor: Colors.white,
        activeTextStyle: TextStyle(color: Colors.white,),
        textStyle: TextStyle(color: Colors.red),
        activeBackgroundColor: Colors.red,
        items: const [
          MenuItem(
            title: 'Courier',
            route: '/dashboard',
            icon: Icons.local_shipping_rounded,
          ),
          MenuItem(
            title: 'Delivery Prices',
            route: '/prices',
            icon: Icons.price_change,
          ),
          MenuItem(
            title: 'Reports',
            route: '/reports',
            icon: Icons.report_problem,
          ),
        ],
        selectedRoute: '/dashboard',
        onSelected: (item) {
          if (item.route != null) {
            Navigator.of(context).pushNamed(item.route);
          }
        },
        header: Container(
          height: 100,
          width: double.infinity,
          color: Color(0xFFEEEEEE),
          child: Center(
            child: Container(
              child: Image.asset('assets/PROXpressLogo.png'),
            )
          ),
        ),
        footer: Container(
          height: 50,
          width: double.infinity,
          child: Center(
            child: Container(
              height: MediaQuery.of(context).size.height / 20,
              width: MediaQuery.of(context).size.width / 1,
              child: ElevatedButton.icon(
                label: Text('Logout'),
                icon: Icon(Icons.logout_rounded),
                style: ElevatedButton.styleFrom(primary: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),),
                onPressed: () async{
                  print(user.uid);
                  if (user != null) {
                    await _auth.signOut();
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                },
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Courier>>(
          stream: DatabaseService().courierList,
        builder: (context, snapshot) {
          if(snapshot.hasData){
            List<Courier> couriers = snapshot.data;

            List<PlutoColumn> columns = [
              PlutoColumn(
                enableRowChecked: true,
                enableEditingMode: false,
                title: 'Name',
                field: 'name',
                type: PlutoColumnType.text(),
              ),
              PlutoColumn(
                enableEditingMode: false,
                title: 'Address',
                field: 'address',
                type: PlutoColumnType.text(),
              ),
              PlutoColumn(
                enableEditingMode: false,
                title: 'Email',
                field: 'email',
                type: PlutoColumnType.text(),
              ),
              PlutoColumn(
                enableEditingMode: false,
                title: 'Vehicle Type',
                field: 'vehicle_type',
                type: PlutoColumnType.text(),
              ),
              PlutoColumn(
                  enableEditingMode: false,
                title: 'Vehicle Color',
                field: 'vehicle_color',
                type: PlutoColumnType.text(),
                renderer: (rendererContext){
                  //print(rendererContext.cell.value);
                  return Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border.all(),
                      shape: BoxShape.circle,
                      color: Color(rendererContext.cell.value),
                    ),
                  );
                }
              ),

              PlutoColumn(
                enableEditingMode: false,
                title: 'Credentials',
                field: 'credentials',
                type: PlutoColumnType.text(),
                renderer: (rendererContext) {
                  return InkWell(
                    child: new Text('View Credentials', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline,),),
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) => StatefulBuilder(
                            builder: (context, setState){
                              return AlertDialog(
                                  content: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                          child: Image.network(rendererContext.cell.value)
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text("OK"),
                                      onPressed: () async {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ]);
                            },
                          )
                      );
                    }
                  );
                  },
              ),
              PlutoColumn(
                title: 'Verdict',
                field: 'commands',
                type: PlutoColumnType.select(<bool>[true, false]),
                formatter: (dynamic value){
                  switch (value) {
                    case true:
                      return 'Approved';
                    case false:
                      return 'Disapproved';
                  }
                  return null;
                }
              ),
            ];

            List<PlutoRow> rows = List.generate(couriers.length, (index) {
              // List credentials = [
              //   couriers[index].driversLicenseFront_,
              //   couriers[index].driversLicenseBack_,
              //   couriers[index].nbiClearancePhoto_,
              //   couriers[index].vehicleRegistrationOR_,
              //   couriers[index].vehicleRegistrationCR_,
              //   couriers[index].vehiclePhoto_
              // ];
              return PlutoRow(
                cells: {
                  'name': PlutoCell(value: "${couriers[index].fName} ${couriers[index].lName}"),
                  'address': PlutoCell(value: couriers[index].address),
                  'email': PlutoCell(value: couriers[index].email),
                  'vehicle_type': PlutoCell(value: couriers[index].vehicleType),
                  'vehicle_color': PlutoCell(value: couriers[index].vehicleColor),
                  'credentials': PlutoCell(value: couriers[index].driversLicenseFront_),
                  'commands' : PlutoCell(value: couriers[index].approved)
                },
              );
            });

            return Padding(
              padding: EdgeInsets.all(100),
              child: PlutoGrid(
                  columns: columns,
                  rows: rows,
                  // onChanged: (PlutoGridOnChangedEvent event) {
                  //   //print(event);
                  //   print(event.rowIdx);
                  // },
                  // onLoaded: (PlutoGridOnLoadedEvent event) {
                  //   print(event.stateManager.currentSelectingPosition);
                  // },
                onRowChecked: (PlutoGridOnRowCheckedEvent event){
                    if(event.row.checked == true){
                      print('something');
                    }
                    else print('something here to');
                    //print(event.row.checked);
                    },
                // onLoaded: (PlutoGridOnLoadedEvent event){
                //   event.stateManager!
                //       .setSelectingMode(PlutoGridSelectingMode.cell);
                //
                //   stateManager = event.stateManager;
                // },
                createHeader: (PlutoGridStateManager){
                    return Text('Couriers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30));
                },
                  // createFooter: (PlutoGridStateManager){
                  //   return Row(
                  //     mainAxisAlignment: MainAxisAlignment.end,
                  //     children: [
                  //       ElevatedButton(
                  //           child: Text('Approve'),
                  //           onPressed: (){
                  //
                  //           }
                  //       ),
                  //       ElevatedButton(
                  //           child: Text('Notify Reason'),
                  //           onPressed: (){
                  //             String _adminMessage = " ";
                  //             showDialog(
                  //                 context: context,
                  //                 builder: (BuildContext context) => StatefulBuilder(
                  //                   builder: (context, setState){
                  //                     return AlertDialog(
                  //                         content: Column(
                  //                           crossAxisAlignment: CrossAxisAlignment.center,
                  //                           mainAxisSize: MainAxisSize.min,
                  //                           children: [
                  //                             ListTile(
                  //                               title: Text("Notify the Courier", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                  //                             ),
                  //                             SizedBox(height: 20),
                  //                             SizedBox(
                  //                               width: 500,
                  //                               child: TextFormField(
                  //                                 maxLines: 2,
                  //                                 maxLength: 200,
                  //                                 decoration: InputDecoration(
                  //                                   hintText: 'Type something',
                  //                                   border: OutlineInputBorder(),
                  //                                 ),
                  //                                 keyboardType: TextInputType.multiline,
                  //                                 onChanged: (val) => setState(() => _adminMessage = val),
                  //                               ),
                  //                             ),
                  //                             Column(
                  //                               children: [
                  //                                 SizedBox(height: 30),
                  //                                 Text("Select the credential that is invalid.", style: TextStyle(fontWeight: FontWeight.bold),),
                  //                                 CheckboxListTile(
                  //                                   title: Text('Driver\'s License Front'),
                  //                                   value: false,
                  //                                   onChanged: (bool value) {
                  //                                     setState(() {
                  //                                       // credentials[0] = value;
                  //                                     });
                  //                                   },
                  //                                 ),
                  //                                 CheckboxListTile(
                  //                                   title: const Text('Driver\'s License Back'),
                  //                                   value: false,
                  //                                   onChanged: (bool value) {
                  //                                     setState(() {
                  //                                       // credentials[1] = value;
                  //                                     });
                  //                                   },
                  //                                 ),
                  //                                 CheckboxListTile(
                  //                                   title: const Text('NBI Clearance'),
                  //                                   value: false,
                  //                                   onChanged: (bool value) {
                  //                                     setState(() {
                  //                                       // credentials[2] = value;
                  //                                     });
                  //                                   },
                  //                                 ),
                  //                                 CheckboxListTile(
                  //                                   title: const Text('Vehicle Registration OR'),
                  //                                   value: false,
                  //                                   onChanged: (bool value) {
                  //                                     setState(() {
                  //                                       // credentials[3] = value;
                  //                                     });
                  //                                   },
                  //                                 ),
                  //                                 CheckboxListTile(
                  //                                   title: const Text('Vehicle Registration CR'),
                  //                                   value: false,
                  //                                   onChanged: (bool value) {
                  //                                     setState(() {
                  //                                       // credentials[4] = value;
                  //                                     });
                  //                                   },
                  //                                 ),
                  //                                 CheckboxListTile(
                  //                                   title: const Text('Vehicle Photo'),
                  //                                   value: false,
                  //                                   onChanged: (bool value) {
                  //                                     setState(() {
                  //                                       // credentials[5] = value;
                  //                                     });
                  //                                   },
                  //                                 ),
                  //                               ],
                  //                             ),
                  //                           ],
                  //                         ),
                  //
                  //                         actions: [
                  //                           TextButton(
                  //                             child: Text("Send"),
                  //                             onPressed: () async {
                  //                               // await DatabaseService(uid: widget.courier.uid).updateCourierMessage(_adminMessage);
                  //                               // await DatabaseService(uid: widget.courier.uid).updateCredentials(credentials);
                  //                               Navigator.pop(context);
                  //                             },
                  //                           ),
                  //                         ]);
                  //                   },
                  //                 )
                  //             );
                  //           }
                  //       ),
                  //     ],
                  //   );
                  // },
              ),
            );
          }
          else return Container();
        }
      ),
    );
  }
}
