import 'package:attendance/screens/manage_team.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamListScreen extends StatelessWidget {
  final String userId;
  final String user_role;
  const TeamListScreen({Key? key, required this.userId,required this.user_role}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: Column(
        children: [
          // Custom AppBar Decoration
          Container(
            width: double.infinity,
            height: 180,
            decoration: const BoxDecoration(
              color: Colors.deepPurpleAccent,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(80),
                bottomRight: Radius.circular(80),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Teams',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Teams List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Teams').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No Teams Found',
                      style: TextStyle(
                        color: Colors.deepPurpleAccent,
                        fontSize: 18,
                      ),
                    ),
                  );
                }

                final teams = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: teams.length,
                  itemBuilder: (context, index) {
                    final team = teams[index];
                    final teamName = team['Team_name'];
                    final documentId = team.id; // Get the document ID

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        title: Text(
                          teamName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.deepPurpleAccent,
                        ),
                        onTap: () {
                          // Navigate to ManageTeam screen with document ID as input
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ManageTeam(
                                documentid: documentId,
                                userId: userId,
                                user_role: user_role,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
