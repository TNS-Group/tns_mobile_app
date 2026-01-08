import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tns_mobile_app/notification_handler.dart';
import 'package:tns_mobile_app/pages/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid || Platform.isIOS) {
    await Firebase.initializeApp();
    await NotificationService.instance.initialize();
  } 

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
    ThemeMode themeMode = ThemeMode.system;

    return MaterialApp(
      themeMode: themeMode,
      title: 'TNS Mobile Application',
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade700, 
          primary: Colors.blue.shade700, 
          brightness: Brightness.light
        )
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade300, 
          primary: Colors.blue.shade300, 
          brightness: Brightness.dark
        )
      ),
      home: AuthWrapper(),
    );
  }
}
