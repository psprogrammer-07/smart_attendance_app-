import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddMembers extends StatefulWidget {
  final String userId;
  final String teamName;


  const AddMembers({super.key, required this.userId, required this.teamName,});

  @override
  _AddMembersState createState() => _AddMembersState();
}

class _AddMembersState extends State<AddMembers> {
  Map<String, String> allUsers = {};
  Map<String, String> filteredUsers = {};
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAllUsers();
    searchController.addListener(_filterUsers);
  }

  Future<void> _fetchAllUsers() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Users').get();
      setState(() {
        allUsers = {
          for (var doc in snapshot.docs) doc['user id']: doc['username']
        };
        filteredUsers = Map.from(allUsers);
      });
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  void _filterUsers() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredUsers = {
        for (var entry in allUsers.entries)
          if (entry.key.contains(query) || entry.value.toLowerCase().contains(query))
            entry.key: entry.value
      };
    });
  }

  Future<void> _addUserToTeam(String userId) async {
    try {
      DocumentReference teamDoc = FirebaseFirestore.instance.collection('Teams').doc(widget.userId);
      DocumentSnapshot teamSnapshot = await teamDoc.get();

      if (teamSnapshot.exists) {
        Map<String, dynamic> teamData = teamSnapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> teamMembersMap = teamData['team_members'];

        if (teamMembersMap.containsKey(userId)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('The user is already added')),
          );
          return; // Exit the function since the user is already added
        }

        await teamDoc.update({
          'team_members.$userId': allUsers[userId],
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Member added successfully')),
        );
      }
    } catch (e) {
      print('Error adding member: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add member')),
      );
    }
  }

  Widget _highlightText(String text, String query) {
    if (query.isEmpty) {
      return Text(text);
    }

    final regex = RegExp('($query)', caseSensitive: false);
    final matches = regex.allMatches(text);

    if (matches.isEmpty) {
      return Text(text);
    }

    final textSpans = <TextSpan>[];
    int start = 0;

    for (final match in matches) {
      if (match.start > start) {
        textSpans.add(TextSpan(
          text: text.substring(start, match.start),
          style: const TextStyle(color: Colors.black),
        ));
      }
      textSpans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: const TextStyle(
          color: Colors.red, // Highlight color
          fontWeight: FontWeight.bold,
        ),
      ));
      start = match.end;
    }

    if (start < text.length) {
      textSpans.add(TextSpan(
        text: text.substring(start),
        style: const TextStyle(color: Colors.black),
      ));
    }

    return RichText(
      text: TextSpan(
        children: textSpans,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Members to ${widget.teamName}'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by User ID or Name',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  String userId = filteredUsers.keys.elementAt(index);
                  String username = filteredUsers.values.elementAt(index);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                            username.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: _highlightText(username, searchController.text),
                        subtitle: _highlightText('ID: $userId', searchController.text),
                        trailing: IconButton(
                          icon: const Icon(Icons.add, color: Colors.green),
                          onPressed: () => _addUserToTeam(userId),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
