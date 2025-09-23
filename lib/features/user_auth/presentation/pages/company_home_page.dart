import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CompanyDashboard extends StatefulWidget {
  const CompanyDashboard({Key? key}) : super(key: key);

  @override
  State<CompanyDashboard> createState() => _CompanyDashboardState();
}

class _CompanyDashboardState extends State<CompanyDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _jobScopeController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();

  String? profileImageUrl;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadCompanyInfo();
  }

  Future<void> _loadCompanyInfo() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('companies').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data();
      setState(() {
        _companyNameController.text = data?['companyName'] ?? 'Unknown Company';
        profileImageUrl = data?['profileImage'];
        _aboutController.text = data?['about'] ?? '';
        _emailController.text = data?['email'] ?? user.email ?? '';
        _phoneController.text = data?['phone'] ?? '';
      });
    }
  }

  Future<void> _saveCompanyInfo() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('companies').doc(user.uid).set({
        'companyName': _companyNameController.text,
        'about': _aboutController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'profileImage': profileImageUrl ?? '',
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Company information updated!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update information: $e")),
      );
    }
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _addInternship() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('internships').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'jobScope': _jobScopeController.text,
        'skills': _skillsController.text,
        'location': _locationController.text,
        'companyId': user.uid,
        'postedAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Internship added successfully!")),
      );
      _titleController.clear();
      _descriptionController.clear();
      _jobScopeController.clear();
      _skillsController.clear();
      _locationController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add internship: $e")),
      );
    }
  }

  void _logout() {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildPostedInternships() {
    final user = _auth.currentUser;
    if (user == null) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('internships')
          .where('companyId', isEqualTo: user.uid)
          .orderBy('postedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No internships posted yet."));
        }

        final internships = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: internships.length,
          itemBuilder: (context, index) {
            final internship = internships[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(internship['title'] ?? 'Untitled'),
                subtitle: Text(internship['description'] ?? 'No description'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await internship.reference.delete();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Internship deleted.")),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Company Dashboard")),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: profileImageUrl != null
                        ? NetworkImage(profileImageUrl!)
                        : const AssetImage('assets/default_profile.jpg')
                            as ImageProvider,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _companyNameController.text.isNotEmpty
                        ? _companyNameController.text
                        : "Company Name",
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text("Notifications"),
              onTap: () {
                Navigator.pushNamed(context, '/notifications');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Company Information"),
                    GestureDetector(
                      onTap: _pickProfileImage,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: _profileImage == null
                            ? (profileImageUrl != null
                                ? NetworkImage(profileImageUrl!)
                                : AssetImage('assets/default_profile.jpg')
                                    as ImageProvider)
                            : FileImage(_profileImage!),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField("Company Name", _companyNameController),
                    _buildTextField("Email", _emailController),
                    _buildTextField("Phone Number", _phoneController),
                    _buildTextField("About Us", _aboutController, maxLines: 3),
                    ElevatedButton(
                      onPressed: _saveCompanyInfo,
                      child: const Text("Save Information"),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Add New Internship"),
                    _buildTextField("Title", _titleController),
                    _buildTextField("Description", _descriptionController, maxLines: 3),
                    _buildTextField("Job Scope", _jobScopeController),
                    _buildTextField("Required Skills", _skillsController),
                    _buildTextField("Location", _locationController),
                    ElevatedButton(
                      onPressed: _addInternship,
                      child: const Text("Post Internship"),
                    ),
                  ],
                ),
              ),
            ),
            _buildSectionTitle("Posted Internships"),
            _buildPostedInternships(),
          ],
        ),
      ),
    );
  }
}
