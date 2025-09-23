import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Add FirebaseAuth import
import 'package:cloud_firestore/cloud_firestore.dart';  // Add FirebaseFirestore import
import 'package:inthub/features/app/splash%20screen/splash_screen.dart';
import 'package:inthub/features/screens/company/company_profile_screen.dart';
import 'package:inthub/features/user_auth/presentation/pages/company_home_page.dart';
import 'package:inthub/features/user_auth/presentation/pages/company_notification_page.dart';
import 'package:inthub/features/user_auth/presentation/pages/student_home_page.dart';
import 'package:inthub/features/user_auth/presentation/pages/login_page.dart';
import 'package:inthub/features/user_auth/presentation/pages/sign_up_page.dart';
import 'package:inthub/features/screens/student/profile_screen.dart';
import 'package:inthub/global/common/toast.dart'; // Add your custom toast
import 'package:inthub/features/user_auth/presentation/pages/user_notification_page.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: kIsWeb
          ? FirebaseOptions(
              apiKey: "AIzaSyCsHDQtI9DItQgSqwy45_y2xG9tDGxuER8",
              appId: "1:540215271818:web:8b22d4aee01acdce862873",
              messagingSenderId: "540215271818",
              projectId: "flutter-firebase-9c136",
            )
          : null,
    );

    // Enable App Check with DebugProvider for development (uncomment this when needed)
    if (!kIsWeb) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.debug,
      );
    }

    // Initialize Firebase Cloud Messaging (FCM)
    await setupFCM();

    // No errors in initialization
    runApp(MyApp());
  } catch (e) {
    // Handle Firebase initialization error
    debugPrint('Firebase initialization error: $e');
    // Optional: You can navigate to an error screen here
  }
}

Future<void> setupFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request notification permissions
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted notification permissions');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional notification permissions');
  } else {
    print('User declined or has not accepted notification permissions');
  }

  // Get the FCM token
  String? token = await messaging.getToken();
  print("FCM Token: $token");

  // Optionally, save the token to Firestore or your backend if needed
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'fcmToken': token,
    });
  }

  // Handle background notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Handle foreground notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received a message while in the foreground: ${message.notification}');
    if (message.notification != null) {
      showToast(message: message.notification?.body ?? "New notification");
    }
  });
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'InternHub',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(), // Starting screen of the app
      routes: {
        '/login': (context) => LoginScreen(),
        '/signUp': (context) => SignupScreen(),
        '/home': (context) => HomePage(),
        '/profile': (context) => StudentProfileScreen(),
        '/studentHome': (context) => HomePage(),
        '/companyHome': (context) => CompanyProfileScreen(),
        '/notifications': (context) => const CompanyNotificationsPage(),
        '/userNotifications': (context) => UserNotificationsPage(), 
      },
    );
  }
}
