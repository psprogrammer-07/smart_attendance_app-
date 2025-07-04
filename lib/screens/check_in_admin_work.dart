import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widgets and  functions/physical_checkin_functions.dart';
import '../widgets and  functions/physical_checkout_functions.dart';

class CheckInAdminWork extends StatefulWidget {
  final String user_id;
  final String user_name;
  const CheckInAdminWork({super.key,required this.user_id,required this.user_name});

  @override
  State<CheckInAdminWork> createState() => _CheckInAdminWorkState();
}

class _CheckInAdminWorkState extends State<CheckInAdminWork> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  LatLng? _customPosition; // To store the custom marker position
  String currentlocation_name = '';
  String customLocationName = ''; // To store the custom location name

  bool isMarking = false; // To toggle marking mode

  double? current_longitude=null;
  double? current_latitude=null;

  @override
  void initState() {
    super.initState();
    requestLocationPermission(context);
    create_empty_document(widget.user_id,widget.user_name);
    set_all_widgets(widget.user_id);

  }

  Future<void> _getCurrentLocation() async {
    PermissionStatus permission = await Permission.location.request();

    if (permission.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      _getAddressFromLatLng(position.latitude, position.longitude, isCustom: false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission denied.")),
      );
    }
  }

  Future<void> _getAddressFromLatLng(double latitude, double longitude, {required bool isCustom}) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];
      String detailedAddress = "${place.name ?? ''}, ${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.postalCode ?? ''}";

      setState(() {
        if (isCustom) {
          customLocationName = detailedAddress;

        }
        currentlocation_name = detailedAddress;
        current_latitude=latitude;
        current_longitude=longitude;
      });
    } catch (e) {
      print(e);
    }
  }

  void _startMarking() {
    setState(() {
      isMarking = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tap on the map to place a custom marker.")),
      );
    });
  }

  void _onMapTap(LatLng position) {
    if (isMarking) {
      setState(() {
        _customPosition = position;
        isMarking = false;
      });

      _getAddressFromLatLng(position.latitude, position.longitude, isCustom: true);
    }
  }

  TextEditingController job_dec_c=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: const BoxDecoration(
              color: Colors.deepPurpleAccent,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(80),
                bottomRight: Radius.circular(80),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 100,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 100,
                  height: 80,
                  child: Image.asset("local_items/check-in1.png"),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Text(
                    currentlocation_name,
                    style: TextStyle(fontSize: 16),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 20,),
              Container(
                width: 170,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(

                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      child: Image.asset("local_items/checked.png"),
                    ),
                    TextButton(
                      onPressed: () {
                        String job_dec=job_dec_c.text.trim();
                        if(job_dec.isEmpty||job_dec==null){
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please Enter job description '),
                            ),
                          );
                          return;
                        }
                        String userid=widget.user_id;
                        _updateEmpOutInPreviousField(userid,context,job_dec);


                      },
                      child: const Text(
                        "Check In",
                        style: TextStyle(color: Colors.deepPurpleAccent),
                      ),
                    ),


                  ],
                ),
              ),

            ],
          ),


          SizedBox(height: 10,),


          Container(
            margin: EdgeInsets.only(left: 10,right: 1+

                0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
            ),
            child: TextField(
              controller: job_dec_c,
              decoration: InputDecoration(
                  hintText: "    Enter Job description "
              ),
            ),
          ),

          SizedBox(height: 20,),

          _customPosition != null
              ? Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "Custom Location: $customLocationName",
              style: TextStyle(fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          )
              : SizedBox.shrink(),
          _currentPosition == null
              ? Center(child: CircularProgressIndicator())
              : Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 14,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              myLocationEnabled: true,
              markers: {
                Marker(
                  markerId: MarkerId('currentLocation'),
                  position: _currentPosition!,
                ),
                if (_customPosition != null)
                  Marker(
                    markerId: MarkerId('customLocation'),
                    position: _customPosition!,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen,
                    ),
                  ),
              },
              onTap: _onMapTap, // Allow users to tap the map to place a marker
            ),
          ),
        ],
      ),
    );
  }

  Future<void> set_all_widgets(String userid) async {

    Map<String, dynamic>? last_checkin=await getSecondLastAttendance(userid);

    Map<String, dynamic>? innerMap =last_checkin!.values.first as Map<String, dynamic>;


    setState(() {
      currentlocation_name=innerMap['place'];
      current_latitude=innerMap['latitude'];
      current_longitude=innerMap["longitude"];
      _currentPosition = LatLng(current_latitude!, current_longitude!);
    });
  }

  Future<void> _updateEmpOutInPreviousField(String documentId,BuildContext? context,String job_dec) async {
    bool? are_emp_checkout=await getEmpAreOutValue(documentId);

    if(are_emp_checkout==true &&context!=null){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Work already checked out"),
        ),
      );
      return;
    }

    DocumentReference documentRef = FirebaseFirestore.instance
        .collection('Employee Attendance')
        .doc(documentId);

    // Fetch the document to get the current fields
    DocumentSnapshot documentSnapshot = await documentRef.get();

    // Check if the document exists
    if (documentSnapshot.exists) {
      // Cast the document data to Map<String, dynamic>
      Map<String, dynamic> documentData = documentSnapshot.data() as Map<String, dynamic>;

      // Get the keys (field names) in the document
      List<String> fieldKeys = documentData.keys.toList();
      fieldKeys.sort();

      // If there are at least two fields, get the second-to-last field
      print("lennnnnnnnnnnnnnnnn:${fieldKeys.length}");
      print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk:${fieldKeys}");
      if (fieldKeys.length >= 1) {
        String secondToLastFieldKey = fieldKeys[fieldKeys.length-2];
        print("dddddddddddddddddddddfffffffffffff:${secondToLastFieldKey}");

        // Get the second-to-last field's value
        dynamic secondToLastFieldValue = documentData[secondToLastFieldKey];

        // Check if the field's value is a Map and contains 'emp_out'
        if (true) {

          secondToLastFieldValue['inTime'] = Timestamp.now();
          secondToLastFieldValue['assign_by_admin']=false;
          secondToLastFieldValue['work_name']=job_dec;

          Map<String, dynamic>? last_checkin=await getSecondLastAttendance(documentId);

          Map<String, dynamic>? innerMap =last_checkin!.values.first as Map<String, dynamic>;
          Map<String, dynamic>? lastWorkDetails = innerMap;


          // Update the document with the modified second-to-last field
          await documentRef.update({secondToLastFieldKey: secondToLastFieldValue});
          updateEmpAreOut(documentId,false);
          if(context!=null)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Work checked out Successfully"),
              ),
            );
        } else {
          print('The second-to-last field is not a map or does not contain "emp_out".');
        }
      } else {
        print('Not enough fields to find the second-to-last one.');
      }
    } else {
      print('Document does not exist!');
    }
  }

}
