import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inthub/features/user_auth/presentation/pages/company_home_page.dart';
import 'package:inthub/features/user_auth/presentation/pages/login_page.dart';
import 'package:inthub/features/user_auth/presentation/pages/student_home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      _navigateBasedOnRole();
    });
  }

  Future<void> _navigateBasedOnRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // No user logged in, navigate to login page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
        return;
      }

      // Fetch user's role from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final role = userDoc['role'];

        if (role == 'student') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
          );
        } else if (role == 'company') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const CompanyDashboard()),
            (route) => false,
          );
        } else {
          throw Exception("Invalid role");
        }
      } else {
        throw Exception("User data not found in Firestore");
      }
    } catch (e) {
      // Handle errors and navigate to login as a fallback
      print("Error determining role: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
Widget build(BuildContext context) {
  return const Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Welcome To InternHub",
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          CircularProgressIndicator(), // Loading indicator
        ],
      ),
    ),
  );
}
}
