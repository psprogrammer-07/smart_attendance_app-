import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'team_chat_screen.dart';

class TeamListPage extends StatefulWidget {
  final String userId;
  final String username;

  const TeamListPage({super.key, required this.userId,required this.username});

  @override
  _TeamListPageState createState() => _TeamListPageState();
}

class _TeamListPageState extends State<TeamListPage> {
  late Future<List<Map<String, dynamic>>> _userTeamsFuture;

  @override
  void initState() {
    super.initState();
    _userTeamsFuture = _fetchUserTeams();
  }

  Future<List<Map<String, dynamic>>> _fetchUserTeams() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Teams').get();
    List<Map<String, dynamic>> userTeams = [];

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      Map<String, String> teamMembers = Map<String, String>.from(data['team_members']);

      if (teamMembers.containsKey(widget.userId)) {
        userTeams.add({
          'teamId': doc.id,
          'teamName': data['Team_name'],
        });
      }
    }
    return userTeams;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Teams'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _userTeamsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('You are not part of any teams.'));
          } else {
            List<Map<String, dynamic>> userTeams = snapshot.data!;
            return ListView.builder(
              itemCount: userTeams.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> team = userTeams[index];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    title: Text(
                      team['teamName'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Icon(Icons.chat_bubble_outline, color: Colors.deepPurpleAccent),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeamChatScreen(
                            username:widget.username ,
                            teamId: team['teamId'],
                            teamName: team['teamName'],
                            userId: widget.userId,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
