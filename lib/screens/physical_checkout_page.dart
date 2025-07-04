import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets and  functions/physical_checkout_functions.dart';

class PhysicalCheckoutPage extends StatefulWidget {
  final DocumentSnapshot userDoc;
  const PhysicalCheckoutPage({super.key, required this.userDoc});

  @override
  State<PhysicalCheckoutPage> createState() => _PhysicalCheckoutPageState();
}

class _PhysicalCheckoutPageState extends State<PhysicalCheckoutPage> {
  Map<String, dynamic>? lastWorkDetails;

  @override
  void initState() {
    super.initState();
    // Initiate the data fetch
    _fetchLastWorkDetails();
  }

  // Asynchronous method to fetch data
  Future<void> _fetchLastWorkDetails() async {
    try {
      // Fetch the last employee attendance details
      Map<String, dynamic>? details = await getSecondLastAttendance(widget.userDoc['user id']);

      // Update the state synchronously

      setState(() {
        Map<String, dynamic>? innerMap = details!.values.first as Map<String, dynamic>;
        lastWorkDetails = innerMap;
      });
    } catch (e) {
      // Handle any errors here, such as logging or showing a message to the user
      print('Error fetching last work details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // If data is still being fetched, show a loading indicator
    if (lastWorkDetails == null) {
      return Scaffold(
        backgroundColor: Colors.grey[300],
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Once data is fetched, build the main UI
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: const BoxDecoration(
              color: Colors.deepPurpleAccent,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(130),
                bottomRight: Radius.circular(130),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.all(40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text("On Going\n Work",style: TextStyle(color: Colors.white,fontSize: 30),)
                ],
              ),
            ),
          ),
          SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                child: Image.asset("local_items/user_profile.png"),
              ),
              SizedBox(width: 10),
              Text("${widget.userDoc['username']}"),
            ],
          ),
          SizedBox(height: 20,),
          Container(
            child: Text("Check in Time: ${formatTimestamp(lastWorkDetails!['inTime'])}"),
          ),
          Container(
            child:(lastWorkDetails!['outTime']==null)?Container(): Text("Check out Time: ${formatTimestamp(lastWorkDetails!['outTime'])}"),
          ),
          SizedBox(height: 20,),

          Container(
            child:(lastWorkDetails!['outTime']==null)?Container(): Text("Work Completed"),
          ),

          SizedBox(height: 30),

          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding:EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  width: 160,
                  height: 200,
                  child: Column(
                    children: [
                      Container(
                        height: 100, 
                        width: 100,
                        child: Image.asset("local_items/working.png"),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                          child: Text("${lastWorkDetails!['work_name']}")
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  width: 160,
                  height: 200,

                  child: Column(
                    children: [
                      Container(
                        height: 70,
                        width: 100,
                        child: Image.asset("local_items/building.png"),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                          child: Text("${lastWorkDetails!['place']}")
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20,),
          TextButton(
            onPressed: (){
           //   updateEmpAreOut(widget.userDoc['user id']);
              updateEmpOutInPreviousField(widget.userDoc['user id'],context);
            },
            child: Container(
              width: 200,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.deepPurpleAccent
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    child: Image.asset("local_items/check-out-2.png"),
                  ),
                  SizedBox(width: 25,),
                  Text("Check out?",style: TextStyle(color: Colors.white),)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
