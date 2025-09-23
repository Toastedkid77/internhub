import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserNotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Notifications")),
        body: Center(
          child: Text("Please log in to view your notifications."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Notifications")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .doc(currentUser.uid)
            .collection('userNotifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No notifications available."));
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final data = notification.data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text(data['internshipTitle'] ?? "Unknown Internship"),
                  subtitle: Text(
                    data['status'] == "approved"
                        ? "Your application has been accepted."
                        : "Your application has been rejected.",
                  ),
                  trailing: Icon(
                    data['status'] == "approved"
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined,
                    color: data['status'] == "approved"
                        ? Colors.green
                        : Colors.red,
                  ),
                  onTap: () {
                    // Mark as read when tapped
                    _markAsRead(notification.reference);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _markAsRead(DocumentReference notificationRef) {
    notificationRef.update({'read': true});
  }
}
