// TODO: Implement schedule calendar editor 
// TODO: Implement profile editor

import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:tns_mobile_app/availability.dart';
import 'package:tns_mobile_app/infobar.dart';

void main() {
  runApp(const TNSMobileApp());
}

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
      home: const TNSRootPage(),
    );
  }
}

class TNSRootPage extends StatefulWidget {
  const TNSRootPage({super.key});

  @override
  State<TNSRootPage> createState() => _TNSRootPageState();
}

class _TNSRootPageState extends State<TNSRootPage> with TickerProviderStateMixin {
  late PageController _pageViewController;
  late TabController _tabController;

  bool _doNotDisturb = false;
  bool _hasCheckedIn = false;
  int _selectedPageIndex = 0;

  Availability _availability = Availability.absent;

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
    _tabController.dispose();
  }

  void _updateCurrentPageIndex(int index) {
    _tabController.index = index;
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuad,
    );
  }

  @override
  Widget build(BuildContext context) {
    final quickSettings = Column(
      spacing: 8,
      children: [
        Row(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child:Icon(Icons.do_not_disturb_on),
            ),
            Expanded(
              child: const Text("Do Not Disturb"),
            ),
            Switch(value: _doNotDisturb, onChanged: ( value ) {
              setState((){
                _doNotDisturb = value;
              });
            }),
          ],
        ),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _hasCheckedIn ? null : (){
              setState(() {
                _hasCheckedIn = true;
                _availability = Availability.available;
              });
            }, 
            child: Padding( 
              padding: EdgeInsets.all(16),
              child: Text(_hasCheckedIn ? "Already Checked In" : "Check In")
            )
          ),
        )
      ],
    );

    final classesList = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: double.infinity,
        height: 196,
        child: Stack(
          children: [

            // Scrollable List
            ListView(
              shrinkWrap: true,
              children: [ for (Widget i in [
                HomePageClassDisplay(
                  start: TimeOfDay(hour:17, minute:30),
                  end: TimeOfDay(hour:18, minute:30),
                  className: "St. John the Baptist",
                ),
                HomePageClassDisplay(
                  start: TimeOfDay(hour:17, minute:30),
                  end: TimeOfDay(hour:18, minute:30),
                  className: "St. Mark",
                ),
              ]) Padding(padding: EdgeInsets.symmetric(vertical: 4), child: i) ],
            ),

            // Gradient Overlay
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0, 0.25),
                      end: Alignment(0, 1),
                      colors: [
                        Theme.of(context).colorScheme.surface.withAlpha(0),
                        Theme.of(context).colorScheme.surface,
                      ]
                    )
                  ),
                ),
              ),
            )
          ]
        )
      ),
    );

    final homePage = Container(
      padding: EdgeInsets.all(16),
      child: Column(
        spacing: 32,
        children: [
          quickSettings,
          classesList,
        ],
      )
    );

    final schedPage = Container(
      padding: EdgeInsets.all(16),
      child: Column(
        spacing: 32,
        children: [
          const Text("Schedule Page")
        ],
      )
    );

    final profilePage = Container(
      padding: EdgeInsets.all(16),
      child: Column(
        spacing: 32,
        children: [
          const Text("Profle Page")
        ],
      )
    );

    return Scaffold(

      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(144),
          child: InformationBar(
            name: "Aidan Ocmer",
            prefix: "Mr.",
            subject: "Mathematics",
            availability: _doNotDisturb ? Availability.doNotDisturb : _availability,
          ),
        ),
      ),

      body: PageView(
        controller: _pageViewController,
        children: [
          homePage,
          schedPage,
          profilePage
        ],
      ),


      bottomNavigationBar: SalomonBottomBar(
        margin: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        
        currentIndex: _selectedPageIndex,
        onTap: (index) {
          setState(() {
            _tabController.index = index;
            _selectedPageIndex = index;
            _updateCurrentPageIndex(index);
          });
        },
        items: _destinations,
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final bool bold;
  final String title;
  final Alignment alignment;

  const SectionLabel({ super.key, this.title = "", this.alignment = Alignment.center, this.bold = false });

  @override Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Text(
        title,
        textScaler: TextScaler.linear(1.61),
        style: TextStyle(
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: Theme.of(context).colorScheme.tertiary,
        )
      )
    );
  }
}

class HomePageClassDisplay extends StatelessWidget {
  final String className;
  final TimeOfDay start;
  final TimeOfDay end;

  const HomePageClassDisplay( { super.key, required this.start, required this.end, this.className = "Class" } );

  @override Widget build(BuildContext context) {
    return  
      Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment(0.5, 1.0),
            colors: [
              Theme.of(context).colorScheme.surfaceContainer,
              Colors.blue
            ]
          )
        ),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            spacing: 4,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${hasTimePassed(end) ? "PREVIOUS" : hasTimePassed(start) ? "CURRENT" : "NEXT"} CLASS", textScaler: TextScaler.linear(1/1.61),),
              Text(className, textScaler: TextScaler.linear(1.61),),
              Text("${formatTimeOfDay(start)} - ${formatTimeOfDay(end)}"),
            ],
          )
        )
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

String formatTimeOfDay(TimeOfDay tod) {
  final hour = tod.hourOfPeriod;
  final minute = tod.minute.toString().padLeft(2, '0');
  final period = tod.period == DayPeriod.am ? "AM" : "PM";
  return "$hour:$minute$period";
}

bool hasTimePassed(TimeOfDay target) {
  final now = TimeOfDay.now();

  if (now.hour > target.hour) return true;
  if (now.hour == target.hour && now.minute >= target.minute) return true;

  return false;
}
