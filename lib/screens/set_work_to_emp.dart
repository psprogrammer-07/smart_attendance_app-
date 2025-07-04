import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widgets and  functions/physical_checkin_functions.dart';
import '../widgets and  functions/physical_checkout_functions.dart';


class SetWorkToEmp extends StatefulWidget {
  final String user_id;
  final String user_name;
  const SetWorkToEmp({super.key,required this.user_id,required this.user_name});

  @override
  State<SetWorkToEmp> createState() => _SetWorkToEmpState();
}

class _SetWorkToEmpState extends State<SetWorkToEmp> {
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
    _getCurrentLocation();
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
            children: [
              SizedBox(width: 20,),
              Container(
                //width: 170,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                  children: [
                    Container(
                      height: 50,
                      
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
                        _set_emp_work(widget.user_name,userid, currentlocation_name, job_dec, current_latitude!, current_longitude!,context,);

                      },
                      child: const Text(
                        "Assign Work To Employee",
                        style: TextStyle(color: Colors.deepPurpleAccent,fontSize: 10),
                      ),
                      
                    ),

                    
                     
              
                  ],
                ),
              ),
              SizedBox(width: 10,),
              ElevatedButton(

                onPressed: _startMarking,
                child: Text("Mark Custom Location",style: TextStyle(fontSize: 10),),
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
  Future<void> _set_emp_work(String employeeName, String employeeId, String placeName, String work, double latitude, double longitude, BuildContext context) async {
    try {
      print("heloooooooooooooooooooo:${employeeId}");
      if(employeeId.isEmpty){
        print("enddddddddddddddddd");
        return;
      }
      final employeeRef = FirebaseFirestore.instance.collection('Employee Attendance').doc(employeeId);

      // **1. Check for document existence:**
      final employeeDoc = await employeeRef.get();
      if (!employeeDoc.exists) {
        final areOut = {
          "emp_are_out": true
        };

        await employeeRef.set(areOut, SetOptions(merge: true));
      }


      bool? isUserCheckedOut = employeeDoc.data()!['emp_are_out'];

      if (isUserCheckedOut == true) {
        // **4. Prepare attendance data and check-out flag:**
        final timeNow = _formatTimestamp(Timestamp.now()); // Use ISO-8601 format for consistency
        final attendanceData = {
          timeNow: {
            'employeeName': employeeName,
            'employeeId': employeeId,
            'work_name': work,
            'latitude': latitude,
            'longitude': longitude,
            'inTime':Timestamp.now(),
            'outTime': null,
            "place": placeName,
            'total_worktime':null,
            "assign_by_admin":true,
          }
        };
        updateEmpAreOut(employeeId,false);
        await employeeRef.set(attendanceData, SetOptions(merge: true));



        // Workmanager().initialize(loc.callbackDispatcher, isInDebugMode: true);
        //Workmanager().initialize(callbackDispatcher, isInDebugMode: true);



        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('successfully set work to the employee'),
          ),
        );
        print('successfully set the work');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please Check Out from your previous work of the employee'),
          ),
        );
      }
    } catch (e) {
      print('Error saving attendance data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again later.'),
        ),
      );
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();

    // Format the date and time
    String formattedDate = DateFormat('MMMM d, y').format(dateTime); // e.g., August 25, 2024
    String formattedTime = DateFormat('h:mm:ss a').format(dateTime);   // e.g., 7:08 PM

    return '$formattedDate, $formattedTime';
  }

}
