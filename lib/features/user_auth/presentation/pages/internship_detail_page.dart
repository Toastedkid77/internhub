import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inthub/models/internship_model.dart';
import '../../../../global/common/toast.dart';

class InternshipDetailPage extends StatelessWidget {
  final Internship internship;

  const InternshipDetailPage({super.key, required this.internship});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(internship.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Internship Title
            Text(
              internship.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Company Name
            Text(
              "Company: ${internship.company}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            // Location
            Text(
              "Location: ${internship.location}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            // Description Section
            Text(
              "Description:",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              internship.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            // Job Scope Section
            Text(
              "Job Scope:",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              internship.jobScope,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            // Skills Needed Section
            Text(
              "Skills Needed:",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: internship.skills.map((skill) {
                return Chip(
                  label: Text(skill),
                  backgroundColor: Colors.blue.shade100,
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            // Apply Button
            ElevatedButton(
              onPressed: () => _confirmApplication(context),
              child: const Text("Apply Now"),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmApplication(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Confirm Application"),
          content: Text(
            "Are you sure you want to apply for '${internship.title}' at ${internship.company}?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _applyForInternship(context);
              },
              child: const Text("Apply"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _applyForInternship(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      showToast(message: "You must be logged in to apply.", isError: true);
      Navigator.pushNamed(context, "/login");
      return;
    }

    try {
      final applicationRef = FirebaseFirestore.instance.collection('applications').doc();
      final studentName = currentUser.displayName ?? "Anonymous Student";

      await applicationRef.set({
        'id': applicationRef.id,
        'studentId': currentUser.uid,
        'studentName': studentName,
        'companyId': internship.companyId,
        'companyName': internship.company,
        'internshipTitle': internship.title,
        'internshipId': internship.id,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Add notification for the company
      final notificationRef = FirebaseFirestore.instance
          .collection('notifications')
          .doc(internship.companyId)
          .collection('companyNotifications')
          .doc();

      await notificationRef.set({
        'id': notificationRef.id,
        'studentId': currentUser.uid,
        'studentName': studentName,
        'internshipTitle': internship.title,
        'internshipId': internship.id,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'unread',
      });

      showToast(message: "Successfully applied for '${internship.title}'!");
      Navigator.pop(context);
    } catch (e) {
      showToast(
        message: "Error applying for the internship. Please try again: $e",
        isError: true,
      );
    }
  }
}
