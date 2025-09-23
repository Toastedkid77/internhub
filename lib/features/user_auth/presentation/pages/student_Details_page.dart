import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentDetailsPage extends StatefulWidget {
  final String studentId;
  final String internshipTitle;
  final String companyId;

  const StudentDetailsPage({
    super.key,
    required this.studentId,
    required this.internshipTitle,
    required this.companyId,
  });

  @override
  _StudentDetailsPageState createState() => _StudentDetailsPageState();
}

class _StudentDetailsPageState extends State<StudentDetailsPage> {
  Map<String, dynamic>? studentData;

  @override
  void initState() {
    super.initState();
    fetchStudentDetails();
  }

  Future<void> fetchStudentDetails() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('students').doc(widget.studentId).get();
      if (doc.exists) {
        setState(() {
          studentData = doc.data();
        });
      }
    } catch (e) {
      print("Error fetching student details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (studentData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Student Details")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(studentData!['fullName'] ?? "Student Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${studentData!['fullName']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Email: ${studentData!['email']}"),
            Text("Phone: ${studentData!['phoneNumber']}"),
            const SizedBox(height: 8),
            Text("About Me: ${studentData!['aboutMe']}"),
            const SizedBox(height: 8),
            Text("Education: ${studentData!['education'].join(', ')}"),
            Text("Experience: ${studentData!['experience'].join(', ')}"),
            Text("Skills: ${studentData!['skills'].join(', ')}"),
            const SizedBox(height: 16),

            if (studentData!['resume'].isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  // Open resume PDF (requires a PDF viewer)
                },
                child: const Text("View Resume"),
              ),

            const SizedBox(height: 20),

            // Approve & Reject Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _updateApplicationStatus('approved'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Approve"),
                ),
                ElevatedButton(
                  onPressed: () => _updateApplicationStatus('rejected'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Reject"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateApplicationStatus(String newStatus) async {
    try {
      // Update in company's notifications
      QuerySnapshot companyQuery = await FirebaseFirestore.instance
          .collection('notifications')
          .doc(widget.companyId)
          .collection('companyNotifications')
          .where('studentId', isEqualTo: widget.studentId)
          .where('internshipTitle', isEqualTo: widget.internshipTitle)
          .get();

      for (var doc in companyQuery.docs) {
        doc.reference.update({'status': newStatus});
      }

      // Update in student's notifications
      QuerySnapshot studentQuery = await FirebaseFirestore.instance
          .collection('notifications')
          .doc(widget.studentId)
          .collection('userNotifications')
          .where('internshipTitle', isEqualTo: widget.internshipTitle)
          .get();

      if (studentQuery.docs.isNotEmpty) {
        for (var doc in studentQuery.docs) {
          doc.reference.update({
            'status': newStatus,
            'timestamp': FieldValue.serverTimestamp(),
            'read': false,
          });
        }
      } else {
        FirebaseFirestore.instance.collection('notifications')
            .doc(widget.studentId)
            .collection('userNotifications')
            .add({
          'internshipTitle': widget.internshipTitle,
          'status': newStatus,
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        });
      }

      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Application $newStatus successfully!")),
      );

      // Close the page
      Navigator.pop(context);
    } catch (e) {
      print("Error updating application status: $e");
    }
  }
}
