//import 'package:flutter/material.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';

//class RoleSelectionScreen extends StatelessWidget {
  //const RoleSelectionScreen({Key? key}) : super(key: key);

  //@override
  //Widget build(BuildContext context) {
    //return Scaffold(
      //appBar: AppBar(title: const Text("Select Your Role")),
      //body: Center(
        //child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          //children: [
            //ElevatedButton(
              //onPressed: () => _setRole(context, 'student'),
              ///child: const Text("I'm a Student"),
            //),
            //const SizedBox(height: 20),
            //ElevatedButton(
              //onPressed: () => _setRole(context, 'company'),
              //child: const Text("I'm a Company"),
            //),
          //],
        //),
      //),
    //);
  //}

  //void _setRole(BuildContext context, String role) async {
    //try {
      //final user = FirebaseAuth.instance.currentUser;

      //if (user != null) {
        // Save the selected role in Firestore
        //await FirebaseFirestore.instance
            //.collection('users')
            //.doc(user.uid)
            //.set({'role': role}, SetOptions(merge: true));

        // Navigate to the respective home screen
        //if (role == 'student') {
          //Navigator.pushReplacementNamed(context, '/studentHome');
        //} else if (role == 'company') {
          //Navigator.pushReplacementNamed(context, '/companyHome');
        //}
      //} else {
        //print("No user is logged in.");
        //ScaffoldMessenger.of(context).showSnackBar(
          //const SnackBar(content: Text("You need to be logged in first.")),
        //);
      //}
    //} catch (e) {
      //print("Error setting role: $e");
      //ScaffoldMessenger.of(context).showSnackBar(
        //SnackBar(content: Text("Failed to set role: $e")),
      //);
    //}
  //}
//}
