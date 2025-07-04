import 'package:attendance/screens/admin_screen.dart';
import 'package:attendance/screens/login_page.dart';
import 'package:attendance/screens/physical_checkin_page.dart';
import 'package:attendance/screens/physical_checkout_page.dart';
import 'package:attendance/screens/team_chat_list_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';

class MainScreen extends StatefulWidget {
  final DocumentSnapshot userDoc;
  const MainScreen({super.key, required this.userDoc});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 100,
            decoration: const BoxDecoration(
              color: Colors.deepPurpleAccent,

            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage(),));
                  },
                  child:const Icon(Icons.logout,color: Colors.white,),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 300, // Adjust height as needed
            decoration: const BoxDecoration(
              color: Colors.deepPurpleAccent,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(120),
                bottomRight: Radius.circular(120),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PhysicalCheckinPage(user_doc: widget.userDoc),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.only(top: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.all(Radius.circular(30)),
                            border: Border.all(color: Colors.grey),
                          ),
                          width: 170,
                          height: 200,
                          child: Column(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                child: Image.asset("local_items/check-in1.png"),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "Check In",
                                style: GoogleFonts.roboto(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                             Navigator.push(context, MaterialPageRoute(builder: (context) => PhysicalCheckoutPage(userDoc: widget.userDoc,),));
                              //_showNotification("hello world");
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.all(Radius.circular(30)),
                            border: Border.all(color: Colors.grey),
                          ),
                          width: 170,
                          height: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              Container(
                                width: 100,
                                height: 100,
                                child: Image.asset("local_items/check-out.png"),
                              ),
                              const SizedBox(height: 10,),
                              const Text('Check out',style: TextStyle(fontSize: 20,color: Colors.black),)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20,),
         // (widget.userDoc["Role"]!="Admin")?Container():
          Container(

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AdminScreen(user_id: widget.userDoc["user id"],username: widget.userDoc['username'],user_role: widget.userDoc['Role'],),));
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(30)),

                    ),
                    width: 170,
                    height: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Container(
                          width: 100,
                          height: 100,
                          child: Image.asset("local_items/manage_employee_icon.png"),
                        ),
                        const SizedBox(height: 10,),
                        const Text('Manage Team',style: TextStyle(fontSize: 20,color: Colors.black),)
                      ],
                    ),
                  ),
                ),

                TextButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TeamListPage(userId: widget.userDoc['user id'],username: widget.userDoc['username'],),));
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(30)),

                    ),
                    width: 170,
                    height: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Container(
                          width: 100,
                          height: 100,
                          child: Image.asset("local_items/chat_icon.png"),
                        ),
                        const SizedBox(height: 10,),
                        const Text('Chat with Teams',style: TextStyle(fontSize: 20,color: Colors.black),)
                      ],
                    ),
                  ),
                ),
              ],

            ),
          ),
          TextButton(onPressed: (){
              _showNotification("helo bro");
          }, child: Text("notify"))

        ],
      ),
    );
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
}
