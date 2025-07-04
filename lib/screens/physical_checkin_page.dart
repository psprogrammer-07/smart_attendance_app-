import 'package:attendance/screens/check_in_admin_work.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widgets and  functions/physical_checkin_functions.dart';
import '../widgets and  functions/physical_checkout_functions.dart';

class PhysicalCheckinPage extends StatefulWidget {
  final DocumentSnapshot user_doc;
  const PhysicalCheckinPage({super.key,required this.user_doc});

  @override
  State<PhysicalCheckinPage> createState() => _PhysicalCheckinPageState();
}

class _PhysicalCheckinPageState extends State<PhysicalCheckinPage> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  LatLng? _customPosition; // To store the custom marker position
  String currentlocation_name = '';
  String customLocationName = ''; // To store the custom location name

  bool isMarking = false; // To toggle marking mode

  double? current_longitude=null;
  double? current_latitude=null;

  bool? assign_by_admin=null;

  @override
  void initState() {
    super.initState();
    requestLocationPermission(context);
    create_empty_document(widget.user_doc['user id'],widget.user_doc['username']);
    assign_by_admin_fun(widget.user_doc['user id']);


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
          (assign_by_admin==null)?
          CircularProgressIndicator():

          (assign_by_admin!=null && assign_by_admin==true)
              ? Column(
            children: [
              Text("Admin Assign work for you  \n Your want to check in it"),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckInAdminWork(
                        user_id: widget.user_doc['user id'],
                        user_name: widget.user_doc['username'],
                      ),
                    ),
                  );
                },
                child: Text("Check in?"),
              )
            ],
          )
              : Column(
            children: [
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
                  SizedBox(width: 20),
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
                            String job_dec = job_dec_c.text.trim();
                            if (job_dec.isEmpty || job_dec == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please Enter job description '),
                                ),
                              );
                              return;
                            }
                            String userid = widget.user_doc['user id'];
                            saveAttendanceData(
                              widget.user_doc['username'],
                              userid,
                              currentlocation_name,
                              job_dec,
                              current_latitude!,
                              current_longitude!,
                              context,
                            );
                          },
                          child: const Text(
                            "Check In",
                            style: TextStyle(color: Colors.deepPurpleAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _startMarking,
                    child: Text(
                      "Mark Custom Location",
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: TextField(
                  controller: job_dec_c,
                  decoration: InputDecoration(
                    hintText: "    Enter Job description ",
                  ),
                ),
              ),
              SizedBox(height: 20),
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
                  : SizedBox(
                height: 300, // Set a specific height for the GoogleMap
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
                  onTap: _onMapTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

 Future<void> assign_by_admin_fun(String regId) async {
  Map<String, dynamic>? last_checkin = await getSecondLastAttendance(regId);

  // Check if last_checkin is not null and contains valid data
  if (last_checkin != null && last_checkin.values.isNotEmpty) {
    Map<String, dynamic>? innerMap = last_checkin.values.first;

    if (innerMap != null && innerMap["assign_by_admin"] == true) {
      print("Assigned by admin");
      if (mounted) {
        setState(() {
          assign_by_admin = true;
        });
      }
    } else {
      print("No admin assignment");
      if (mounted) {
        setState(() {
          assign_by_admin = false;
        });
      }
      _getCurrentLocation();
    }
  }
}
}
