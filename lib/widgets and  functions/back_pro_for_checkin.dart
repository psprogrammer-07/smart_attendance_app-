import 'package:attendance/widgets%20and%20%20functions/physical_checkout_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:workmanager/workmanager.dart';
import '../main.dart';

// Workmanager().initialize(callbackDispatcher, isInDebugMode: true);


  void scheduleBackgroundTask() {
  
    Workmanager().registerPeriodicTask(
      "1",
      "locationCheckTask",
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
         requiresBatteryNotLow: false,
         requiresStorageNotLow: false,
         requiresDeviceIdle: false,
        requiresCharging: false,
      ),
    );

  }


  void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: process.env.FLUTTER_FIREBASE_APIKEY,
        appId: process.env.FLUTTER_FIREBASE_APPID,
        messagingSenderId: process.env.FLUTTER_FIREBASE_MESSAGEINGSENDERID,
        projectId:process.env.FLUTTER_FIREBASE_PROJECTID,
      ),
    );

      // Retrieve the latitude and longitude from inputData
      double latitude = 0.0;
      double longitude =  0.0;
      String regId ='';

     bool assign_by_admin=false;
     String? totalwork_timee='';


      Object? userDe= await getUserData();
      if (userDe != null && userDe is Map<String, dynamic>) {
        regId = userDe['user id'];
        print("User id: ${userDe['user id']}");
        bool? isEmpOut = await getEmpAreOutValue(regId);
        print("eeeeeeeeeeemmmmmmmmmmmmmmmmmmmm:${isEmpOut}");

        /*
        if (isEmpOut==true) {
          print("Employee is already marked as out. Skipping location check.");
          return Future.value(true); // Skip the rest of the task
        }

        */

        Map<String, dynamic>? last_checkin=await getSecondLastAttendance(regId);

        Map<String, dynamic>? innerMap =last_checkin!.values.first as Map<String, dynamic>;
        Map<String, dynamic>? lastWorkDetails = innerMap;

         latitude=lastWorkDetails['latitude'];
        longitude=lastWorkDetails['longitude'];

         assign_by_admin=lastWorkDetails["assign_by_admin"];
         totalwork_timee=lastWorkDetails['total_worktime'];
        

      } else {
        print("No user data found or data is not in expected format.");
      }



      // Call your location check function with the retrieved coordinates
      await _checkLocation(latitude, longitude,regId,assign_by_admin,totalwork_timee);

      return Future.value(true);
    });
  }

  Future<void> _checkLocation(double targetLatitude,
      double targetLongitude,String regId, bool checkin_or_not,String? totalwork_time) async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Prompt user to enable location services
        print('Location services are disabled. Please enable them.');
        await Geolocator.openLocationSettings();
        return;
      }

      // Check if permissions are granted
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied. Requesting permissions...');
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          print('Location permissions are still denied');
          return;
        }
      }

      // Get the current position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print('Current position: ${position.latitude}, ${position.longitude}');

      // Calculate the distance
      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        targetLatitude,
        targetLongitude,
      );
      print("real vlaueeeeeeeeeeeeeeeeeeee");
      print(position.latitude);
      print(position.longitude);
      print(targetLatitude);
      print(targetLongitude);

      print("dissssssssssssssssssssssssssssssssssssssss: $distance");
      print("totalllllllllllllllllllllllllrrrrrrrrrrrrrrr:$totalwork_time");
     // String notificationMessage = "Distance from target: ${distance.toStringAsFixed(2)} meters";
     await _showNotification("Service is working");
  
      // Check if user is within range
      if (distance >=200) {
        print('User is out of rangeeeeeeeeeeeeeeeeeeeeeeee:$checkin_or_not');

        if(!checkin_or_not && totalwork_time==null){
          print("totalllllllllllllllllllllllll:$totalwork_time");
          await updateEmpOutInPreviousField(regId, null);
          String update_str='Work Successfully Checkout and with the distance $distance';
            await _showNotification(update_str);
        }

      } else {
        print('User is inside to the rangeeeeeeeeeeeeeeeeeeeeeeee:$checkin_or_not');
        if(checkin_or_not) {

          print("workkkkkkkkkkkkkkkkkkkkkk");
          await  _updateEmpOutInPreviousField(regId,"my job");
          String update_str='Work Successfully Checkin and with the distance $distance';
          await _showNotification(update_str);
        }
        else{
        print("wtffffffffffffffffff");
        }
       // _showNotification(notificationMessage);
      }
    } catch (e) {
      print('Error in _checkLocation: $e');
    }
  }
Future<Object?> getUserData() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    CollectionReference users = FirebaseFirestore.instance.collection('Users');
    QuerySnapshot querySnapshot = await users.where('email', isEqualTo: user.email).get();

    if (querySnapshot.docs.isNotEmpty) {
      // Return the first document found
      return querySnapshot.docs.first.data();
    }
  }
  return null;
}


Future<void> _updateEmpOutInPreviousField(String documentId,String job_dec) async {
  bool? are_emp_checkout=await getEmpAreOutValue(documentId);
  print("isworkkkkkkkkkkkkkkkkkkkkkkkkkkkkk:$are_emp_checkout");

  if(are_emp_checkout==true){
     print("isnotworkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk");
    return;
  }
  print("isworkkkkkkkkkkkkkkkkkkkkkkkkkkkkk:$are_emp_checkout");

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



        // Update the document with the modified second-to-last field
        await documentRef.update({secondToLastFieldKey: secondToLastFieldValue});
       await  updateEmpAreOut(documentId,false);

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



Future<void> _showNotification(String message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails('high_importance_channel', 'High Importance Notifications',
      importance: Importance.max, priority: Priority.high, showWhen: false);

  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    'Location Update',
    message,
    platformChannelSpecifics,
    payload: 'Location Payload',
  );
}