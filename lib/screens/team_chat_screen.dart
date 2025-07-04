import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/scheduler.dart';

class TeamChatScreen extends StatefulWidget {
  final String teamId;
  final String teamName;
  final String userId;
  final String username;

  const TeamChatScreen({
    super.key,
    required this.teamId,
    required this.teamName,
    required this.userId,
    required this.username,
  });

  @override
  _TeamChatScreenState createState() => _TeamChatScreenState();
}

class _TeamChatScreenState extends State<TeamChatScreen> {
  TextEditingController _messageController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  void _sendMessage(String message) async {
    if (message.isNotEmpty) {
      String timeNow = _formatTimestamp(Timestamp.now());

      Map<String, dynamic> newMessage = {
        'message': message,
        'userId': widget.userId,
        'username': widget.username,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('Employee_Team_Messages').doc(widget.teamId).set({
        timeNow: newMessage
      }, SetOptions(merge: true));

      _messageController.clear();

      // Scroll to the bottom after sending a message
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.teamName),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Employee_Team_Messages')
                  .doc(widget.teamId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.data() == null) {
                  return Center(child: Text('No messages yet.'));
                }

                Map<String, dynamic> messages = snapshot.data!.data() as Map<String, dynamic>;
                List<String> sortedKeys = messages.keys.toList()
                  ..sort((a, b) => DateFormat('MMMM d, y, h:mm:ss a').parse(a).compareTo(DateFormat('MMMM d, y, h:mm:ss a').parse(b)));

                SchedulerBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: sortedKeys.length,
                  itemBuilder: (context, index) {
                    String key = sortedKeys[index];
                    var message = messages[key] as Map<String, dynamic>;
                    bool isMe = message['userId'] == widget.userId;

                    return ListTile(
                      title: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.deepPurpleAccent : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['username'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isMe ? Colors.white : Colors.black,
                                ),
                              ),
                              Text(
                                message['message'],
                                style: TextStyle(color: isMe ? Colors.white : Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter message...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.deepPurpleAccent),
                  onPressed: () {
                    _sendMessage(_messageController.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat('MMMM d, y').format(dateTime);
    String formattedTime = DateFormat('h:mm:ss a').format(dateTime);
    return '$formattedDate, $formattedTime';
  }
}
