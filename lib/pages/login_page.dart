import 'dart:io';
import 'package:tns_mobile_app/globals.dart' as globals;
import 'package:flutter/material.dart';

class TNSLoginPage extends StatefulWidget {
  final void Function(String email, String password) onLogin;
  const TNSLoginPage({super.key, required this.onLogin});

  @override 
  State<TNSLoginPage> createState() => TNSLoginPageState();
}

class TNSLoginPageState extends State<TNSLoginPage> {
  bool showPassword = false;

  late TextEditingController emailInputController;
  late TextEditingController passwordInputController;

  bool hasError = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    emailInputController = TextEditingController();
    passwordInputController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1, 0),
                end: Alignment(1, 1.5),
                colors: [
                  Theme.of(context).colorScheme.surfaceContainer,
                  Colors.blue
                ]
              )
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 64),
              child: Column (
                spacing: 16,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // TextField(
                  //   controller: serverInputController,
                  //   decoration: InputDecoration(
                  //     suffixIcon: const Icon(Icons.mail),
                  //     label: const Text("Server / Host"),
                  //     border: OutlineInputBorder()
                  //   ),
                  // ),
                  TextField(
                    controller: emailInputController,
                    decoration: InputDecoration(
                      suffixIcon: const Icon(Icons.mail),
                      errorText: hasError ? "Invalid Email or Password" : null,
                      label: const Text("Email"),
                      border: OutlineInputBorder()
                    ),
                  ),
                  TextField(
                    obscureText: !showPassword,
                    controller: passwordInputController,
                    decoration: InputDecoration(
                      suffixIcon: const Icon(Icons.key),
                      errorText: hasError ? "Invalid Email or Password" : null,
                      label: const Text("Password"),
                      border: OutlineInputBorder()
                    ),
                  ),
                  CheckboxListTile(
                    title: const Text('Show Password'),
                    value: showPassword,
                    onChanged: (bool? newValue) {
                      setState(() {
                        showPassword = newValue ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading, // Or .trailing
                  ),
                  FilledButton(
                    onPressed: (){
                      widget.onLogin(
                        emailInputController.text, 
                        passwordInputController.text
                      );
                    },
                    child: SizedBox(
                      // height: 64,
                      width: double.infinity,

                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text("Login")
                        )
                      )
                    ),
                  ),
                ],
              )
            )
          ),
          if (loading)
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withAlpha(128),
              borderRadius: BorderRadius.circular(8)
            ),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        ],
      ),
    );
  }
}
