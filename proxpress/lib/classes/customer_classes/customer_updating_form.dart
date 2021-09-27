import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/services/auth.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/models/customers.dart';
import 'package:proxpress/UI/CustomerUI/notif_drawer_customer.dart';
import 'package:proxpress/services/upload_file.dart';
import 'package:path/path.dart' as Path;
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class CustomerUpdate extends StatefulWidget {

  @override
  _CustomerUpdateState createState() => _CustomerUpdateState();
}

class _CustomerUpdateState extends State<CustomerUpdate> {
  void _openEndDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _updateKey = GlobalKey<FormState>();

  String _currentFName;
  String _currentLName;
  String _currentAddress;
  String _currentEmail;
  String _currentContactNo;
  String _currentPassword;
  String _newPassword;
  String _confirmPassword;
  List bookmarks;
  bool checkCurrentPassword = true;
  final AuthService _auth = AuthService();

  File profilePicture;
  bool uploadedNewPic = false;
  String savedUrl = '';
  String saveDestination = '';

  String fetchedUrl;
  String defaultProfilePic = 'https://firebasestorage.googleapis.com/v0/b/proxpress-629e3.appspot.com/o/profile-user.png?alt=media&token=6727618b-4289-4438-8a93-a4f14753d92e';

  bool _isLoading = false;

  String dots(int Dotlength){
    String dot = "•";
    for(var i = 0; i<Dotlength; i++){
      dot += "•";
    }
    return dot;
  }
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);
    Stream<Customer> customerStream;

    if(user != null)
      customerStream = DatabaseService(uid: user.uid).customerData;

      return user == null ? LoginScreen() : WillPopScope(
        child: Scaffold(
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
                  // Navigator.pushNamed(context, '/customerProfile');
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

                      fetchedUrl = customerData.avatarUrl;

                      return Form(
                        key: _updateKey,
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              child: Text(
                                "Edit Profile",
                                style: TextStyle(
                                  fontSize: 25,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              child: Stack(
                                children: [
                                  Container(
                                    child: CircleAvatar(
                                      radius: 55,
                                      backgroundImage: uploadedNewPic
                                        ? FileImage(File(profilePicture.path))
                                        : NetworkImage(fetchedUrl),
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    //right : 10,
                                    left: 70,
                                    child: ClipOval(
                                      child: SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: Container(
                                          color: Color(0xfffb0d0d),
                                          child: IconButton(
                                            iconSize: 16,
                                            icon: Icon(Icons.edit_rounded,color: Colors.white,),
                                            onPressed: () async{

                                              String datetime = DateTime.now().toString();

                                              final result = await FilePicker.platform.pickFiles(allowMultiple: false);

                                              final pathProfiePicUploaded = result.files.single.path;
                                              setState(() {
                                                uploadedNewPic = true;
                                                profilePicture = File(pathProfiePicUploaded);
                                              });

                                              final profilePictureDestination = 'Customers/${user.uid}/profilepic_${user.uid}_$datetime';

                                              setState((){
                                                saveDestination = profilePictureDestination.toString();
                                                if (saveDestination != null && saveDestination.length > 0) {
                                                  saveDestination = saveDestination.substring(0, saveDestination.length - 1);
                                                }
                                              });
                                            }
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: TextFormField(
                                decoration: InputDecoration(labelText:
                                'First Name:',
                                  hintText: "${customerData.fName}",
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelStyle: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black
                                  ),
                                ),
                                onChanged: (val) => setState(() => _currentFName = val),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: TextFormField(
                                decoration: InputDecoration(labelText:
                                'Last Name:',
                                  hintText: "${customerData.lName}",
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelStyle: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black
                                  ),
                                ),
                                onChanged: (val) => setState(() => _currentLName = val),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: TextFormField(
                                decoration: InputDecoration(labelText:
                                'Address:',
                                  hintText: "${customerData.address}",
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelStyle: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black
                                  ),
                                ),
                                keyboardType: TextInputType.streetAddress,
                                onChanged: (val) => setState(() => _currentAddress = val),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: TextFormField(

                                decoration: InputDecoration(labelText:
                                'Email:',
                                  hintText: "${customerData.email}",
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelStyle: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black
                                  ),
                                ),
                                validator: (String val){
                                  if(val.isEmpty){
                                    return null;
                                  }
                                  else if (!RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?").hasMatch(val)){
                                    return 'Please Enter a Valid Email Address';
                                  }
                                  else
                                    return null;
                                },
                                onChanged: (val) => setState(() => _currentEmail = val),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: TextFormField(
                                decoration: InputDecoration(labelText:
                                'Contact No:',
                                  hintText: "${customerData.contactNo}",
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelStyle: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black
                                  ),
                                ),
                                maxLength: 11,
                                keyboardType: TextInputType.number,
                                validator: (String val){
                                  if(val.length < 11 && val.length > 0){
                                    return 'Your contact number should be 11 digits';
                                  }
                                  else
                                    return null;
                                },
                                onChanged: (val) => setState(() => _currentContactNo = val),
                              ),
                            ),
                            Container(
                              child: Center(
                                child: Text(
                                  "Manage Password",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: TextFormField(
                                obscureText: true,
                                decoration: InputDecoration(labelText:
                                'Password:',
                                  hintText: dots(customerData.password.length),
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  errorText: (checkCurrentPassword ?
                                  null :
                                  "Please double check your current password"
                                  ),
                                  labelStyle: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black
                                  ),
                                ),
                                validator: (String val){
                                  if(val.length < 8 && val.length > 0){
                                    return 'Password should be 8 characters long';
                                  }
                                  else
                                    return null;
                                },
                                //initialValue: "${customerData.password}",
                                onChanged: (val) => setState(() => _currentPassword = val),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: TextFormField(
                                obscureText: true,
                                decoration: InputDecoration(labelText:
                                'New Password:',
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelStyle: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.black,
                                  ),
                                ),
                                validator: (String val){
                                  if(val.length < 8 && val.length > 0){
                                    return 'Password should be 8 characters long';
                                  } else if(_currentPassword != null){
                                    if(val.isEmpty){
                                      return 'Kindly provide your new password';
                                    } else {
                                      return null;
                                    }
                                  }
                                  else
                                    return null;
                                },
                                onChanged: (val) => setState(() => _newPassword = val),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: TextFormField(
                                obscureText: true,
                                decoration: InputDecoration(labelText:
                                'Repeat Password:',
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelStyle: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black
                                  ),
                                ),
                                validator: (String val){
                                  if(_currentPassword != null){
                                    if(val.isEmpty){
                                      return "Kindly provide repeat password for verification";
                                    } else if(_newPassword != val){
                                      return "Password does not match";
                                    } else {
                                      return null;
                                    }
                                  }
                                  else
                                    return null;
                                },
                                onChanged: (val) => setState(() => _confirmPassword = val),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 20),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: ElevatedButton.icon(
                                  icon: _isLoading ? CircularProgressIndicator() : Icon(Icons.save),
                                  label: Text(
                                    _isLoading ? 'Loading...' : 'Save Changes',
                                    style: TextStyle(color: Colors.white, fontSize:15),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    primary: Color(0xfffb0d0d),
                                  ),
                                  onPressed: _isLoading ? null : () async {
                                    setState((){
                                      _isLoading = true;
                                    });
                                    final Customer validCustomer = Customer();

                                    if(_currentPassword != null)
                                      checkCurrentPassword = await validCustomer.validateCurrentPassword(_currentPassword);
                                    setState(() {

                                    });
                                    if (_updateKey.currentState.validate() && checkCurrentPassword) {
                                      if(_currentEmail != null)
                                        validCustomer.updateCurrentEmail(_currentEmail);
                                      if(_newPassword != null)
                                        validCustomer.updateCurrentPassword(_newPassword);

                                      await DatabaseService(uid: user.uid)
                                          .updateCustomerData(
                                        _currentFName ?? customerData.fName,
                                        _currentLName ?? customerData.lName,
                                        _currentEmail ?? customerData.email,
                                        _currentContactNo ?? customerData.contactNo,
                                        _confirmPassword ?? customerData.password,
                                        _currentAddress ?? customerData.address,
                                        customerData.avatarUrl,
                                        customerData.notifStatus,
                                        customerData.currentNotif,
                                        customerData.courier_ref[''],
                                      );

                                      if (profilePicture != null) {
                                        await UploadFile.uploadFile(saveDestination, profilePicture);

                                        savedUrl = await firebase_storage.FirebaseStorage.instance
                                            .ref(saveDestination)
                                            .getDownloadURL();

                                        if (savedUrl != null || savedUrl == 'null') {
                                          await DatabaseService(uid: user.uid).updateCustomerProfilePic(savedUrl);
                                        }

                                        setState(() {
                                          fetchedUrl = savedUrl;
                                        });
                                      }

                                      Navigator.pop(context, false);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
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