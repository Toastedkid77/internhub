import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inthub/features/user_auth/presentation/pages/student_Details_page.dart';

class CompanyNotificationsPage extends StatelessWidget {
  const CompanyNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final companyId = FirebaseAuth.instance.currentUser!.uid; // Get company UID

    return Scaffold(
      appBar: AppBar(
        title: const Text("Company Notifications"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .doc(companyId)
            .collection('companyNotifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No notifications available."));
          }

          final notifications = snapshot.data!.docs;

          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final notificationData = notifications[index].data() as Map<String, dynamic>;
              final studentId = notificationData['studentId'];
              final internshipTitle = notificationData['internshipTitle'];
              final status = notificationData['status'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('students') // Fetch student details
                    .doc(studentId)
                    .get(),
                builder: (context, studentSnapshot) {
                  if (studentSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      title: Text("Loading..."),
                    );
                  }

                  if (!studentSnapshot.hasData) {
                    return const ListTile(
                      title: Text("Error loading student data"),
                    );
                  }

                  final studentData = studentSnapshot.data!.data() as Map<String, dynamic>;
                  final studentName = studentData['name'] ?? 'Unknown Student';
                  final studentEmail = studentData['email'] ?? 'No Email';
                  final studentSkills = studentData['skills'] ?? 'No Skills Available';

                  return ListTile(
                    title: Text(studentName),
                    subtitle: Text(
                      "Applied for: $internshipTitle\nEmail: $studentEmail\nSkills: ${studentSkills.join(', ')}",
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudentDetailsPage(
                              studentId: studentId,
                              internshipTitle: internshipTitle,
                              companyId: companyId,
                            ),
                          ),
                        );
                      },
                      child: const Text("View Details"),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // Show Approve/Reject options
  void _showApplicationActions(BuildContext context, String studentId, String internshipTitle, String status, String companyId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Application Actions"),
          content: Text("Do you want to approve or reject the application for '$internshipTitle'?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _updateApplicationStatus(studentId, internshipTitle, 'approved', companyId);
                Navigator.of(context).pop();
              },
              child: const Text("Approve"),
            ),
            TextButton(
              onPressed: () {
                _updateApplicationStatus(studentId, internshipTitle, 'rejected', companyId);
                Navigator.of(context).pop();
              },
              child: const Text("Reject"),
            ),
          ],
        );
      },
    );
  }

  //  Update both company & user notifications
  void _updateApplicationStatus(String studentId, String internshipTitle, String newStatus, String companyId) {
    FirebaseFirestore.instance.collection('notifications')
        .doc(companyId)
        .collection('companyNotifications')
        .where('studentId', isEqualTo: studentId)
        .where('internshipTitle', isEqualTo: internshipTitle)
        .get()
        .then((querySnapshot) {
          for (var doc in querySnapshot.docs) {
            doc.reference.update({'status': newStatus});
          }
        });

    //  Notify the student
    FirebaseFirestore.instance.collection('notifications')
        .doc(studentId)
        .collection('userNotifications')
        .where('internshipTitle', isEqualTo: internshipTitle)
        .get()
        .then((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            for (var doc in querySnapshot.docs) {
              doc.reference.update({
                'status': newStatus, 
                'timestamp': FieldValue.serverTimestamp(),
                'read': false,
              });
            }
          } else {
            FirebaseFirestore.instance.collection('notifications')
                .doc(studentId)
                .collection('userNotifications')
                .add({
                  'internshipTitle': internshipTitle,
                  'status': newStatus,
                  'timestamp': FieldValue.serverTimestamp(),
                  'read': false,
                });
          }
        });
  }
}
