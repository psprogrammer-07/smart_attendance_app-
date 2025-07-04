import 'dart:io';
import 'package:attendance/screens/login_page.dart';
import 'package:attendance/screens/main_screen.dart';
import 'package:attendance/widgets%20and%20%20functions/back_pro_for_checkin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize WorkManager
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

  // Request notification permissions and initialize notifications
  await requestNotificationPermission();
  await initializeNotifications();

  // Schedule background tasks
  scheduleBackgroundTask();

  // Check if Firebase has already been initialized
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: process.env.FLUTTER_FIREBASE_APIKEY,
        appId: process.env.FLUTTER_FIREBASE_APPID,
        messagingSenderId: process.env.FLUTTER_FIREBASE_MESSAGEINGSENDERID,
        projectId:process.env.FLUTTER_FIREBASE_PROJECTID,
      ),
    );
  }

  // Run the app
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: AuthCheck(), // Start with the AuthCheck widget
    );
  }
}

class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseAuth.instance.currentUser != null ? _getUserData() : Future.value(null),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while checking the auth status
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          if (snapshot.data != null) {

            return MainScreen(userDoc: snapshot.data!);
          } else {
            // If no user is logged in, navigate to LoginPage
            return LoginPage();
          }
        }
      },
    );
  }

  // Function to get user data from Firestore
  Future<DocumentSnapshot> _getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      CollectionReference users = FirebaseFirestore.instance.collection('Users');
      QuerySnapshot querySnapshot = await users.where('email', isEqualTo: user.email).get();

      if (querySnapshot.docs.isNotEmpty) {
        // Return the first document found
        return querySnapshot.docs.first;
      }
    }
    return Future.value(null);
  }

}

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> requestNotificationPermission() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}
