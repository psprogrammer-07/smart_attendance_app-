import 'package:attendance/screens/create_new_team.dart';
import 'package:attendance/screens/manage_team.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:attendance/screens/team_list_screen.dart';

class AdminScreen extends StatefulWidget {
  final String user_id;
  final String username;
  final String user_role;
  const AdminScreen({super.key,required this.user_id,required this.username, required this.user_role});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

       body: Container(
         child: Column(
           children: [
             Container(
               width: double.infinity,
               height: 200,
               decoration: const BoxDecoration(
                 color: Colors.deepPurpleAccent,
                 borderRadius: BorderRadius.only(
                   bottomLeft: Radius.circular(120),
                   bottomRight: Radius.circular(120),
                 ),
               ),
             ),
             SizedBox(height: 25,),
             Container(
               padding: const EdgeInsets.only(left: 10,right: 10),
               child: Row(
                 children: [
                   TextButton(
                     onPressed: ()async{  //widget.user_id
                       if(await checkDocumentExists(widget.user_id)) {
                        /* Navigator.push(context, MaterialPageRoute(builder: (
                             context) => ManageTeam(userId: widget.user_id,),));
                         */
                         Navigator.push(context, MaterialPageRoute(builder: (
                             context) => TeamListScreen(userId: widget.user_id,user_role:widget.user_role),));
                       }
                       else{                                                                             //userId: widget.user_id,userName: widget.username
                         Navigator.push(context, MaterialPageRoute(builder: (context) => CreateNewTeam(userId: widget.user_id,userName: widget.username,),));
                       }


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
                             child: Image.asset("local_items/manage_emp.png"),
                           ),
                           const SizedBox(height: 10,),
                           const Text('Manage Team',style: TextStyle(fontSize: 20,color: Colors.black),)
                         ],
                       ),
                     ),
                   ),
                 ],
               ),
             ),
           ],
         ),
       ),
    );
  }
  Future<bool> checkDocumentExists(String documentId) async {
    try {
      // Reference to the "Teams" collection
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Teams')
          .doc(documentId)
          .get();

      // Check if the document exists
      return doc.exists;
    } catch (e) {
      print('Error checking document existence: $e');
      return false;
    }
  }
}
