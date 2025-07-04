import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<Map<String, dynamic>?> getSecondLastAttendance(String userId) async {
  try {
    // Reference to the Employee Attendance document for the user
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('Employee Attendance')
        .doc(userId);

    // Fetch the document
    DocumentSnapshot documentSnapshot = await documentReference.get();

    // Check if the document exists and contains data
    if (documentSnapshot.exists && documentSnapshot.data() != null) {
      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;

      // Extract the keys and sort them (assuming keys are timestamps or identifiers)
      List<String> keys = data.keys.toList();
      keys.sort();
     

     if(keys.length<=2){
       String secondLastKey = keys[keys.length -2];
       Map<String, dynamic> secondLastEntry = {secondLastKey: data[secondLastKey]};
       return secondLastEntry;
     }



      String secondLastKey = keys[keys.length - 2];
      Map<String, dynamic> secondLastEntry = {secondLastKey: data[secondLastKey]};

      return secondLastEntry;
    }
  } catch (e) {
    print('Error fetching second last attendance: $e');
    return null;
  }
  return null;
}



Future<void> updateEmpOutInPreviousField(String documentId,BuildContext? context) async {
  bool? are_emp_checkout=await getEmpAreOutValue(documentId);

  if(are_emp_checkout==true &&context!=null){
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Work already checked out"),
      ),
    );
   return;
  }

  DocumentReference documentRef = FirebaseFirestore.instance
      .collection('Employee Attendance')
      .doc(documentId);

  // Fetch the document to get the current fields
  DocumentSnapshot documentSnapshot = await documentRef.get();

  // Check if the document exists
  if (documentSnapshot.exists) {
    // Cast the document data to Map<String, dynamic>
    Map<String, dynamic> documentData = documentSnapshot.data() as Map<String, dynamic>;

    // Get the keys (field names) in the document
    List<String> fieldKeys = documentData.keys.toList();
    fieldKeys.sort();

    // If there are at least two fields, get the second-to-last field
    print("lennnnnnnnnnnnnnnnn:${fieldKeys.length}");
    print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk:${fieldKeys}");
    if (fieldKeys.length >= 1) {
      String secondToLastFieldKey = fieldKeys[fieldKeys.length-2];
      print("dddddddddddddddddddddfffffffffffff:${secondToLastFieldKey}");

      // Get the second-to-last field's value
      dynamic secondToLastFieldValue = documentData[secondToLastFieldKey];

      // Check if the field's value is a Map and contains 'emp_out'
      if (true) {

        secondToLastFieldValue['outTime'] = Timestamp.now();

        Map<String, dynamic>? last_checkin=await getSecondLastAttendance(documentId);

        Map<String, dynamic>? innerMap =last_checkin!.values.first as Map<String, dynamic>;
        Map<String, dynamic>? lastWorkDetails = innerMap;

        Timestamp checkin_time=lastWorkDetails["inTime"];
        Timestamp  checkout_time=Timestamp.now();

        String working_time=calculateTimeDifference(checkin_time,checkout_time);
        secondToLastFieldValue['total_worktime']=working_time;

        // Update the document with the modified second-to-last field
        await documentRef.update({secondToLastFieldKey: secondToLastFieldValue});
        updateEmpAreOut(documentId,true);
        if(context!=null)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Work checked out Successfully"),
            ),
          );
      } else {
        print('The second-to-last field is not a map or does not contain "emp_out".');
      }
    } else {
      print('Not enough fields to find the second-to-last one.');
    }
  } else {
    print('Document does not exist!');
  }
}

Future<void> updateEmpAreOut(String emp_id,bool status) async {
  // Reference to the specific document in the "Employee Attendance" collection
  print("heeeeeeeeeeeeeeeeeeeeeeee:${emp_id}");
  DocumentReference documentReference =
  FirebaseFirestore.instance.collection('Employee Attendance').doc(emp_id);

  try {
    // Update the 'emp_are_out' field to true
    await documentReference.update({'emp_are_out': status});
    print('emp_are_out field has been updated to true.');
  } catch (e) {
    print('Failed to update emp_are_out: $e');
  }
}



Future<bool?> getEmpAreOutValue(String documentId) async {
  // Reference to the Firestore document
  DocumentReference documentRef = FirebaseFirestore.instance
      .collection('Employee Attendance')
      .doc(documentId);

  try {
    // Fetch the document
    DocumentSnapshot documentSnapshot = await documentRef.get();

    // Check if the document exists
    if (documentSnapshot.exists) {
      // Cast the document data to Map<String, dynamic>
      Map<String, dynamic> documentData = documentSnapshot.data() as Map<String, dynamic>;

      // Check if 'emp_are_out' exists and return its value
      if (documentData.containsKey('emp_are_out')) {
        return documentData['emp_are_out'];
      } else {
        print('The document does not contain the "emp_are_out" field.');
        return null;
      }
    } else {
      print('Document does not exist!');
      return null;
    }
  } catch (e) {
    print('Error retrieving document: $e');
    return null;
  }
}



String formatTimestamp(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();

  // Format the date and time
  String formattedDate = DateFormat('MMMM d, y').format(dateTime); // e.g., August 25, 2024
  String formattedTime = DateFormat('h:mm a').format(dateTime);   // e.g., 7:08 PM

  return '$formattedDate, $formattedTime';
}

String calculateTimeDifference(Timestamp checkInTime, Timestamp checkOutTime) {
  DateTime checkInDateTime = checkInTime.toDate();
  DateTime checkOutDateTime = checkOutTime.toDate();

  Duration difference = checkOutDateTime.difference(checkInDateTime);
  int hours = difference.inHours;
  int minutes = difference.inMinutes.remainder(60);

  // Formatting the result to "HH:MM"
  String formattedTime = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  return formattedTime;
}