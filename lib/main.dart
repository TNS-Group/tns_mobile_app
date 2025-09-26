import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:tns_mobile_app/infobar.dart';

void main() {
  runApp(const TNSMobileApp());
}

class TNSMobileApp extends StatelessWidget {
  const TNSMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TNS Mobile Application',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const TNSRootPage(),
    );
  }
}

class TNSRootPage extends StatefulWidget {
  const TNSRootPage({super.key});

  @override
  State<TNSRootPage> createState() => _TNSRootPageState();
}

class _TNSRootPageState extends State<TNSRootPage> {
  int _selectedPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 32, 255, 255),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(144),
          child: InformationBar(),
        ),
      ),
      body: Container(),
      bottomNavigationBar: SalomonBottomBar(
        margin: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        
        currentIndex: _selectedPageIndex,
        onTap: (index) {
          setState(() {
            _selectedPageIndex = index;
          });
        },
        items: _destinations,
      ),
    );
  }
}

final _destinations = [
  SalomonBottomBarItem(
    icon: const Icon(Icons.home_outlined),
    title: const Text("Home"),
    selectedColor: Colors.purple
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.edit_calendar_outlined),
    title: const Text("Schedule"),
    selectedColor: Colors.orange
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.person_outline),
    title: const Text("Profile"),
    selectedColor: Colors.teal
  ),
];
