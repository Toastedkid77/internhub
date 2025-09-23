import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> saveCompanyProfile({
  required String companyId,
  required String companyName,
  required String role,
  required String logo,
  required String about,
  required String email,
  required String phoneNumber,
  required String website,
  required String industry,
  required List<String> locations,
}) async {
  final companyRef = FirebaseFirestore.instance.collection('companies').doc(companyId);

  final companyData = {
    'companyName': companyName,
    'role': role,
    'logo': logo,
    'about': about,
    'email': email,
    'phoneNumber': phoneNumber,
    'website': website,
    'industry': industry,
    'locations': locations,
  };

  try {
    await companyRef.set(companyData);
    print('Company profile saved successfully!');
  } catch (e) {
    print('Failed to save company profile: $e');
  }
}

