import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestLocationPermission(BuildContext context) async {
  PermissionStatus status = await Permission.location.request();

  if (status.isGranted) {
    // Permission is granted
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Location permission granted!")),
    );
  } else if (status.isDenied) {
    // Permission is denied
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Location permission denied.")),
    );
  } else if (status.isPermanentlyDenied) {
    // Permission is permanently denied, open app settings
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            "Location permission permanently denied. Please enable it in the settings."),
        action: SnackBarAction(
          label: 'Settings',
          onPressed: () {
            openAppSettings();
          },
        ),
      ),
    );
  }
}



Future<void> saveAttendanceData(String employeeName, String employeeId, String placeName, String work, double latitude, double longitude, BuildContext context) async {
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
          'assign_by_admin':false,
          'employeeName': employeeName,
          'employeeId': employeeId,
          'work_name': work,
          'latitude': latitude,
          'longitude': longitude,
          'inTime':Timestamp.now(),
          'outTime': null,
          "place": placeName,
          'total_worktime':null
        }
      };

      final areOut = {
        "emp_are_out": false
      };


      await employeeRef.set(attendanceData, SetOptions(merge: true));
        await employeeRef.set(areOut, SetOptions(merge: true));

    // Workmanager().initialize(loc.callbackDispatcher, isInDebugMode: true);
      //Workmanager().initialize(callbackDispatcher, isInDebugMode: true);



      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check-In details successfully uploaded!'),
        ),
      );
      print('Attendance data saved successfully.');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please Check Out from your previous attendance first!'),
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

void create_empty_document(String employeeId,String employeeName)async {

  final employeeRef = FirebaseFirestore.instance.collection('Employee Attendance').doc(employeeId);
  final employeeDoc = await employeeRef.get();
  if (!employeeDoc.exists) {
    final timeNow = _formatTimestamp(Timestamp.now()); // Use ISO-8601 format for consistency
    final attendanceData = {
      timeNow: {
        'assign_by_admin':false,
        'employeeName': employeeName,
        'employeeId': employeeId,
        'work_name': "trail",
        'latitude': 6789.0,
        'longitude': 34567.7,
        'inTime':Timestamp.now(),
        'outTime': Timestamp.now(),
        "place": "checking trail",
        'total_worktime':"-1000"
      }
    };

    final areOut = {
      "emp_are_out": true
    };
    await employeeRef.set(attendanceData, SetOptions(merge: true));
    await employeeRef.set(areOut, SetOptions(merge: true));
  }
}

String _formatTimestamp(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();

  // Format the date and time
  String formattedDate = DateFormat('MMMM d, y').format(dateTime); // e.g., August 25, 2024
  String formattedTime = DateFormat('h:mm:ss a').format(dateTime);   // e.g., 7:08 PM

  return '$formattedDate, $formattedTime';
}




