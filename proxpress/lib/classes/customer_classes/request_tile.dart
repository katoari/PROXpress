import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/classes/chat_page.dart';
import 'package:proxpress/UI/CustomerUI/delivery_status.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/customers.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/services/database.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:proxpress/services/upload_file.dart';

class RequestTile extends StatefulWidget {
  RequestTile({Key key,}) : super(key: key);

  @override
  State<RequestTile> createState() => _RequestTileState();
}

class _RequestTileState extends State<RequestTile> {
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  String _description = "";
  GlobalKey<FormState> _keyCancel = GlobalKey<FormState>();
  String cancellationMessage = "";
  String reason = "";
  CollectionReference reportColl = DatabaseService().reportCollection;
  String localVal = "";
  File reportAttachment;
  String saveDestination = "";
  bool attachmentEmpty = false;
  String savedUrl = '';

  @override
  Widget build(BuildContext context) {

    final delivery = Provider.of<Delivery>(context);
    final auth = FirebaseAuth.instance;
    User user = auth.currentUser;

    var color;
    if(delivery.deliveryStatus == 'Ongoing'){
      color = Colors.orange;
    }
    else if(delivery.deliveryStatus == 'Pending'){
      color = Colors.blue;
    }
    else if (delivery.deliveryStatus == 'Delivered'){
      color = Colors.green;
    }
    else if (delivery.deliveryStatus == 'Cancelled'){
      color = Colors.red;
    }

    if(delivery.deliveryStatus == 'Ongoing'){
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder<Courier>(
            stream: DatabaseService(uid: delivery.courierRef.id).courierData,
            builder: (context, snapshot) {
              if(snapshot.hasData){
                Courier courierData = snapshot.data;
                return ExpansionTileCard(
                  title: Text("${courierData.fName} ${courierData.lName}",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  leading: Container(
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(courierData.avatarUrl),
                      backgroundColor: Colors.white,
                    ),
                  ),
                  subtitle: Container(
                    padding: EdgeInsets.only(top: 5),
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(text: "Status: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                        TextSpan(text: "${delivery.deliveryStatus} \n", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold, color: color)),
                        TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                        TextSpan(text: courierData.contactNo, style: TextStyle(color: Colors.black)),
                      ],
                      ),
                    ),
                  ),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(Icons.payments_rounded, color: Colors.red),
                                title: Text("Payment Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                subtitle: Container(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Text.rich(
                                    TextSpan(children: [
                                      TextSpan(text: "Mode of Payment: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "${delivery.paymentOption}\n", style: Theme.of(context).textTheme.bodyText2),
                                      TextSpan(text: '\n'),
                                      TextSpan(text: "Who Will Pay: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "${delivery.whoWillPay}\n",style: Theme.of(context).textTheme.bodyText2),
                                      TextSpan(text: '\n'),
                                      TextSpan(text: "Delivery Fee: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
                                      TextSpan(text: "\₱${delivery.deliveryFee}\n",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
                                    ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(Icons.info_rounded, color: Colors.red),
                                title: Text("Additional Information", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                subtitle: Container(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Text.rich(
                                    TextSpan(children: [
                                      TextSpan(text: "Pick Up Address: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "${delivery.pickupAddress}\n", style: Theme.of(context).textTheme.bodyText2),
                                      TextSpan(text: '\n'),
                                      TextSpan(text: "Drop Off Address: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "${delivery.dropOffAddress}\n", style: Theme.of(context).textTheme.bodyText2),
                                      TextSpan(text: '\n'),
                                      TextSpan(text: "Item Description: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "${delivery.itemDescription}\n",style: Theme.of(context).textTheme.bodyText2),
                                      TextSpan(text: "Specific Instructions: \n", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "${delivery.specificInstructions}\n",style: Theme.of(context).textTheme.bodyText2),
                                    ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(Icons.phone_rounded, color: Colors.red),
                                title: Text("Contact Information", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                subtitle: Container(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Text.rich(
                                    TextSpan(children: [
                                      TextSpan(text: "Pickup Point Person: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "${delivery.pickupPointPerson}\n",style: Theme.of(context).textTheme.bodyText2),
                                      TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "${delivery.pickupContactNum}\n",style: Theme.of(context).textTheme.bodyText2),
                                      TextSpan(text: "\n"),
                                      TextSpan(text: "Drop Off Point Person: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "${delivery.dropoffPointPerson}\n",style: Theme.of(context).textTheme.bodyText2),
                                      TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "${delivery.dropoffContactNum}\n",style: Theme.of(context).textTheme.bodyText2),
                                    ],
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                      height: 25,
                                      child: (() {
                                        return ElevatedButton.icon(
                                            icon: Icon(Icons.local_shipping_rounded, size: 20),
                                            label: Text('View Delivery', style: TextStyle(color: Colors.white, fontSize: 10),),
                                            onPressed: () {
                                              Navigator.push(context, PageTransition(child: DeliveryStatus(delivery: delivery), type: PageTransitionType.rightToLeftWithFade));
                                            }
                                        );
                                      }())
                                  ),
                                  SizedBox(width: 20,),
                                  Container(
                                      height: 25,
                                      child: (() {
                                        return ElevatedButton.icon(
                                            icon: Icon(Icons.message_rounded, size: 20),
                                            label: Text('Chat Courier', style: TextStyle(color: Colors.white, fontSize: 10),),
                                            onPressed: () {
                                              Navigator.push(context, PageTransition(child: ChatPage(delivery: delivery), type: PageTransitionType.rightToLeftWithFade));
                                            }
                                        );
                                      }())
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              else return Container();
            }
          ),
        ),
      );
    } else if(delivery.deliveryStatus == 'Delivered'){
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder<Courier>(
                stream: DatabaseService(uid: delivery.courierRef.id).courierData,
                builder: (context,snapshot){
                  if(snapshot.hasData){
                    Courier courierData = snapshot.data;
                    return ExpansionTileCard(
                      title: Text("${courierData.fName} ${courierData.lName}",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                      leading: Container(
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(courierData.avatarUrl),
                          backgroundColor: Colors.white,
                        ),
                      ),
                      subtitle: Container(
                        padding: EdgeInsets.only(top: 5),
                        child: Text.rich(
                          TextSpan(children: [
                            TextSpan(text: "Status: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                            TextSpan(text: "${delivery.deliveryStatus} \n", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold, color: color)),
                            TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                            TextSpan(text: courierData.contactNo, style: TextStyle(color: Colors.black)),
                          ],
                          ),
                        ),
                      ),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Column(
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.payments_rounded, color: Colors.red),
                                    title: Text("Payment Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                    subtitle: Container(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Text.rich(
                                        TextSpan(children: [
                                          TextSpan(text: "Mode of Payment: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                          TextSpan(text: "${delivery.paymentOption}\n", style: Theme.of(context).textTheme.bodyText2),
                                          TextSpan(text: '\n'),
                                          TextSpan(text: "Who Will Pay: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                          TextSpan(text: "${delivery.whoWillPay}\n",style: Theme.of(context).textTheme.bodyText2),
                                          TextSpan(text: '\n'),
                                          TextSpan(text: "Delivery Fee: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
                                          TextSpan(text: "\₱${delivery.deliveryFee}\n",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
                                        ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.info_rounded, color: Colors.red),
                                    title: Text("Additional Information", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                    subtitle: Container(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Text.rich(
                                        TextSpan(children: [
                                          TextSpan(text: "Pick Up Address: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                          TextSpan(text: "${delivery.pickupAddress}\n", style: Theme.of(context).textTheme.bodyText2),
                                          TextSpan(text: '\n'),
                                          TextSpan(text: "Drop Off Address: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                          TextSpan(text: "${delivery.dropOffAddress}\n", style: Theme.of(context).textTheme.bodyText2),
                                          TextSpan(text: '\n'),
                                          TextSpan(text: "Item Description: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                          TextSpan(text: "${delivery.itemDescription}\n",style: Theme.of(context).textTheme.bodyText2),
                                          TextSpan(text: "Specific Instructions: \n", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                          TextSpan(text: "${delivery.specificInstructions}\n",style: Theme.of(context).textTheme.bodyText2),
                                        ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.phone_rounded, color: Colors.red),
                                    title: Text("Contact Information", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                    subtitle: Container(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Text.rich(
                                        TextSpan(children: [
                                          TextSpan(text: "Pickup Point Person: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                          TextSpan(text: "${delivery.pickupPointPerson}\n",style: Theme.of(context).textTheme.bodyText2),
                                          TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                          TextSpan(text: "${delivery.pickupContactNum}\n",style: Theme.of(context).textTheme.bodyText2),
                                          TextSpan(text: "\n"),
                                          TextSpan(text: "Drop Off Point Person: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                          TextSpan(text: "${delivery.dropoffPointPerson}\n",style: Theme.of(context).textTheme.bodyText2),
                                          TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                          TextSpan(text: "${delivery.dropoffContactNum}\n",style: Theme.of(context).textTheme.bodyText2),
                                        ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                  height: 25,
                                  child: (() {
                                    if (delivery.deliveryStatus == "Delivered") {
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton.icon(
                                              icon: Icon(Icons.feedback, size: 20),
                                              label: Text('Send Feedback', style: TextStyle(color: Colors.white, fontSize: 10),),
                                              onPressed: !(delivery.rating == 0 && delivery.feedback == '') ? null : () {
                                                showFeedback(delivery);
                                              }
                                          ),
                                          ElevatedButton.icon(
                                              icon: Icon(Icons.outlined_flag, size: 20),
                                              label: Text('Report', style: TextStyle(color: Colors.white, fontSize: 10),),
                                              onPressed: delivery.isReported ==  true ? null : () async {
                                                await showDialog(
                                                    context: context,
                                                    builder: (context) => StatefulBuilder(
                                                      builder: (context, setState){
                                                        String fetchedUrl = "";
                                                        final reportAttachmentFileName =  reportAttachment != null ? Path.basename(reportAttachment.path) : 'No File Selected';
                                                        return SingleChildScrollView(
                                                          child: AlertDialog(
                                                            title: Stack(
                                                              alignment: AlignmentDirectional.topEnd,
                                                              children: [
                                                                Container(
                                                                  padding: EdgeInsets.only(bottom: 15),
                                                                  decoration: BoxDecoration(
                                                                    border: Border(
                                                                      bottom: BorderSide(color: Colors.grey[500])
                                                                    )
                                                                  ),
                                                                    child: Center(
                                                                        child: Text("Report Courier")
                                                                    ),
                                                                ),
                                                                Positioned(
                                                                  bottom: -85,
                                                                  top: -100,
                                                                  child: IconButton(
                                                                    icon: const Icon(Icons.close_sharp),
                                                                    color: Colors.redAccent,
                                                                    onPressed: () {
                                                                      Navigator.pop(context);
                                                                      setState((){
                                                                        reason = "";
                                                                        reportAttachment = null;
                                                                        attachmentEmpty = false;
                                                                      });
                                                                    },
                                                                  ),
                                                                ),
                                                              ],

                                                            ),
                                                            content: Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Align(
                                                                  child: Text(
                                                                    "Please select a reason",
                                                                    style: TextStyle(
                                                                      fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                  alignment: Alignment.topLeft,
                                                                ),
                                                                SizedBox(height: 5,),
                                                                Text(
                                                                  "if this courier commited undesireable act, get help before reporting to PROXpress. Don't wait.",
                                                                  style: TextStyle(
                                                                    fontSize: 12,
                                                                  ),
                                                                ),
                                                                SizedBox(height: 15,),
                                                                Form(
                                                                  key: _key,
                                                                  child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [

                                                                      DropdownButtonFormField<String>(
                                                                        validator: (value) => value == null ? 'Please choose a reason' : null,
                                                                        decoration: InputDecoration(
                                                                          border: new OutlineInputBorder(
                                                                              borderSide: new BorderSide(color: Colors.black)),
                                                                          labelText: "Reason why",
                                                                        ),
                                                                        isExpanded: true,

                                                                        icon: const Icon(Icons.arrow_downward),
                                                                        iconSize: 20,
                                                                        elevation: 16,
                                                                        onChanged: (String newValue) {
                                                                          setState(() {
                                                                            reason = newValue;
                                                                          });
                                                                          print(reason);
                                                                        },
                                                                        items: <String>['Parcel damaged or mishandled', 'Utterly long delivery time', 'Rudeness or harassment', 'Asking price beyond stated fee', 'Others',]
                                                                            .map<DropdownMenuItem<String>>((String value) {
                                                                          return DropdownMenuItem<String>(
                                                                            value: value,
                                                                            child: Text(value),
                                                                          );
                                                                        }).toList(),
                                                                      ),
                                                                      SizedBox(height: 10,),
                                                                      Visibility(
                                                                          visible: reason == "Others" ? true : false,
                                                                          child: TextFormField(
                                                                            validator: (value){
                                                                              reason = value;
                                                                              return value.isNotEmpty ? null : "Please provide a reason";
                                                                            },
                                                                            onChanged: (value) {

                                                                            },
                                                                            decoration:  InputDecoration(
                                                                              hintText: "Reason",
                                                                              hintStyle: TextStyle(
                                                                                  fontStyle: FontStyle.italic
                                                                              ),
                                                                              filled: true,


                                                                              focusedBorder: OutlineInputBorder(
                                                                                borderSide: BorderSide(
                                                                                  color: Colors.red,
                                                                                  width: 2,
                                                                                ),
                                                                                borderRadius: BorderRadius.circular(10.0),
                                                                              ),


                                                                            ),
                                                                          ),
                                                                      ),
                                                                      SizedBox(height: 10,),
                                                                      TextFormField(
                                                                        validator: (value){
                                                                          _description = value;
                                                                          return value.isNotEmpty ? null : "Please provide a reason";
                                                                        },
                                                                        minLines: 3,
                                                                        maxLines: null,
                                                                        maxLength: 100,
                                                                        keyboardType: TextInputType.multiline,
                                                                        onChanged: (value) {

                                                                        },
                                                                        decoration:  InputDecoration(
                                                                          hintText: "More details",
                                                                          hintStyle: TextStyle(
                                                                              fontStyle: FontStyle.italic
                                                                          ),
                                                                          filled: true,
                                                                          border: InputBorder.none,
                                                                          fillColor: Colors.grey[300],

                                                                          contentPadding: const EdgeInsets.all(30),
                                                                          focusedBorder: OutlineInputBorder(
                                                                            borderSide: BorderSide(
                                                                              color: Colors.red,
                                                                              width: 2,
                                                                            ),
                                                                            borderRadius: BorderRadius.circular(10.0),
                                                                          ),
                                                                          enabledBorder: UnderlineInputBorder(
                                                                            borderSide: BorderSide(color: Colors.white),
                                                                            borderRadius: BorderRadius.circular(10.0),
                                                                          ),

                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 10,),
                                                                      OutlinedButton(
                                                                        child: ListTile(
                                                                          title: Text('Add attachment'),
                                                                          subtitle: Text(reportAttachmentFileName),
                                                                          trailing: IconButton(
                                                                            icon: Icon(reportAttachmentFileName == 'No File Selected' ? Icons.attachment: Icons.cancel_outlined, color: Color(0xfffb0d0d),),
                                                                            onPressed:  reportAttachmentFileName == 'No File Selected' || reportAttachment == null ? null :(){
                                                                              setState(() {
                                                                                reportAttachment = null;
                                                                                attachmentEmpty = false;
                                                                              });
                                                                              print(reportAttachment);
                                                                            },
                                                                          ),
                                                                        ),
                                                                        onPressed: reportAttachmentFileName != 'No File Selected' || reportAttachment != null ? null : () async{
                                                                          String datetime = DateTime.now().toString();
                                                                          final result = await FilePicker.platform.pickFiles(allowMultiple: false);
                                                                          final path = result.files.single.path;
                                                                          setState(() {
                                                                            reportAttachment = File(path);
                                                                          });

                                                                          final attachmentDestination = 'Reports/${user.uid}/report_${user.uid}_$datetime';

                                                                          setState((){
                                                                            saveDestination = attachmentDestination.toString();
                                                                            if (saveDestination != null && saveDestination.length > 0) {
                                                                                  saveDestination = saveDestination.substring(0, saveDestination.length - 1);
                                                                            }
                                                                          });

                                                                        },
                                                                      ),
                                                                      SizedBox(height: 5,),
                                                                      Visibility(
                                                                        visible: attachmentEmpty,
                                                                        child: Container(
                                                                          margin: EdgeInsets.only(left: 25),
                                                                          child: Align(
                                                                            alignment: Alignment.topLeft,
                                                                            child: Text("Attachment is required",
                                                                                    style: TextStyle(
                                                                                      color: Colors.red,
                                                                                      fontSize: 12,
                                                                                    ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),


                                                              ],
                                                            ),
                                                            actions: <Widget> [
                                                              ElevatedButton(
                                                                child: Text("Report"),
                                                                onPressed: () async {
                                                                  print("not in");
                                                                  if(_key.currentState.validate() && reportAttachmentFileName != 'No File Selected'){
                                                                    print("in");
                                                                    setState((){
                                                                      attachmentEmpty = false;

                                                                    });

                                                                    await UploadFile.uploadFile(saveDestination, reportAttachment);

                                                                    savedUrl = await FirebaseStorage.instance
                                                                        .ref(saveDestination)
                                                                        .getDownloadURL();

                                                                    if (savedUrl != null || savedUrl == 'null') {
                                                                      await DatabaseService(uid: user.uid).updateCustomerProfilePic(savedUrl);
                                                                    }

                                                                    setState(() {
                                                                      fetchedUrl = savedUrl;
                                                                    });
                                                                    print(fetchedUrl);
                                                                    DatabaseService().createReportData(_description, delivery.customerRef,
                                                                        delivery.courierRef, Timestamp.now(), reason , fetchedUrl);
                                                                    DatabaseService(uid: delivery.uid).updateReport(true);
                                                                    Navigator.of(context).pop();
                                                                    showToast('Report sent.');
                                                                    setState(() {
                                                                      reportAttachment = null;
                                                                    });

                                                                  } else{
                                                                    if(reportAttachmentFileName == 'No File Selected'){
                                                                      print("Attachment is required");
                                                                      setState((){
                                                                        attachmentEmpty = true;
                                                                      });
                                                                    }

                                                                  }
                                                                },
                                                              )
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    )
                                                );
                                                // report a courier
                                              }
                                          ),
                                        ],

                                      );
                                    }
                                  }())
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  else return Container();
                }
            )
        ),
      );
    } else if(delivery.courierApproval == 'Pending' || delivery.deliveryStatus == 'Pending') {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder<Courier>(
            stream: DatabaseService(uid: delivery.courierRef.id).courierData,
            builder: (context,snapshot){
              if(snapshot.hasData){
                Courier courierData = snapshot.data;
                return ExpansionTileCard(
                  title: Text("${courierData.fName} ${courierData.lName}",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  leading: Container(
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(courierData.avatarUrl),
                      backgroundColor: Colors.white,
                    ),
                  ),
                  subtitle: Container(
                    padding: EdgeInsets.only(top: 5),
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(text: "Status: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                        TextSpan(text: "${delivery.courierApproval} \n", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold, color: color)),
                        TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                        TextSpan(text: courierData.contactNo, style: TextStyle(color: Colors.black)),
                      ],
                      ),
                    ),
                  ),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(Icons.payments_rounded, color: Colors.red),
                                title: Text("Payment Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                subtitle: Container(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Text.rich(
                                    TextSpan(children: [
                                      TextSpan(text: "Mode of Payment: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "${delivery.paymentOption}\n", style: Theme.of(context).textTheme.bodyText2),
                                      TextSpan(text: '\n'),
                                      TextSpan(text: "Who Will Pay: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "${delivery.whoWillPay}\n",style: Theme.of(context).textTheme.bodyText2),
                                      TextSpan(text: '\n'),
                                      TextSpan(text: "Delivery Fee: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
                                      TextSpan(text: "\₱${delivery.deliveryFee}\n",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
                                    ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(Icons.info_rounded, color: Colors.red),
                                title: Text("Additional Information", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                subtitle: Container(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Text.rich(
                                    TextSpan(children: [
                                      TextSpan(text: "Pick Up Address: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "${delivery.pickupAddress}\n", style: Theme.of(context).textTheme.bodyText2),
                                      TextSpan(text: '\n'),
                                      TextSpan(text: "Drop Off Address: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "${delivery.dropOffAddress}\n", style: Theme.of(context).textTheme.bodyText2),
                                      TextSpan(text: '\n'),
                                      TextSpan(text: "Item Description: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "${delivery.itemDescription}\n",style: Theme.of(context).textTheme.bodyText2),
                                      TextSpan(text: "Specific Instructions: \n", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "${delivery.specificInstructions}\n",style: Theme.of(context).textTheme.bodyText2),
                                    ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(Icons.phone_rounded, color: Colors.red),
                                title: Text("Contact Information", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                subtitle: Container(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Text.rich(
                                    TextSpan(children: [
                                      TextSpan(text: "Pick up Point Person: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "${delivery.pickupPointPerson}\n",style: Theme.of(context).textTheme.bodyText2),
                                      TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "${delivery.pickupContactNum}\n",style: Theme.of(context).textTheme.bodyText2),
                                      TextSpan(text: "\n"),
                                      TextSpan(text: "Drop Off Point Person: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "${delivery.dropoffPointPerson}\n",style: Theme.of(context).textTheme.bodyText2),
                                      TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "${delivery.dropoffContactNum}\n",style: Theme.of(context).textTheme.bodyText2),
                                    ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                              height: 25,
                              child: ElevatedButton.icon(
                                  icon: Icon(Icons.cancel),
                                  label: Text('Cancel', style: TextStyle(color: Colors.white, fontSize: 10),),
                                  onPressed: () async {
                                    await showDialog(
                                        context: context,
                                        builder: (context) => StatefulBuilder(
                                          builder: (context, setState){
                                            return AlertDialog(
                                              title: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.only(right: 10),
                                                    child: Icon(
                                                      Icons.cancel,
                                                      color: Colors.redAccent,
                                                    ),
                                                  ),
                                                  Text("Cancellation Reason"),
                                                ],
                                              ),
                                              content: Form(
                                                key: _keyCancel,
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      TextFormField(
                                                        validator: (value){
                                                          cancellationMessage = value;
                                                          return value.isNotEmpty ? null : "Please provide a reason";
                                                        },
                                                        minLines: 3,
                                                        maxLines: null,
                                                        maxLength: 100,
                                                        keyboardType: TextInputType.multiline,
                                                        onChanged: (val) => setState(() => cancellationMessage = val),
                                                        decoration:  InputDecoration(
                                                          hintText: "Reason why",
                                                          hintStyle: TextStyle(
                                                              fontStyle: FontStyle.italic
                                                          ),
                                                          filled: true,
                                                          border: InputBorder.none,
                                                          fillColor: Colors.grey[300],
                                                          contentPadding: const EdgeInsets.all(30),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color: Colors.red,
                                                              width: 2,
                                                            ),
                                                            borderRadius: BorderRadius.circular(10.0),
                                                          ),
                                                          enabledBorder: UnderlineInputBorder(
                                                            borderSide: BorderSide(color: Colors.white),
                                                            borderRadius: BorderRadius.circular(10.0),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              actions: <Widget> [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    ElevatedButton(
                                                      child: Text("Discard"),
                                                      style: ButtonStyle(
                                                        backgroundColor: MaterialStateProperty.all(Colors.grey),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                    ElevatedButton(
                                                      child: Text("Send"),
                                                      onPressed: () async {
                                                        if(_keyCancel.currentState.validate()){
                                                          await DatabaseService(uid: delivery.uid).customerCancelRequest(cancellationMessage);
                                                          Navigator.of(context).pop();
                                                          showToast("Request cancelled");
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                )
                                              ],
                                            );
                                          },
                                        )
                                    );
                                  }
                              )
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              else return Container();
            }
          )
        ),
      );
    } else if (delivery.deliveryStatus == 'Cancelled') {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder<Courier>(
            stream: DatabaseService(uid: delivery.courierRef.id).courierData,
            builder: (context,snapshot){
              if(snapshot.hasData){
                Courier courierData = snapshot.data;

                String status = '';

                if (delivery.courierApproval.contains("Customer")) {
                  status = 'Cancelled by You';
                } else {
                  status = delivery.courierApproval;
                }

                return ExpansionTileCard(
                  title: Text("${courierData.fName} ${courierData.lName}",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  leading: Container(
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(courierData.avatarUrl),
                      backgroundColor: Colors.white,
                    ),
                  ),
                  subtitle: Container(
                    padding: EdgeInsets.only(top: 5),
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(text: "Status: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                        TextSpan(text: "$status \n", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold, color: color)),
                        TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                        TextSpan(text: courierData.contactNo, style: TextStyle(color: Colors.black)),
                      ],
                      ),
                    ),
                  ),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(Icons.cancel, color: Colors.red),
                                title: Text("Cancellation Message", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                subtitle: Container(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Text(delivery.cancellationMessage, style: TextStyle(color: Colors.black,),),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(Icons.payments_rounded, color: Colors.red),
                                title: Text("Payment Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                subtitle: Container(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Text.rich(
                                    TextSpan(children: [
                                      TextSpan(text: "Mode of Payment: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "${delivery.paymentOption}\n", style: Theme.of(context).textTheme.bodyText2),
                                      TextSpan(text: '\n'),
                                      TextSpan(text: "Who Will Pay: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "${delivery.whoWillPay}\n",style: Theme.of(context).textTheme.bodyText2),
                                      TextSpan(text: '\n'),
                                      TextSpan(text: "Delivery Fee: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
                                      TextSpan(text: "\₱${delivery.deliveryFee}\n",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
                                    ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(Icons.info_rounded, color: Colors.red),
                                title: Text("Additional Information", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                subtitle: Container(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Text.rich(
                                    TextSpan(children: [
                                      TextSpan(text: "Pick Up Address: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "${delivery.pickupAddress}\n", style: Theme.of(context).textTheme.bodyText2),
                                      TextSpan(text: '\n'),
                                      TextSpan(text: "Drop Off Address: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "${delivery.dropOffAddress}\n", style: Theme.of(context).textTheme.bodyText2),
                                      TextSpan(text: '\n'),
                                      TextSpan(text: "Item Description: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "${delivery.itemDescription}\n",style: Theme.of(context).textTheme.bodyText2),
                                      TextSpan(text: "Specific Instructions: \n", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "${delivery.specificInstructions}\n",style: Theme.of(context).textTheme.bodyText2),
                                    ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(Icons.phone_rounded, color: Colors.red),
                                title: Text("Contact Information", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                subtitle: Container(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Text.rich(
                                    TextSpan(children: [
                                      TextSpan(text: "Pickup Point Person: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "${delivery.pickupPointPerson}\n",style: Theme.of(context).textTheme.bodyText2),
                                      TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "${delivery.pickupContactNum}\n",style: Theme.of(context).textTheme.bodyText2),
                                      TextSpan(text: "\n"),
                                      TextSpan(text: "Drop Off Point Person: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "${delivery.dropoffPointPerson}\n",style: Theme.of(context).textTheme.bodyText2),
                                      TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "${delivery.dropoffContactNum}\n",style: Theme.of(context).textTheme.bodyText2),
                                    ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return Container();
              }
            }
          )
        ),
      );
    } else {
      return Container();
    }
  }

  double rating = 0.0;
  String feedback  = '';
  Map<String, DocumentReference> localMap = {};
  Map<String, DocumentReference> localAddMap;
  bool isFavorite = false;

  void showFeedback(Delivery delivery){
    showMaterialModalBottomSheet(
      context: context,
      builder: (context) => Container(
        child: Card(
          child: ListTile(
            title: Row(
              children: [
                Text('How\'s My Service?'),
                StreamBuilder<Customer>(
                    stream: DatabaseService(uid: delivery.customerRef.id).customerData,
                    builder: (context, snapshot) {
                      if(snapshot.hasData){
                        Customer customerData = snapshot.data;

                        if (customerData.courier_ref != {}) {
                          localMap = Map<String, DocumentReference>.from(customerData.courier_ref);
                        } else {
                          localAddMap = {};
                        }

                        localAddMap = {'Courier_Ref${localMap.length}' : delivery.courierRef};

                        localMap.forEach((key, value){
                          if (value == delivery.courierRef) {
                            isFavorite = true;
                          }
                        });

                        return Padding(
                          padding: const EdgeInsets.only(left: 170),
                          child: Container(
                            child:  FavoriteButton(
                              isFavorite: isFavorite,
                              iconSize: 30,
                              valueChanged: (_isFavorite) {
                                isFavorite = _isFavorite;

                                if (isFavorite) {
                                  localMap.addAll(localAddMap);
                                }
                              },
                            ),
                          ),
                        );
                      }else {
                        return Container();
                      }
                    }
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                RatingBar.builder(
                  minRating: 1,
                  itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
                  updateOnDrag: true,
                  onRatingUpdate: (rating) => setState((){
                    this.rating = rating;
                  }),
                ),
                Text('Rate Me',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: TextFormField(
                    maxLines: 2,
                    maxLength: 200,
                    decoration: InputDecoration(
                      hintText: 'Leave a Feedback',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.multiline,
                    onChanged: (val) => setState(() => feedback = val),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                      child: Text('OK'),
                      onPressed: () async{
                        await DatabaseService(uid: delivery.uid).updateRatingFeedback(rating.toInt(), feedback);
                        if (isFavorite) {
                          localMap.addAll(localAddMap);
                          DatabaseService(uid: delivery.customerRef.id).updateCustomerCourierRef(localMap);
                        }
                        Navigator.pop(context);
                        showToast('Feedback Sent');
                      }
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future showToast(String message) async {
    await Fluttertoast.cancel();
    Fluttertoast.showToast(msg: message, fontSize: 18, backgroundColor: Colors.green, textColor: Colors.white);
  }
}