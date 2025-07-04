import 'package:attendance/screens/add_members_screen.dart';
import 'package:attendance/screens/user_work_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets and  functions/manage_team_functions.dart';

class ManageTeam extends StatefulWidget {
  final String documentid;
  final String userId;
  final String user_role;

  const ManageTeam({super.key, required this.documentid, required this.userId,required this.user_role});

  @override
  State<ManageTeam> createState() => _ManageTeamState();
}

class _ManageTeamState extends State<ManageTeam> {
  Map<String, String> teamMembers = {};
  String teamName = '';

  @override
  void initState() {
    super.initState();
    print("docccccccccccccccccccccccccccccc:   ${widget.documentid}");
    _fetchTeamData(widget.documentid);
  }

  Future<void> _fetchTeamData(String docid) async {
    try {
      DocumentSnapshot document = await FirebaseFirestore.instance
          .collection('Teams')
          .doc(docid)
          .get();

      if (document.exists) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        Map<String, dynamic> teamMembersMap = data['team_members'];

        setState(() {
          teamName = data['Team_name'];
          teamMembers = teamMembersMap.map((key, value) =>
              MapEntry(key, value.toString()));
        });
      }
    } catch (e) {
      print('Error fetching team data: $e');
    }
  }

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildTeamNameWidget(teamName),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // List the team members
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: teamMembers.entries.map((entry) {
                    return TextButton(
                     
                      onPressed: (){
                         print("dddddddddddddddddddddddddd:${widget.user_role}");
                        if((widget.user_role=='Admin')){ 
                        Navigator.push(context, MaterialPageRoute(builder: (context) =>  UserWork(userId: entry.key,userName: entry.value,),));
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 16.0),
                            leading: CircleAvatar(
                              backgroundColor: Colors.deepPurpleAccent,
                              child: Text(
                                entry.value.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              entry.value,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            subtitle: Text(
                              'ID: ${entry.key}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14.0,
                              ),
                            ),
                            trailing: (widget.user_role!='Admin')?TextButton(onPressed: (){}, child:Text(""),): IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () {
                                confirmDelete(
                                  entry.key,
                                  context,
                                  widget.documentid,
                                      (String docid) {
                                    setState(() {
                                      teamMembers.remove(docid); // Remove from local state
                                    });
                                  },
                                );
                              },
                            ),
                          ),

                        ),

                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

           (widget.user_role=='Admin')?
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddMembers(
                        userId: widget.documentid,
                        teamName: teamName,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.only(bottom: 10, right: 10),
                  width: 80,
                  height: 80,
                  child: Image.asset("local_items/add_emp.png"),
                ),
              ),
            ):Container(),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamNameWidget(String teamName) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            teamName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
        ],
      ),
    );
  }
}
