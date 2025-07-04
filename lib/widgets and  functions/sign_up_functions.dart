import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Widget Text_fiels(String type, TextEditingController t_controller) {
  return Padding(
    padding: const EdgeInsets.only(left: 10,right: 10),
    child: Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey, width: 1), // Thicker border
            color: Colors.white, // Background color of the TextField

          ),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
          child: TextField(
            controller: t_controller,
            decoration: InputDecoration(
              hintText: type,
              border: InputBorder.none, // Removes the default underline border
              hintStyle: TextStyle(color: Colors.grey), // Hint text color
            ),
            style: TextStyle(color: Colors.black, fontSize: 16), // Text style
            cursorColor: Colors.blueAccent, // Cursor color
          ),
        ),
        SizedBox(height: 7),
      ],
    ),
  );
}



Future<void> registerUser({
  required String username,
  required String user_id,
  required String email,
  required String password1,
  required String password2,
  required BuildContext context,
  required String role,
}) async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if any field is empty
  if (username.isEmpty || email.isEmpty || password1.isEmpty || password2.isEmpty||role==""||role.isEmpty||user_id.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Some fields are empty")),
    );
    return;
  }

  // Check if passwords match
  if (password1 != password2) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please check the password")),
    );
    return;
  }
  if(!email.endsWith("@gmail.com")){
    SnackBar(content: Text("Use the @gmail.com domain"),);
  }

  try {
    // Check if email is already taken
    final list = await _auth.fetchSignInMethodsForEmail(email);
    print("listttttttttttttttttttttttt:$list");
    if (list.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("E-mail already taken")),
      );
      return;
    }
    print("listttttttttttttttttttttttt:$list");
    // Check if username already exists in Firestore


    // Create user in Firebase Authentication
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password1,
    );

    // Store additional details in Firestore
    await _firestore.collection('Users').doc(email).set({
      'username': username,
      'user id':user_id,
      'email': email,
      'password': password1,
      "Role":role,
      'created_at': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("User registered successfully")),
    );

  } on FirebaseAuthException catch (e) {
    String errorMessage;
    if (e.code == 'weak-password') {
      errorMessage = 'The password provided is too weak.';
    } else if (e.code == 'email-already-in-use') {
      errorMessage = 'The account already exists for that email.';
    } else {
      errorMessage = 'An unknown error occurred.';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  } catch (e) {
    print(e);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("An error occurred: $e")),
    );
  }
}