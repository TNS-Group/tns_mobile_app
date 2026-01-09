import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
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

  String? tabletToken;

  @override void initState() {
    super.initState();

    loginPageKey = GlobalKey<TNSLoginPageState>();
    loginPage = TNSLoginPage(
      key: loginPageKey,
      onLogin: (email, password) async {
        loginPageKey.currentState?.setState(() {
          loginPageKey.currentState?.loading = true;
        });

        String? fcmToken;

        if (Platform.isAndroid || Platform.isIOS) {
          FirebaseMessaging messaging = FirebaseMessaging.instance;

          NotificationSettings settings = await messaging.requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          );
          if (settings.authorizationStatus == AuthorizationStatus.authorized) {
            fcmToken = await messaging.getToken();

            api.login(email, password).then((teacher) {
              if (teacher == null) {
                  loginPageKey.currentState?.setState(() {
                    loginPageKey.currentState?.loading = false;
                    loginPageKey.currentState?.hasError = true;
                  });
                } else {
                  prefs.setString("token", teacher.token ?? '');
                  setState(() {
                    currentPage = TNSRootPage(initialTeacher: teacher, key: UniqueKey());
                  });

                  loginPageKey.currentState?.setState(() {
                    loginPageKey.currentState?.loading = false;
                  });

                  api.sendDeviceToken(fcmToken!, teacher.token!);
                }
            });
          }
        }

        api.login(email, password).then((teacher) {
          if (teacher == null) {
              loginPageKey.currentState?.setState(() {
                loginPageKey.currentState?.loading = false;
                loginPageKey.currentState?.hasError = true;
              });
            } else {
              prefs.setString("token", teacher.token ?? '');
              setState(() {
                currentPage = TNSRootPage(initialTeacher: teacher, key: UniqueKey());
              });

              loginPageKey.currentState?.setState(() {
                loginPageKey.currentState?.loading = false;
              });
            }
        });
      },
    );

    currentPage = Scaffold(key: UniqueKey(),
      body: Center(
        child: CircularProgressIndicator()
      ),
    );

    SharedPreferences.getInstance().then((v) {
      prefs = v;

      if (!prefs.containsKey("token")) {
        setState(() {
          currentPage = loginPage;
        });
      } else {
        api.getTeacherSelf(prefs.getString("token") ?? '').then((teacher) async {
          if (teacher == null) {
            setState(() {
              currentPage = loginPage;
            });

            await prefs.remove('token');
            return;
          }

          setState(() {
            currentPage = TNSRootPage(initialTeacher: teacher, key: UniqueKey());
          });
        });
      }
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
