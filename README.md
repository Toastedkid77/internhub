# internhub
InternHub is a mobile application built with Flutter and Firebase that connects students and companies in internship marketplace. The app is designed to simplify the internship search and application process while giving companies tools to manage postings and applicants.
Authentication: Role-based login and registration for students and companies (Firebase Authentication).

Profiles:

Students create detailed profiles with education, skills, and experiences.

Companies maintain profiles with descriptions, contact details, and workplace information.

Internship Listings:

Companies can post internships with details like job scope, skills required, and location.

Students can browse opportunities tailored to their skills and apply directly.

Notifications: Real-time updates (via Firebase Cloud Messaging / Firestore snapshots) on application status.

Application Management: Companies can view student applications, and approve/reject them inside the dashboard.

User-Friendly UI: Clean navigation drawer, student/company dashboards, and editable profiles with image upload support.

Tech Stack

Frontend: Flutter (Dart)

Backend: Firebase (Auth, Firestore, Storage, Cloud Messaging)

Architecture: Role-based navigation, Provider/StatefulWidgets for state management

Tools: GitHub for version control, Android Studio / VS Code for development

Challenges & Solutions

Implemented real-time updates using Firestore snapshot listeners.

Solved profile picture persistence with Firebase Storage integration.

Used Firebase Security Rules to separate student and company data.

Designed a responsive UI with navigation drawers tailored for different user roles.

Outcome
InternHub provides a two-sided marketplace that streamlines internship applications, saving time for both students and companies. It demonstrates my ability to build full-stack mobile applications with cloud integration, role-based logic, and real-world usability.
