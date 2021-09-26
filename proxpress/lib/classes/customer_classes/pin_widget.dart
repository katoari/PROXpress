import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/UI/CustomerUI/dashboard_customer.dart';
import 'package:proxpress/classes/directions_model.dart';
import 'package:proxpress/classes/directions_repository.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'courier_bookmarks_tile.dart';

class PinLocation extends StatefulWidget {
  final GlobalKey<FormState> locKey;
   TextEditingController textFieldPickup;
   TextEditingController textFieldDropOff;
  final bool isBookmarks;

  PinLocation({
    Key key,
    @required this.locKey,
    @required this.textFieldPickup,
    @required this.textFieldDropOff,
    @required this.isBookmarks,
  }) : super(key: key);

  // pickupAddress: pickupAddress,
  // pickupCoordinates: pickupCoordinates,
  // dropOffAddress: dropOffAddress,
  // dropOffCoordinates: dropOffCoordinates,
  // distance: isKM ? double.parse(distanceRemoveKM) : double.parse(distanceRemoveKM) / 1000,

  // String getPickupAddress() {
  //   return this.pickupAddress;
  // }
  // LatLng getPickupCoordinates() {
  //   return this.pickupCoordinates;
  // }
  //
  // String getDropOffAddress() {
  //   return this.dropOffAddress;
  // }
  // LatLng getDropOffCoordinates() {
  //   return this.dropOffCoordinates;
  // }
  //
  // int getDistance() {
  //   return this.distance;
  // }

  @override
  _PinLocationState createState() => _PinLocationState();
}

class _PinLocationState extends State<PinLocation> {
  String pickupAddress;
  LatLng pickupCoordinates;

  String dropOffAddress;
  LatLng dropOffCoordinates;

  double distance;

  dynamic pickupDetails;
  dynamic dropOffDetails;

  // Future<bool> checkIfHasPendingRequest(String uid) async {
  //   bool hasPendingRequest = false;
  //
  //   await FirebaseFirestore.instance
  //       .collection('Deliveries')
  //       .where('Courier Approval', isEqualTo: 'Pending')
  //       .where('Customer Reference', isEqualTo: FirebaseFirestore.instance.collection('Customers').doc(uid))
  //       .limit(1)
  //       .get()
  //       .then((event) {
  //     if (event.docs.isNotEmpty) {
  //       hasPendingRequest = true;
  //     } else {
  //       hasPendingRequest = false;
  //     }
  //   });
  //
  //   return hasPendingRequest;
  // }

  bool isKM = false;
  bool appear = false;

  @override
  Widget build(BuildContext context) {
    //final user = Provider.of<TheUser>(context);

    String distanceRemoveKM = '';

    return Column(
      children: [
        Container(
          margin: widget.isBookmarks ? EdgeInsets.only(
              right: 40, left: 40, bottom: 0, top: 0): EdgeInsets.only(
              right: 40, left: 40, bottom: 40, top: 100),
          child: Form(
            key: widget.locKey,
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Text(
                      "Pin a Location",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 35),
                    child: TextFormField(
                      controller: widget.textFieldPickup,
                      enableInteractiveSelection: false,
                      onTap: () async {
                        FocusScope.of(context).requestFocus(new FocusNode());

                        pickupDetails = await Navigator.pushNamed(context, '/pinLocationMap');

                        print("niceee ${pickupDetails.address}");
                        widget.textFieldPickup.text = pickupDetails.address;
                        widget.textFieldPickup.selection = TextSelection.fromPosition(TextPosition(offset: 0));

                        print("niceee2 ${pickupDetails.coordinates.toString()}");
                        pickupCoordinates = pickupDetails.coordinates;

                        setState(() => pickupAddress = widget.textFieldPickup.text);
                      },
                      decoration: InputDecoration(labelText: 'Pick up location', prefixIcon: Icon(Icons.place_rounded)),
                      keyboardType: TextInputType.streetAddress,
                      validator: (String value){
                        if(value.isEmpty){
                          return 'Pick up location is required';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (String value){
                        pickupAddress = value;
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 35, vertical: 23),
                    child: TextFormField(
                      controller: widget.textFieldDropOff,
                      enableInteractiveSelection: false,
                      onTap: () async {
                        FocusScope.of(context).requestFocus(new FocusNode());

                        dropOffDetails = await Navigator.pushNamed(context, '/pinLocationMap');

                        print("niceee ${dropOffDetails.address}");
                        widget.textFieldDropOff.text = dropOffDetails.address;
                        widget.textFieldDropOff.selection = TextSelection.fromPosition(TextPosition(offset: 0));

                        print("niceee2 ${dropOffDetails.coordinates.toString()}");
                        dropOffCoordinates = dropOffDetails.coordinates;

                        setState(() => dropOffAddress = widget.textFieldDropOff.text);
                      },
                      decoration: InputDecoration(labelText: 'Drop off location', prefixIcon: Icon(Icons.location_searching_rounded)),
                      keyboardType: TextInputType.streetAddress,
                      validator: (String value){
                        if(value.isEmpty){
                          return 'Drop off location is required';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (String value){
                        dropOffAddress = value;
                      },
                    ),
                  ),

                ],
              ),
              shadowColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.all(Radius.circular(10))),
            ),
          ),
        ),
        Visibility(
          visible: widget.isBookmarks,
          child: ElevatedButton(
            child: Text(
              'Pin Location',
              style:
              TextStyle(color: Colors.white, fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
                primary: Color(0xfffb0d0d)),
            onPressed: () async {
              if (widget.locKey.currentState.validate()) {
                Directions _infoFetch = await DirectionsRepository().getDirections(origin: pickupCoordinates, destination: dropOffCoordinates);

                if (_infoFetch.totalDistance.contains('km')) {
                  setState((){
                    isKM = true;
                    distanceRemoveKM = _infoFetch.totalDistance.substring(0, _infoFetch.totalDistance.length - 3);
                  });
                } else {
                  setState((){
                    distanceRemoveKM = _infoFetch.totalDistance.substring(0, _infoFetch.totalDistance.length - 2);
                  });
                }

                // bool hasPendingRequest = await checkIfHasPendingRequest(user.uid);

                setState((){
                  distance = isKM ? double.parse(
                      distanceRemoveKM) : double.parse(
                      distanceRemoveKM) / 1000;
                });

                if (!widget.isBookmarks) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DashboardCustomer(
                              pickupAddress: pickupAddress,
                              pickupCoordinates: pickupCoordinates,
                              dropOffAddress: dropOffAddress,
                              dropOffCoordinates: dropOffCoordinates,
                              distance: distance,
                            ),
                      )
                  );
                } else {
                  print(pickupAddress);
                  print(pickupCoordinates);
                  print(dropOffAddress);
                  print(dropOffCoordinates);
                  print(distance);
                  setState((){
                    print('nice');
                    appear = true;
                    widget.textFieldPickup.clear();
                    widget.textFieldDropOff.clear();
                  });

                  Navigator.pop(context, LocalDataBookmark(
                      appear: appear, distance: distance,
                      pickupAddress: pickupAddress, pickupCoordinates: pickupCoordinates,
                    dropOffAddress: dropOffAddress, dropOffCoordinates: dropOffCoordinates
                  ));
                  setState(() {

                  });
                }
              }
            },
          ),
        ),
        !widget.isBookmarks ? Visibility(
          visible: !widget.isBookmarks,
          child: ElevatedButton(
            child: Text(
              'Pin Location',
              style:
              TextStyle(color: Colors.white, fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
                primary: Color(0xfffb0d0d)),
            onPressed: () async {
              if (widget.locKey.currentState.validate()) {
                Directions _infoFetch = await DirectionsRepository().getDirections(origin: pickupCoordinates, destination: dropOffCoordinates);

                String distanceRemoveKM = '';
                bool isKM = false;

                if (_infoFetch.totalDistance.contains('km')) {
                  isKM = true;
                  distanceRemoveKM = _infoFetch.totalDistance.substring(0, _infoFetch.totalDistance.length - 3);
                } else {
                  distanceRemoveKM = _infoFetch.totalDistance.substring(0, _infoFetch.totalDistance.length - 2);
                }

                // bool hasPendingRequest = await checkIfHasPendingRequest(user.uid);

                if(!widget.isBookmarks){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DashboardCustomer(
                              pickupAddress: pickupAddress,
                              pickupCoordinates: pickupCoordinates,
                              dropOffAddress: dropOffAddress,
                              dropOffCoordinates: dropOffCoordinates,
                              distance: isKM ? double.parse(distanceRemoveKM) : double.parse(distanceRemoveKM) / 1000,
                            ),
                      )
                  );
                }

              }
            },
          ),
        ) : Container(),
      ],
    );
  }
}
class LocalDataBookmark{
  bool appear;
  double distance;
  String pickupAddress;
  LatLng pickupCoordinates;
  String dropOffAddress;
  LatLng dropOffCoordinates;


  LocalDataBookmark({this.appear, this.distance, this.pickupAddress, this.pickupCoordinates,
    this.dropOffAddress, this.dropOffCoordinates
  });
}