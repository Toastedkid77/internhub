import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  String companyLogo = "assets/default_company_logo.png";
  String companyName = "";
  String companyEmail = "";
  String companyWebsite = "";
  String aboutCompany = "";
  List<Map<String, String>> internshipListings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompanyProfile();
  }

  Future<void> _loadCompanyProfile() async {
    try {
      final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
      if (userId.isEmpty) {
        throw Exception("No user logged in.");
      }

      final doc = await FirebaseFirestore.instance
          .collection('companies')
          .doc(userId)
          .get();

      if (doc.exists) {
        setState(() {
          companyLogo = doc['companyLogo'] ?? companyLogo;
          companyName = doc['companyName'] ?? "Unknown Company";
          companyEmail = doc['companyEmail'] ?? "";
          companyWebsite = doc['companyWebsite'] ?? "";
          aboutCompany = doc['aboutCompany'] ?? "Describe your company.";
          internshipListings = List<Map<String, String>>.from(doc['internshipListings'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error loading company profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Company Profile"),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Company Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _changeCompanyLogo,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: companyLogo.startsWith('assets')
                              ? AssetImage(companyLogo)
                              : NetworkImage(companyLogo) as ImageProvider,
                        ),
                        const Icon(Icons.edit, color: Colors.white),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    companyName.isEmpty ? "Unknown Company" : companyName,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildEditableSection(
              title: "About Company",
              content: aboutCompany,
              onSave: (value) {
                setState(() {
                  aboutCompany = value;
                });
              },
            ),

            _buildInfoTile("Email", companyEmail.isEmpty ? "Not Provided" : companyEmail),
            _buildInfoTile("Website", companyWebsite.isEmpty ? "Not Provided" : companyWebsite),

            const SizedBox(height: 20),
            _buildInternshipListingsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableSection({
    required String title,
    required String content,
    required Function(String) onSave,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextFormField(
          initialValue: content,
          maxLines: 4,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: "Edit $title",
          ),
          onFieldSubmitted: onSave,
        ),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
    );
  }

  Widget _buildInternshipListingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Internship Listings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: internshipListings.length,
          itemBuilder: (context, index) {
            final listing = internshipListings[index];
            return ListTile(
              title: Text(listing['position'] ?? "Unknown Position"),
              subtitle: Text(listing['companyName'] ?? "Unknown Company"),
              trailing: Text(listing['location'] ?? "Unknown Location"),
            );
          },
        ),
        TextButton.icon(
          onPressed: _showAddInternshipDialog,
          icon: const Icon(Icons.add),
          label: const Text("Add Internship"),
        ),
      ],
    );
  }

  Future<void> _showAddInternshipDialog() async {
    final Map<String, String> newListing = {};
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Internship"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogTextField("Position", (value) => newListing['position'] = value),
            _buildDialogTextField("Company Name", (value) => newListing['companyName'] = value),
            _buildDialogTextField("Location", (value) => newListing['location'] = value),
            _buildDialogTextField("Job Scope", (value) => newListing['jobScope'] = value),
            _buildDialogTextField("Email", (value) => newListing['email'] = value),
            _buildDialogTextField("Website", (value) => newListing['website'] = value),
            _buildDialogTextField("Expiry Date", (value) => newListing['expiryDate'] = value),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                internshipListings.add(newListing);
              });
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogTextField(String label, Function(String) onChanged) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }

  Future<void> _changeCompanyLogo() async {
  try {
    // Use ImagePicker to let the user pick an image from the gallery
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Update the logo locally
      setState(() {
        companyLogo = pickedFile.path;
      });

      // Optionally, upload the new logo to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('company_logos/${FirebaseAuth.instance.currentUser?.uid}.jpg');

      await storageRef.putFile(File(pickedFile.path));

      // Get the download URL and update Firestore
      final logoUrl = await storageRef.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('companies')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({'logoUrl': logoUrl});

      setState(() {
        companyLogo = logoUrl; // Update to use the network URL
      });
    }
  } catch (e) {
    print("Error updating company logo: $e");
    // Optionally, show an error message to the user
  }
}
}
