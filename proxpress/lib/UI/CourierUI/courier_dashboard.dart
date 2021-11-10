import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:proxpress/classes/courier_classes/delivery_list.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/classes/verify.dart';
import 'package:path/path.dart' as Path;
import 'package:file_picker/file_picker.dart';
import 'package:proxpress/services/upload_file.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class CourierDashboard extends StatefulWidget {
  @override
  State<CourierDashboard> createState() => _CourierDashboardState();
}

class _CourierDashboardState extends State<CourierDashboard> {
  File driversLicenseFront;
  File driversLicenseBack;
  File nbiClearancePhoto;
  File vehicleRegistrationOR;
  File vehicleRegistrationCR;
  File vehiclePhoto;

  String driversLicenseFront_ = '';
  String driversLicenseBack_ = '';
  String nbiClearancePhoto_ = '';
  String vehicleRegistrationOR_ = '';
  String vehicleRegistrationCR_ = '';
  String vehiclePhoto_ = '';
  bool vPhone = false;
  bool rButton = true;
  String contactNo;
  String _verificationCode = "";

  final BoxDecoration pinPutDecoration = BoxDecoration(
    border: Border.all(color: Colors.redAccent),
    borderRadius: BorderRadius.circular(15.0),
  );
  final _pinPutController = TextEditingController();
  final _pinPutFocusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);
    final auth = FirebaseAuth.instance;
    User user1 = auth.currentUser;
    final driversLicenseFrontFileName =  driversLicenseFront != null ? Path.basename(driversLicenseFront.path) : 'No File Selected';
    final driversLicenseBackFileName =  driversLicenseBack != null ? Path.basename(driversLicenseBack.path) : 'No File Selected';
    final nbiClearancePhotoFileName =  nbiClearancePhoto != null ? Path.basename(nbiClearancePhoto.path) : 'No File Selected';
    final vehicleRegistrationORFileName =  vehicleRegistrationOR != null ? Path.basename(vehicleRegistrationOR.path) : 'No File Selected';
    final vehicleRegistrationCRFileName =  vehicleRegistrationCR != null ? Path.basename(vehicleRegistrationCR.path) : 'No File Selected';
    final vehiclePhotoFileName =  vehiclePhoto != null ? Path.basename(vehiclePhoto.path) : 'No File Selected';

    bool approved = false;
    bool notifPopUpStatus = false;
    int notifCounter = 0;




    verifyPhone(String contact) async{
      contact = "+63" + contact.substring(1);
      print("sending ${contact}");
      try{
        await auth.verifyPhoneNumber
          (
            phoneNumber: contact,
            verificationCompleted: (PhoneAuthCredential credential) async{
              await FirebaseAuth.instance.signInWithCredential(credential).
              then((value) async {
                if(value.user != null){
                  print('verified naaaaa');
                }
              });
            },
            verificationFailed: (FirebaseAuthException e){
              print(e.message);
            },
            codeSent: (String verificationID, int resendToken){
              setState(() {
                _verificationCode = verificationID;
              });
            },
            codeAutoRetrievalTimeout: (String verificationID){
              setState(() {
                _verificationCode = verificationID;
              });
            },
            timeout: Duration(seconds: 120)
        );
      } catch (e){
        print(e);
      }
    }

    return StreamBuilder<Courier>(
      stream: DatabaseService(uid: user.uid).courierData,
      builder: (context,snapshot){
        if(snapshot.hasData){
          Courier courierData = snapshot.data;
          approved = courierData.approved;
          notifPopUpStatus = courierData.NotifPopStatus;
          notifCounter = courierData.NotifPopCounter;
          Stream<List<Delivery>> deliveryList = FirebaseFirestore.instance
              .collection('Deliveries')
              .where('Courier Approval', isEqualTo: 'Pending')
              .where('Courier Reference', isEqualTo: FirebaseFirestore.instance.collection('Couriers').doc(user.uid))
              .snapshots()
              .map(DatabaseService().deliveryDataListFromSnapshot);

          bool allCredentialsValid = courierData.adminCredentialsResponse[0]  == false &&
              courierData.adminCredentialsResponse[1] == false &&
              courierData.adminCredentialsResponse[2] == false &&
              courierData.adminCredentialsResponse[3] == false &&
              courierData.adminCredentialsResponse[4] == false &&
              courierData.adminCredentialsResponse[5] == false ? true : false;


          Widget _welcomeMessage(){
            String welcomeMessage = courierData.adminMessage;
            print(welcomeMessage);
            return Container(
              margin: EdgeInsets.fromLTRB(20, 40, 20, 0),
              child: Align(
                child: Text(welcomeMessage,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            );
          }

          Widget _updateCredential1(){
            return Container(
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text('Driver\'s License Front',
                      style: TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.upload_rounded, color: Color(0xfffb0d0d)),
                            label: Text(
                              'Add File',
                              style: TextStyle(color: Color(0xfffb0d0d)),
                            ),
                            onPressed: () async {
                              final result = await FilePicker.platform.pickFiles(allowMultiple: false);

                              final path = result.files.single.path;
                              setState(() {
                                driversLicenseFront = File(path);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(driversLicenseFrontFileName),
                        ),
                        SizedBox(height: 20,),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          Widget _updateCredential2(){
            return Column(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text('Driver\'s License Back',
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.upload_rounded, color: Color(0xfffb0d0d)),
                          label: Text(
                            'Add File',
                            style: TextStyle(color: Color(0xfffb0d0d)),
                          ),
                          onPressed: () async {
                            final result = await FilePicker.platform.pickFiles(allowMultiple: false);

                            final path = result.files.single.path;
                            setState(() {
                              driversLicenseBack = File(path);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(driversLicenseBackFileName),
                      ),
                      SizedBox(height: 20,),
                    ],
                  ),
                ),
              ],
            );
          }
          Widget _updateCredential3(){
            return Column(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text('NBI Clearance',
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.upload_rounded, color: Color(0xfffb0d0d)),
                          label: Text(
                            'Add File',
                            style: TextStyle(color: Color(0xfffb0d0d)),
                          ),
                          onPressed: () async {
                            final result = await FilePicker.platform.pickFiles(allowMultiple: false);

                            final path = result.files.single.path;
                            setState(() {
                              nbiClearancePhoto = File(path);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(nbiClearancePhotoFileName),
                      ),
                      SizedBox(height: 20,),
                    ],
                  ),
                ),
              ],
            );
          }

          Widget _updateCredential4(){
            return Column(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text('Vehicle Official Receipt (OR)',
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.upload_rounded, color: Color(0xfffb0d0d)),
                          label: Text(
                            'Add File',
                            style: TextStyle(color: Color(0xfffb0d0d)),
                          ),
                          onPressed: () async {
                            final result = await FilePicker.platform.pickFiles(allowMultiple: false);

                            final path = result.files.single.path;
                            setState(() {
                              vehicleRegistrationOR = File(path);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(vehicleRegistrationORFileName),
                      ),
                      SizedBox(height: 20,),
                    ],
                  ),
                ),
              ],
            );
          }

          Widget _updateCredential5(){
            return Column(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text('Vehicle Certificate of Registration (CR)',
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.upload_rounded, color: Color(0xfffb0d0d)),
                          label: Text(
                            'Add File',
                            style: TextStyle(color: Color(0xfffb0d0d)),
                          ),
                          onPressed: () async {
                            final result = await FilePicker.platform.pickFiles(allowMultiple: false);

                            final path = result.files.single.path;
                            setState(() {
                              vehicleRegistrationCR = File(path);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(vehicleRegistrationCRFileName),
                      ),
                      SizedBox(height: 20,),
                    ],
                  ),
                ),
              ],
            );
          }

          Widget _updateCredential6(){
            return Column(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text('Vehicle Photo',
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.upload_rounded, color: Color(0xfffb0d0d)),
                          label: Text(
                            'Add File',
                            style: TextStyle(color: Color(0xfffb0d0d)),
                          ),
                          onPressed: () async {
                            final result = await FilePicker.platform.pickFiles(allowMultiple: false);

                            final path = result.files.single.path;
                            setState(() {
                              vehiclePhoto = File(path);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(vehiclePhotoFileName),
                      ),
                      SizedBox(height: 20,),
                    ],
                  ),
                ),
              ],
            );
          }

          Widget _updateCredentialButton(){
            return ElevatedButton(
                child: Text(
                  'Update Credentials', style: TextStyle(color: Colors.white, fontSize:18),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xfffb0d0d),
                ),
                onPressed: () async {

                  bool picsLoaded(){
                    if(courierData.adminCredentialsResponse[0] && driversLicenseFront != null){
                      return true;
                    }else if(courierData.adminCredentialsResponse[1] && driversLicenseBack != null){
                      return true;
                    }else if(courierData.adminCredentialsResponse[2] && nbiClearancePhoto != null){
                      return true;
                    }else if(courierData.adminCredentialsResponse[3] && vehicleRegistrationOR != null){
                      return true;
                    }else if(courierData.adminCredentialsResponse[4] && vehicleRegistrationCR != null){
                      return true;
                    }else if(courierData.adminCredentialsResponse[5] && vehiclePhoto != null){
                      return true;
                    }else return false;
                  }
                  if (picsLoaded()){
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      final User user = auth.currentUser;

                      if (user != null) {
                        final driversLicenseFrontDestination = 'Couriers/${user.uid}/$driversLicenseFrontFileName';
                        final driversLicenseBackDestination = 'Couriers/${user.uid}/$driversLicenseBackFileName';
                        final nbiClearancePhotoDestination = 'Couriers/${user.uid}/$nbiClearancePhotoFileName';
                        final vehicleRegistrationORDestination = 'Couriers/${user.uid}/$vehicleRegistrationORFileName';
                        final vehicleRegistrationCRDestination = 'Couriers/${user.uid}/$vehicleRegistrationCRFileName';
                        final vehiclePhotoDestination = 'Couriers/${user.uid}/$vehiclePhotoFileName';

                        try {
                          if(courierData.adminCredentialsResponse[0]){
                            print('1');
                            await UploadFile.uploadFile(driversLicenseFrontDestination, driversLicenseFront);
                            driversLicenseFront_ = await firebase_storage.FirebaseStorage.instance
                                .ref(driversLicenseFrontDestination)
                                .getDownloadURL();
                          }
                          if(courierData.adminCredentialsResponse[1]){
                            print('2');
                            await UploadFile.uploadFile(driversLicenseBackDestination, driversLicenseBack);
                            driversLicenseBack_ = await firebase_storage.FirebaseStorage.instance
                                .ref(driversLicenseBackDestination)
                                .getDownloadURL();
                          }
                          if(courierData.adminCredentialsResponse[2]){
                            print('3');
                            await UploadFile.uploadFile(nbiClearancePhotoDestination, nbiClearancePhoto);
                            nbiClearancePhoto_ = await firebase_storage.FirebaseStorage.instance
                                .ref(nbiClearancePhotoDestination)
                                .getDownloadURL();
                          }
                          if(courierData.adminCredentialsResponse[3]){
                            print('4');
                            await UploadFile.uploadFile(vehicleRegistrationORDestination, vehicleRegistrationOR);
                            vehicleRegistrationOR_ = await firebase_storage.FirebaseStorage.instance
                                .ref(vehicleRegistrationORDestination)
                                .getDownloadURL();
                          }
                          if(courierData.adminCredentialsResponse[4]){
                            print('5');
                            await UploadFile.uploadFile(vehicleRegistrationCRDestination, vehicleRegistrationCR);
                            vehicleRegistrationCR_ = await firebase_storage.FirebaseStorage.instance
                                .ref(vehicleRegistrationCRDestination)
                                .getDownloadURL();
                          }
                          if(courierData.adminCredentialsResponse[5]){
                            print('6');
                            await UploadFile.uploadFile(vehiclePhotoDestination, vehiclePhoto);
                            vehiclePhoto_ = await firebase_storage.FirebaseStorage.instance
                                .ref(vehiclePhotoDestination)
                                .getDownloadURL();
                          }
                          if(driversLicenseFront_ == null || driversLicenseFront_ == ''){
                            driversLicenseFront_ = courierData.driversLicenseFront_;
                          }
                          if(driversLicenseBack_ == null || driversLicenseBack_ == ''){
                            driversLicenseBack_ = courierData.driversLicenseBack_;
                          }
                          if(nbiClearancePhoto_ == null || nbiClearancePhoto_ == ''){
                            nbiClearancePhoto_ = courierData.nbiClearancePhoto_;
                          }
                          if(vehicleRegistrationOR_ == null || vehicleRegistrationOR_ == ''){
                            vehicleRegistrationOR_ = courierData.vehicleRegistrationOR_;
                          }
                          if(vehicleRegistrationCR_ == null || vehicleRegistrationCR_ == ''){
                            vehicleRegistrationCR_ = courierData.vehicleRegistrationCR_;
                          }
                          if(vehiclePhoto_ == null || vehiclePhoto_ == ''){
                            vehiclePhoto_ = courierData.vehiclePhoto_;
                          }

                          await DatabaseService(uid: user.uid).updateCourierCredentials(driversLicenseFront_, driversLicenseBack_, nbiClearancePhoto_, vehicleRegistrationOR_, vehicleRegistrationCR_, vehiclePhoto_);
                          await DatabaseService(uid: user.uid).updateAdminMessage("Your credentials have been updated, please wait for the confirmation.");
                          await DatabaseService(uid: user.uid).updateCredentialsResponse([false,false,false,false,false,false]);

                        } catch(e) {
                          print(e.toString());
                        }
                      }
                  } else {
                    print('Photos not yet uploaded');
                  }
                  await showToast('Please wait for the confirmation.');
                }
            );
          }

          // bool allCredentialsValid = courierData.adminCredentialsResponse[0]  == false &&
          //     courierData.adminCredentialsResponse[1] == false &&
          //     courierData.adminCredentialsResponse[2] == false &&
          //     courierData.adminCredentialsResponse[3] == false &&
          //     courierData.adminCredentialsResponse[4] == false &&
          //     courierData.adminCredentialsResponse[5] == false ? true : false;
          contactNo = courierData.contactNo;
          return StreamProvider<List<Delivery>>.value(
            initialData: [],
            value: deliveryList,
            child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Text("Welcome, ${courierData.fName}!",
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                    ),
                    !approved || !user1.emailVerified && user1.phoneNumber == null ? Container(
                      child: Column(
                        children: [
                          !approved ? Column(
                            children: [
                              _welcomeMessage(),
                              Column(
                                children: [
                                  courierData.adminCredentialsResponse[0] ? _updateCredential1() : Container(),
                                  courierData.adminCredentialsResponse[1] ? _updateCredential2() : Container(),
                                  courierData.adminCredentialsResponse[2] ? _updateCredential3() : Container(),
                                  courierData.adminCredentialsResponse[3] ? _updateCredential4() : Container(),
                                  courierData.adminCredentialsResponse[4] ? _updateCredential5() : Container(),
                                  courierData.adminCredentialsResponse[5] ? _updateCredential6() : Container(),
                                  !allCredentialsValid ? _updateCredentialButton(): Container(),
                                ],
                              ),
                            ],
                          ) : Visibility(
                            visible: false,
                            child: Container(),
                          ),
                          !user1.emailVerified || user1.phoneNumber == null ? Container(
                            margin: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.info,
                                      color: Colors.red,
                                    ),
                                    title: Text(
                                      "Kindly verify your email ${user1.email} to use the app.",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),

                                  ),
                                ),
                                Visibility(
                                  visible: rButton,
                                  child: ElevatedButton(
                                    onPressed: (){
                                      setState(() {
                                        vPhone = true;
                                        rButton = false;
                                      });
                                      showToast1("OTP has been sent");
                                      verifyPhone(contactNo);
                                    },
                                    child: Text('Verify your contact number'),
                                  ),
                                ),
                                Visibility(
                                  visible: vPhone,
                                  child: Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    borderOnForeground: true,
                                    child: Container(
                                        child: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Column(
                                            children: [
                                              Text(
                                                "Enter Verification code",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold
                                                ),
                                              ),
                                              SizedBox(height: 20,),
                                              Text(
                                                "Please check your mobile number for a "
                                                    "message with your code.",
                                                style: TextStyle(
                                                  fontSize: 15,

                                                ),
                                              ),
                                              SizedBox(height: 15,),
                                              PinPut(
                                                fieldsCount: 6,
                                                eachFieldHeight: 40.0,
                                                withCursor: true,
                                                onSubmit: (pin) async{
                                                  print("pin ${pin}");
                                                  try{
                                                    await user1.linkWithCredential(
                                                        PhoneAuthProvider.credential(verificationId: _verificationCode, smsCode: pin)
                                                    ).then((value) async {
                                                      if(value.user != null){
                                                        print("works?");
                                                        setState(() {
                                                          vPhone = false;
                                                        });
                                                        showToast1("Your phone number is now verified");
                                                        Future.delayed(const Duration(seconds: 3), () {
                                                          setState(() {
                                                            Navigator.pushNamed(context, '/template1');
                                                          });
                                                        });

                                                      }
                                                    });
                                                  } catch (e){
                                                    FocusScope.of(context).unfocus();
                                                    print("invalid otp");

                                                  }

                                                },
                                                focusNode: _pinPutFocusNode,
                                                controller: _pinPutController,
                                                submittedFieldDecoration: pinPutDecoration.copyWith(
                                                  borderRadius: BorderRadius.circular(20.0),
                                                ),
                                                selectedFieldDecoration: pinPutDecoration,
                                                followingFieldDecoration: pinPutDecoration.copyWith(
                                                  borderRadius: BorderRadius.circular(5.0),
                                                  border: Border.all(
                                                    color: Colors.redAccent.withOpacity(.5),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 10,),
                                              Text(
                                                "We have sent the code to ${courierData.contactNo}.",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontStyle: FontStyle.italic,
                                                    fontWeight: FontWeight.bold

                                                ),
                                              ),
                                              SizedBox(height: 20,),
                                              Text(
                                                "Didn't received any code?",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                ),
                                              ),
                                              SizedBox(height: 10,),
                                              InkWell(
                                                child: new Text(
                                                  "RESEND NEW CODE",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.redAccent
                                                  ),
                                                ),
                                                onTap: (){
                                                  showToast1("We have sent a new OTP");
                                                  verifyPhone(contactNo);
                                                  print("resending");
                                                },
                                              ),
                                            ],
                                          ),
                                        )
                                    ),
                                  ),
                                ),
                                //verifyCond(),
                                //VerifyEmail()
                              ],
                            ),
                          ) : Visibility(
                            visible: false,
                            child: Container(),
                          ),
                        ],
                      ),
                    ) : Container(
                      child: DeliveryList(notifPopUpStatus: notifPopUpStatus, notifPopUpCounter: notifCounter,),
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
  Future showToast(String message) async {
    await Fluttertoast.cancel();
    Fluttertoast.showToast(msg: message, fontSize: 18, backgroundColor: Colors.red, textColor: Colors.white);
  }
  Future showToast1(String message) async {
    await Fluttertoast.cancel();
    Fluttertoast.showToast(msg: message, fontSize: 18, backgroundColor: Colors.green, textColor: Colors.white);
  }
}