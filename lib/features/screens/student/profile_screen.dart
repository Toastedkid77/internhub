import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inthub/global/common/toast.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  String profilePicture = "";
  String fullName = "";
  String email = "";
  String aboutMe = "";
  String phoneNumber = "";
  List<String> education = [];
  List<String> experience = [];
  List<String> skills = [];
  String resumePath = "";

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? "";
  }

  Future<void> fetchProfileData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('students')
          .doc(getCurrentUserId())
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          profilePicture = data['profilePicture'] ?? "";
          fullName = data['fullName'] ?? "";
          email = data['email'] ?? "";
          aboutMe = data['aboutMe'] ?? "";
          phoneNumber = data['phoneNumber'] ?? "";
          education = List<String>.from(data['education'] ?? []);
          experience = List<String>.from(data['experience'] ?? []);
          skills = List<String>.from(data['skills'] ?? []);
          resumePath = data['resume'] ?? "";
        });
      }
    } catch (e) {
      print("Error fetching profile data: $e");
    }
  }

  Future<void> saveProfile() async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('students')
          .doc(getCurrentUserId());
      await docRef.set({
        'profilePicture': profilePicture,
        'fullName': fullName,
        'email': email,
        'aboutMe': aboutMe,
        'phoneNumber': phoneNumber,
        'education': education,
        'experience': experience,
        'skills': skills,
        'resume': resumePath,
      });
      showToast(message: "Profile saved successfully!");
    } catch (e) {
      showToast(message: "Failed to save profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildEditableSection(
              title: "About Me",
              content: aboutMe,
              onSave: (value) => setState(() => aboutMe = value),
            ),
            const SizedBox(height: 20),
            _buildAddableSection(
              title: "Education",
              items: education,
              onAdd: (value) => setState(() => education.add(value)),
              onDelete: (index) => setState(() => education.removeAt(index)),
            ),
            _buildAddableSection(
              title: "Experience",
              items: experience,
              onAdd: (value) => setState(() => experience.add(value)),
              onDelete: (index) => setState(() => experience.removeAt(index)),
            ),
            _buildAddableSection(
              title: "Skills",
              items: skills,
              onAdd: (value) => setState(() => skills.add(value)),
              onDelete: (index) => setState(() => skills.removeAt(index)),
            ),
            const SizedBox(height: 20),
            _buildResumeSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final nameController = TextEditingController(text: fullName);
    final emailController = TextEditingController(text: email);
    final phoneController = TextEditingController(text: phoneNumber);

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _changeProfilePicture,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: profilePicture.isNotEmpty
                  ? NetworkImage(profilePicture)
                  : const AssetImage('assets/placeholder.png') as ImageProvider,
              child: profilePicture.isEmpty
                  ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: nameController,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "Enter Your Name",
            ),
            onChanged: (value) {
              setState(() {
                fullName = value;
              });
            },
          ),
          TextField(
            controller: emailController,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "Enter Your Email",
            ),
            onChanged: (value) {
              setState(() {
                email = value;
              });
            },
          ),
          TextField(
            controller: phoneController,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "Enter Your Phone Number",
            ),
            onChanged: (value) {
              setState(() {
                phoneNumber = value;
              });
            },
          ),
        ],
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
            border: OutlineInputBorder(),
            hintText: "Edit $title",
          ),
          onFieldSubmitted: onSave,
        ),
      ],
    );
  }

  Widget _buildAddableSection({
    required String title,
    required List<String> items,
    required Function(String) onAdd,
    required Function(int) onDelete,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ListView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(items[index]),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => onDelete(index),
              ),
            );
          },
        ),
        TextButton.icon(
          onPressed: () => _showAddDialog(title, onAdd),
          icon: const Icon(Icons.add),
          label: Text("Add $title"),
        ),
      ],
    );
  }

  Widget _buildResumeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Resume",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (resumePath.isEmpty)
          TextButton.icon(
            onPressed: _uploadResume,
            icon: const Icon(Icons.upload),
            label: const Text("Upload Resume"),
          )
        else
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(resumePath.split('/').last),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => setState(() => resumePath = ""),
            ),
          ),
      ],
    );
  }

  Future<void> _changeProfilePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profilePicture = pickedFile.path;
      });
    }
  }

  Future<void> _uploadResume() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'doc']);
    if (result != null && result.files.single.path != null) {
      setState(() {
        resumePath = result.files.single.path!;
      });
    }
  }

  void _showAddDialog(String title, Function(String) onAdd) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add $title"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "Enter $title"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onAdd(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
