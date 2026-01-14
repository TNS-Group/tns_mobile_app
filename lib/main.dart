import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Use kIsWeb instead of dart:io
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tns_mobile_app/pages/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase based on platform
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCnlphOLXgUoDvXim5H8IA9CUbX7_ipK4c",
        authDomain: "tns-notif.firebaseapp.com",
        projectId: "tns-notif",
        storageBucket: "tns-notif.firebasestorage.app",
        messagingSenderId: "146195934050",
        appId: "1:146195934050:web:a04b6a79dc8353e7bd1a3b",
        measurementId: "G-T7XPEBE2QS",
      ),
    );
  } else {
    // For Mobile (Android/iOS)
    await Firebase.initializeApp();
  }

  // Orientation settings (Note: Some browsers ignore this, but it won't crash)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const TNSMobileApp());
}

// Ultraroot Application
class TNSMobileApp extends StatelessWidget {
  const TNSMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Keeping your theme logic as is, it works perfectly on web.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      title: 'TNS Mobile Application',
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade700,
          primary: Colors.blue.shade700,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade300,
          primary: Colors.blue.shade300,
          brightness: Brightness.dark,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}