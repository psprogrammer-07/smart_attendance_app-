import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<void> confirmDelete(String userId, BuildContext context, String teamId, Function onDeleteSuccess) async {
  bool? confirm = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Delete Confirmation"),
        content: const Text("Are you sure you want to delete this member?"),
        actions: [
          TextButton(
            child: const Text("No"),
            onPressed: () {
              Navigator.of(context).pop(false); // Return false
            },
          ),
          TextButton(
            child: const Text("Yes"),
            onPressed: () {
              Navigator.of(context).pop(true); // Return true
            },
          ),
        ],
      );
    },
  );

  if (confirm == true) {
    await deleteMember(userId, context, teamId, onDeleteSuccess);
  }
}

Future<void> deleteMember(String userId, BuildContext context, String teamId, Function onDeleteSuccess) async {
  try {
    // Deleting from the "team_members" map in the Firestore document
    DocumentReference teamDoc = FirebaseFirestore.instance
        .collection('Teams')
        .doc(teamId); // The document ID for the team

    await teamDoc.update({
      'team_members.$userId': FieldValue.delete(),
    });

    onDeleteSuccess(userId); // Call the callback function to update the UI

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Member deleted successfully')),
    );
  } catch (e) {
    print('Error deleting member: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to delete member')),
    );
  }
}
