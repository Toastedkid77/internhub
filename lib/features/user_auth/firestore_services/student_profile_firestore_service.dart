import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> saveStudentProfile({
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
  final studentRef = FirebaseFirestore.instance.collection('students').doc(studentId);

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

  await studentRef.set(studentData);
}
