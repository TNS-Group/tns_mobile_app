import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tns_mobile_app/network/api.dart' as api;
import 'package:tns_mobile_app/pages/login_page.dart';
import 'package:tns_mobile_app/pages/root_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<StatefulWidget> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Widget currentPage;
  late Widget loginPage;
  late GlobalKey<TNSLoginPageState> loginPageKey;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();

    loginPageKey = GlobalKey<TNSLoginPageState>();
    loginPage = TNSLoginPage(
      key: loginPageKey,
      onLogin: (email, password) async {
        loginPageKey.currentState?.setState(() {
          loginPageKey.currentState?.loading = true;
        });

        // 1. Perform Login
        final teacher = await api.login(email, password);

        if (teacher == null) {
          loginPageKey.currentState?.setState(() {
            loginPageKey.currentState?.loading = false;
            loginPageKey.currentState?.hasError = true;
          });
          return;
        }

        // 2. Persist Session
        await prefs.setString("token", teacher.token ?? '');

        // 3. Handle Notifications (Web & Mobile compatible)
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        NotificationSettings settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          try {
            // Web requires a vapidKey from Firebase Console
            String? fcmToken = await messaging.getToken(
              vapidKey: kIsWeb ? "YOUR_PUBLIC_VAPID_KEY_HERE" : null,
            );
            if (fcmToken != null && teacher.token != null) {
              await api.sendDeviceToken(fcmToken, teacher.token!);
            }
          } catch (e) {
            debugPrint("FCM Token acquisition failed: $e");
          }
        }

        // 4. Navigate to Root
        setState(() {
          currentPage = TNSRootPage(initialTeacher: teacher, key: UniqueKey());
        });

        loginPageKey.currentState?.setState(() {
          loginPageKey.currentState?.loading = false;
        });
      },
    );

    // Initial Loading State
    currentPage = const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );

    _prepareSession();
  }

  Future<void> _prepareSession() async {
    prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey("token")) {
      setState(() => currentPage = loginPage);
      return;
    }

    final token = prefs.getString("token") ?? '';
    final teacher = await api.getTeacherSelf(token);

    if (teacher == null) {
      await prefs.remove('token');
      setState(() => currentPage = loginPage);
      return;
    }

    // Refresh FCM token on background resume/auto-login
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.getNotificationSettings();
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? fcmToken = await messaging.getToken(
        vapidKey: kIsWeb ? "YOUR_PUBLIC_VAPID_KEY_HERE" : null,
      );
      if (fcmToken != null) {
        api.sendDeviceToken(fcmToken, teacher.token!);
      }
    }

    setState(() {
      currentPage = TNSRootPage(initialTeacher: teacher, key: UniqueKey());
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
      child: currentPage,
    );
  }
}