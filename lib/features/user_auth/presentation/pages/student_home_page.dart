import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inthub/models/internship_model.dart';
import 'package:inthub/features/user_auth/presentation/pages/internship_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("InternHub"),
      ),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search for internships",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Future<Internship>>>(
              stream: _readInternships(searchQuery),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No internships found."));
                }

                final futureInternships = snapshot.data!;
                return ListView.separated(
                  itemCount: futureInternships.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    return FutureBuilder<Internship>(
                      future: futureInternships[index],
                      builder: (context, internshipSnapshot) {
                        if (internshipSnapshot.connectionState == ConnectionState.waiting) {
                          return const ListTile(title: Text("Loading..."));
                        }
                        if (!internshipSnapshot.hasData) {
                          return const ListTile(title: Text("Error loading data"));
                        }

                        final internship = internshipSnapshot.data!;
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: ListTile(
                            title: Text(internship.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Company: ${internship.company}"),
                                Text("Location: ${internship.location}"),
                                Text("Description: ${internship.description}"),
                                if (internship.createdAt != null)
                                  Text(
                                    "Posted: ${DateFormat.yMMMd().add_jm().format(internship.createdAt!)}",
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => InternshipDetailPage(internship: internship),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              "InternHub",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () => Navigator.pushNamed(context, '/profile'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Notifications"),
            onTap: () => Navigator.pushNamed(context, '/userNotifications'),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushNamed(context, "/login");
            },
          ),
        ],
      ),
    );
  }

  Stream<List<Future<Internship>>> _readInternships(String query) {
    final internshipCollection = FirebaseFirestore.instance.collection("internships");

    return internshipCollection.snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) => Internship.fromSnapshot(doc)).toList();
    });
  }
}
