import 'package:attendance/screens/main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/login_page.dart';

Future<void> loginUser(String email, String password, BuildContext context) async {
  try {
    // Attempt to sign in with email and password
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    DocumentSnapshot? userDoc =await getUserDetailsByEmail(email);


    Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen(userDoc: userDoc!,),));


  } on FirebaseAuthException catch (e) {
    String errorMessage;

    if (e.code == 'user-not-found') {
      errorMessage = 'No user found for that email.';
    } else if (e.code == 'wrong-password') {
      errorMessage = 'Wrong password provided for that user.';
    } else if (e.code == 'invalid-email') {
      errorMessage = 'The email address is not valid.';
    } else if (e.code == 'user-disabled') {
      errorMessage = 'This user has been disabled.';
    } else if (e.code == 'too-many-requests') {
      errorMessage = 'Too many login attempts. Please try again later.';
    } else if (e.code == 'operation-not-allowed') {
      errorMessage = 'Email/password sign-in is not enabled.';
    } else {
      errorMessage = 'An undefined error occurred.';
    }

    // Show the error message in a pop-up dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Login Error'),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  } catch (e) {
    // For any other errors not related to FirebaseAuthException
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text('An unexpected error occurred. Please try again later.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
//Map<String, String>?
Future< DocumentSnapshot?> getUserDetailsByEmail(String email) async {
  // Reference to the "User" collection
  CollectionReference users = FirebaseFirestore.instance.collection('Users');

  // Query the collection for the document where 'email' matches the input
  QuerySnapshot querySnapshot = await users.where('email', isEqualTo: email).get();

  // Check if the document exists
  if (querySnapshot.docs.isNotEmpty) {
    // Assuming the first match is the correct one (since emails should be unique)
    DocumentSnapshot userDoc = querySnapshot.docs.first;

    // Retrieve the username and user id from the document
   // String username = userDoc['username'];
   return userDoc;
   // return {'username': username, 'user id': userId};
  } else {
    // If no matching document is found, return null
    return null;
  }
}

Future<void> logout(BuildContext context) async {
  try {
    // Sign out the user from Firebase
    await FirebaseAuth.instance.signOut();

    // Navigate the user back to the LoginPage after logout
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
    );
  } catch (e) {
    // Handle errors if needed, such as showing a Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error logging out: ${e.toString()}')),
    );
  }
}