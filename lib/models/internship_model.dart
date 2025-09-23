import 'package:cloud_firestore/cloud_firestore.dart';

class Internship {
  final String? id;
  final String title;
  final String company; // This will be fetched dynamically
  final String location;
  final String description;
  final String jobScope;
  final String companyId;
  final DateTime? createdAt;
  final List<String> skills;

  Internship({
    this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.description,
    required this.jobScope,
    required this.companyId,
    this.createdAt,
    required this.skills,
  });

  // Factory method to create an Internship instance from Firestore snapshot
  static Future<Internship> fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) async {
    final data = snapshot.data()!;
    String companyId = data['companyId'];

    // Fetch company name from Firestore using companyId
    String companyName = await _fetchCompanyName(companyId);

    return Internship(
      id: snapshot.id,
      title: data['title'],
      company: companyName, // ✅ Fetching dynamically
      location: data['location'],
      description: data['description'],
      jobScope: data['jobScope'],
      companyId: companyId,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      skills: data['skills'] != null
          ? List<String>.from(data['skills']) // Convert list from Firestore
          : [],
    );
  }

  // Function to fetch company name using companyId
  static Future<String> _fetchCompanyName(String companyId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> companySnapshot =
          await FirebaseFirestore.instance.collection('companies').doc(companyId).get();

      if (companySnapshot.exists) {
        return companySnapshot.data()?['companyName'] ?? 'Unknown Company';
      } else {
        return 'Unknown Company';
      }
    } catch (e) {
      print("Error fetching company name: $e");
      return 'Unknown Company';
    }
  }

  // Convert Internship instance into a Map to save to Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'companyId': companyId, // Save companyId instead of company name
      'location': location,
      'description': description,
      'jobScope': jobScope,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'skills': skills,
    };
  }
}
