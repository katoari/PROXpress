import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/services/database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomerRemarks extends StatefulWidget {
  final String courierUID;
  final String pickupAddress;
  final LatLng pickupCoordinates;
  final String dropOffAddress;
  final LatLng dropOffCoordinates;
  final int deliveryFee;

  CustomerRemarks({
    Key key,
    @required this.courierUID,
    @required this.pickupAddress,
    @required this.pickupCoordinates,
    @required this.dropOffAddress,
    @required this.dropOffCoordinates,
    @required this.deliveryFee,
  }) : super(key: key);

  @override
  _CustomerRemarksState createState() => _CustomerRemarksState();
}

class _CustomerRemarksState extends State<CustomerRemarks> {
  String itemDescription;
  String senderName;
  String senderContactNum;
  String receiverName;
  String receiverContactNum;
  String whoWillPay;
  String specificInstructions;
  String paymentOption = 'Choose Payment Option';
  String onlinePayment = '';
  
  void _validate(){
    if(!locKey.currentState.validate()){
      return;
    }
    locKey.currentState.save();
    print (itemDescription);
    print (senderName);
    print (senderContactNum);
    print (receiverName);
    print (receiverContactNum);
    print (whoWillPay);
    print (specificInstructions);
    print (paymentOption);
  }

  final GlobalKey<FormState> locKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Function to create a text field but modular for other variables
  Widget _buildTextField(String labelText, IconData icon, TextInputType textInputType, String error, dynamic textFieldInput){
    return Container(
      padding: EdgeInsets.fromLTRB(25, 0, 25, 25),
      child: TextFormField(
        decoration: InputDecoration(labelText: labelText, prefixIcon: Icon(icon)),
        keyboardType: textInputType,
        validator: (String value){
          if(value.isEmpty){
            return error;
          }
          else return null;
        },
        onSaved: (String value){
          textFieldInput = value;
        },
      ),
    );
  }

  Widget _buildItemDescription() {
    return Container(
      padding: EdgeInsets.fromLTRB(25, 0, 25, 25),
      child: TextFormField(
        decoration: InputDecoration(labelText: 'Item Description', prefixIcon: Icon(Icons.description_rounded,)),
        keyboardType: TextInputType.text,
        validator: (String value){
          if(value.isEmpty){
            return 'Item description is required.';
          }
          else return null;
        },
        onSaved: (String value){
          itemDescription = value;
        },
        onChanged: (String value){
          setState(() => itemDescription = value);
        },
      ),
    );
  }
  Widget _buildSenderName() {
    return Container(
      padding: EdgeInsets.fromLTRB(25, 0, 25, 25),
      child: TextFormField(
        decoration: InputDecoration(labelText: 'Sender Name', prefixIcon: Icon(Icons.person_rounded,)),
        keyboardType: TextInputType.name,
        validator: (String value){
          if(value.isEmpty){
            return 'Sender name is required.';
          }
          else return null;
        },
        onSaved: (String value){
          senderName = value;
        },
        onChanged: (String value){
          setState(() => senderName = value);
        },
      ),
    );
  }
  Widget _buildSenderContactNum() {
    return Container(
      padding: EdgeInsets.fromLTRB(25, 0, 25, 25),
      child: TextFormField(
        maxLength: 11,
        decoration: InputDecoration(labelText: 'Sender Contact Number', prefixIcon: Icon(Icons.phone_rounded,)),
        keyboardType: TextInputType.number,
        validator: (String value){
          if(value.length < 11 && value.length > 0){
            return 'Your sender contact number should be 11 digits.';
          }
          else if(value.isEmpty){
            return 'Sender contact number is required.';
          }
          else return null;
        },
        onSaved: (String value){
          senderContactNum = value;
        },
        onChanged: (String value){
          setState(() => senderContactNum = value);
        },
      ),
    );
  }
  Widget _buildReceiverName() {
    return Container(
      padding: EdgeInsets.fromLTRB(25, 0, 25, 25),
      child: TextFormField(
        decoration: InputDecoration(labelText: 'Receiver Name', prefixIcon: Icon(Icons.person_rounded,)),
        keyboardType: TextInputType.name,
        validator: (String value){
          if(value.isEmpty){
            return 'Receiver name is required.';
          }
          else return null;
        },
        onSaved: (String value){
          receiverName = value;
        },
        onChanged: (String value){
          setState(() => receiverName = value);
        },
      ),
    );
  }
  Widget _buildReceiverContactNum() {
    return Container(
      padding: EdgeInsets.fromLTRB(25, 0, 25, 25),
      child: TextFormField(
        maxLength: 11,
        decoration: InputDecoration(labelText: 'Receiver Contact Number', prefixIcon: Icon(Icons.phone_rounded,)),
        keyboardType: TextInputType.number,
        validator: (String value){
          if(value.length < 11 && value.length > 0){
            return 'Your receiver contact number should be 11 digits.';
          }
          else if(value.isEmpty){
            return 'Receiver contact number is required.';
          }
          else return null;
        },
        onSaved: (String value){
          receiverContactNum = value;
        },
        onChanged: (String value){
          setState(() => receiverContactNum = value);
        },
      ),
    );
  }
  Widget _buildWhoWillPay() {
    return Container(
      padding: EdgeInsets.fromLTRB(25, 0, 25, 25),
      child: TextFormField(
        decoration: InputDecoration(labelText: 'Who Will Pay', prefixIcon: Icon(Icons.person_pin_circle_rounded,)),
        keyboardType: TextInputType.name,
        validator: (String value){
          if(value.isEmpty){
            return 'Who will pay must be specified.';
          }
          else return null;
        },
        onSaved: (String value){
          whoWillPay = value;
        },
        onChanged: (String value){
          setState(() => whoWillPay = value);
        },
      ),
    );
  }
  Widget _buildSpecificInstructions() {
    return Container(
      padding: EdgeInsets.fromLTRB(25, 0, 25, 25),
      child: TextFormField(
        maxLines: null,
        maxLength: 200,
        decoration: InputDecoration(labelText: 'Specific Instructions', prefixIcon: Icon(Icons.workspaces_rounded,)),
        keyboardType: TextInputType.text,
        validator: (String value){
          if(value.isEmpty){
            return 'Item description is required.';
          }
          else return null;
        },
        onSaved: (String value){
          specificInstructions = value;
        },
        onChanged: (String value){
          setState(() => specificInstructions = value);
        },
      ),
    );
  }
  Widget _buildDropDown(){
    return Container(
      padding: EdgeInsets.fromLTRB(25, 0, 25, 25),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Payment Method',
          prefixIcon: Icon(Icons.payment_rounded),
        ),
        iconSize: 20,
        elevation: 16,
        onChanged: (String newValue) {
          setState(() {
            paymentOption = newValue;
          });
        },
        items: <String>['Cash on Delivery', 'Online Payment']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRadioPayment(){
    return Column(
      children: [
        ListTile(
          title: Container(
            child: Row(
              children: [
                Image.asset("assets/gcash.png", height: 50, width: 50,),
                Text("GCash"),
              ],
            ),
          ),
          leading: Radio(
            value: 'Gcash',
            groupValue: onlinePayment,
            onChanged: (value) {
              setState(() {
                onlinePayment = value;
              });
            },
            activeColor: Color(0xfffb0d0d),
          ),
        ),
        ListTile(
          title: Container(
            child: Row(
              children: [
                Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Image.asset("assets/paymaya.png", height: 25, width: 25,)
                ),
                Container(
                    margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
                    child: Text("Paymaya")
                ),
              ],
            ),
          ),
          leading: Radio(
            value: 'Paymaya',
            groupValue: onlinePayment,
            onChanged: (value) {
              setState(() {
                onlinePayment = value;
              });
            },
            activeColor: Color(0xfffb0d0d),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {


    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;

    print(user.uid);
    print(widget.courierUID);
    print(widget.pickupAddress);
    print(widget.pickupCoordinates.toString());
    print(widget.dropOffAddress);
    print(widget.dropOffCoordinates.toString());

    DocumentReference customer = FirebaseFirestore.instance.collection('Customers').doc(user.uid);
    DocumentReference courier = FirebaseFirestore.instance.collection('Couriers').doc(widget.courierUID);

    GeoPoint pickupGeoPoint = GeoPoint(widget.pickupCoordinates.latitude, widget.pickupCoordinates.longitude);
    GeoPoint dropOffGeoPoint = GeoPoint(widget.dropOffCoordinates.latitude, widget.dropOffCoordinates.longitude);

    print(pickupGeoPoint.toString());
    print(dropOffGeoPoint.toString());

    return Scaffold(
        drawerEnableOpenDragGesture: false,
        endDrawerEnableOpenDragGesture: false,
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Color(0xfffb0d0d),),
          actions: [
            IconButton(icon: Icon(
              Icons.help_outline,
            ),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context){
                      return AlertDialog(
                        title: Text("Help"),
                        content: Text('nice'),
                        actions: [
                          TextButton(
                            child: Text("OK"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    }
                );
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
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        "Customer Remarks",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.all(40),
                  child: Form(
                    key: locKey,
                    child: Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildItemDescription(),
                          _buildSenderName(),
                          _buildSenderContactNum(),
                          _buildReceiverName(),
                          _buildReceiverContactNum(),
                          _buildWhoWillPay(),
                          _buildSpecificInstructions(),
                          _buildDropDown(),
                          paymentOption == 'Online Payment' ? _buildRadioPayment() : SizedBox(height: 30),
                        ],
                      ),
                      shadowColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  child: Text(
                    'Send Remarks',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(primary: Color(0xfffb0d0d)),
                  onPressed: () async {
                    _validate();
                    if (locKey.currentState.validate()){
                      await DatabaseService().updateDelivery(customer, courier, widget.pickupAddress, pickupGeoPoint, widget.dropOffAddress, dropOffGeoPoint, itemDescription, senderName, senderContactNum, receiverName, receiverContactNum, whoWillPay, specificInstructions, paymentOption, widget.deliveryFee, 'Pending', 'Pending');
                    }
                  }
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        )
    );
  }
}