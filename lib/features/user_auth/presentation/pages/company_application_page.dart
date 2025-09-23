import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CompanyApplicationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Applications")),
        body: Center(child: Text("Please log in to view applications.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Applications")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('applications')
            .where('companyId', isEqualTo: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No applications found."));
          }

          final applications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final application = applications[index];
              final data = application.data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text(data['studentName'] ?? "Unknown Student"),
                  subtitle: Text("Internship: ${data['internshipTitle']}"),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) => _updateApplicationStatus(application.id, value),
                    itemBuilder: (context) => [
                      PopupMenuItem(value: "Accepted", child: Text("Accept")),
                      PopupMenuItem(value: "Rejected", child: Text("Reject")),
                    ],
                  ),
                  onTap: () {
                    _showApplicantDetails(context, data['studentId']);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _updateApplicationStatus(String applicationId, String status) async {
    await FirebaseFirestore.instance
        .collection('applications')
        .doc(applicationId)
        .update({'status': status});
  }

  void _showApplicantDetails(BuildContext context, String studentId) async {
    if (studentId.isEmpty) return;

    final studentDoc = await FirebaseFirestore.instance
        .collection('students')
        .doc(studentId)
        .get();

    if (!studentDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Student profile not found!")),
      );
      return;
    }

    final studentData = studentDoc.data() as Map<String, dynamic>;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(studentData['fullName'] ?? "Student Details"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfilePicture(studentData['profilePicture']),
                SizedBox(height: 10),
                _buildInfoRow("Email", studentData['email']),
                _buildInfoRow("Phone", studentData['phoneNumber']),
                _buildInfoRow("About Me", studentData['aboutMe']),
                _buildInfoRow("Education", _formatList(studentData['education'])),
                _buildInfoRow("Experience", _formatList(studentData['experience'])),
                _buildInfoRow("Skills", _formatList(studentData['skills'])),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfilePicture(String? url) {
    return Center(
      child: CircleAvatar(
        radius: 40,
        backgroundImage: url != null && url.isNotEmpty
            ? NetworkImage(url)
            : AssetImage('assets/placeholder.png') as ImageProvider,
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        "$label: ${value ?? 'N/A'}",
        style: TextStyle(fontSize: 14),
      ),
    );
  }


  String _formatList(dynamic list) {
    if (list == null || list.isEmpty) return "N/A";
    return (list as List).join(", ");
  }
}
