import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> createStudentProfile({
  required String studentId,
  required String fullName,
  required String role,
  required String profilePicture,
  required String aboutMe,
  required String email,
  required String phoneNumber,
  required List<String> education,
  required List<String> experience,
  required List<String> skills,
  required String resume,
}) async {
  // Reference to the 'students' collection
  final studentRef = FirebaseFirestore.instance.collection('students').doc(studentId);

  // Data for the student document
  final studentData = {
    'fullName': fullName,
    'role': role,
    'profilePicture': profilePicture,
    'aboutMe': aboutMe,
    'email': email,
    'phoneNumber': phoneNumber,
    'education': education,
    'experience': experience,
    'skills': skills,
    'resume': resume,
  };

  // Add the document to Firestore
  await studentRef.set(studentData);
}

Future<Map<String, dynamic>> getStudentProfile(String studentId) async {
  final doc = await FirebaseFirestore.instance.collection('students').doc(studentId).get();
  if (doc.exists) {
    return doc.data()!;
  } else {
    throw Exception('Student not found');
  }
}

Future<void> updateStudentProfile(String studentId, String newAboutMe) async {
  final studentRef = FirebaseFirestore.instance.collection('students').doc(studentId);

  // Update the 'aboutMe' field
  await studentRef.update({'aboutMe': newAboutMe});
}

