import 'dart:async';
import 'package:attendance/screens/emp_work_history.dart';
import 'package:attendance/screens/set_work_to_emp.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../widgets and  functions/physical_checkout_functions.dart';

class UserWork extends StatefulWidget {
  final String userId;
  final String userName;

  const UserWork({super.key, required this.userId, required this.userName});

  @override
  _UserWorkState createState() => _UserWorkState();
}

class _UserWorkState extends State<UserWork> {
  LatLng? _userLocation;
  bool _isJobActive = false;
  final Completer<GoogleMapController> _mapController = Completer();

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
  }

  Future<void> _fetchUserLocation() async {
    try {

      Map<String, dynamic>? last_checkin=await getSecondLastAttendance(widget.userId);

      Map<String, dynamic>? innerMap =last_checkin!.values.first as Map<String, dynamic>;
      Map<String, dynamic>? lastWorkDetails = innerMap;

      if (lastWorkDetails.isNotEmpty) {

        if (lastWorkDetails.isNotEmpty) {
          if (lastWorkDetails['outTime'] != null) {
            setState(() {
              _isJobActive = false;
            });
          } else {
            double? latitude = lastWorkDetails['latitude'];
            double? longitude = lastWorkDetails['longitude'];
            if (latitude != null && longitude != null) {
              setState(() {
                _userLocation = LatLng(latitude, longitude);
                _isJobActive = true;
              });
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching user location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isJobActive
                ? GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _userLocation ?? LatLng(0, 0),
                zoom: 12,
              ),
              markers: _userLocation != null
                  ? {
                Marker(
                  markerId: MarkerId('userLocation'),
                  position: _userLocation!,
                ),
              }
                  : {},
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
              },
            )
                :  Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'The Employee Not In Any Active Jobs',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  const SizedBox(height: 20,),
                  TextButton(onPressed: (){
                    Navigator.push(context,MaterialPageRoute(builder: (context) => SetWorkToEmp(user_id: widget.userId,user_name: widget.userName,),));

                  }, child:const Text("Assign Work To Employee"))
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => EmpWorkHistory(userId: widget.userId , username:  widget.userName),));
              },
              child: Container(
                padding: EdgeInsets.only(bottom: 10,right: 10),
                height: 70,
                width: 70,
                child: Image.asset("local_items/work_history.png"),
              ),
            ),
          )
        ],
      ),
    );
  }
}
