import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EmpWorkHistory extends StatelessWidget {
  final String userId;
  final String username;

  const EmpWorkHistory({
    Key? key,
    required this.userId,
    required this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$username\'s Work History'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('Employee Attendance').doc(userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return Center(child: Text('No work history available.'));
          }

          Map<String, dynamic> workHistory = snapshot.data!.data() as Map<String, dynamic>;
          List<MapEntry<String, dynamic>> entries = workHistory.entries.toList();

          // Skip the first entry
          //entries.removeAt(entries.length-1);

          // Filter out any non-map values
          //entries = entries.where((entry) => entry.value is Map<String, dynamic>).toList();
          entries = entries.where((entry) => entry.value is Map<String, dynamic> && entry.value['total_worktime'] != "-1000").toList();

          // Sort the entries by their inTime timestamp
          entries.sort((a, b) {
            Timestamp aTime = a.value['inTime'] ?? Timestamp.now();
            Timestamp bTime = b.value['inTime'] ?? Timestamp.now();
            return aTime.compareTo(bTime);
          });

          print("gggggggggggggggggggggggggggggggggggggggggggggg:  ${entries.length}         $entries    ${entries.length}");

          if (entries.isEmpty) {
            return Center(child: Text('No work history available.'));
          }

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              var entry = entries[index].value as Map<String, dynamic>;

              String employeeName = entry['employeeName'] ?? 'Unknown';
              String place = entry['place'] ?? 'Unknown';
              String workName = entry['work_name'] ?? 'Unknown';
              Timestamp? inTime = entry['inTime'];
              Timestamp? outTime = entry['outTime'];
              String totalWorkTime = entry['total_worktime'] ?? 'On going work';



              String inTimeFormatted = inTime != null
                  ? DateFormat('MMMM d, y h:mm a').format(inTime.toDate())
                  : 'Unknown';

              String outTimeFormatted = outTime != null
                  ? DateFormat('MMMM d, y h:mm a').format(outTime.toDate())
                  : 'On going work';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Work Name: $workName',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Employee Name: $employeeName',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Place: $place',
                          style: TextStyle(color: Colors.black87),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'In-Time: $inTimeFormatted',
                          style: TextStyle(color: Colors.black87),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Out-Time: $outTimeFormatted',
                          style: TextStyle(color: Colors.black87),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Total Work Time: $totalWorkTime',
                          style: TextStyle(color: Colors.black87),
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
      backgroundColor: Colors.deepPurple[50],
    );
  }
}
