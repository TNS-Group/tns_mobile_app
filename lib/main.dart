import 'package:flutter/material.dart';
import 'package:tns_mobile_app/infobar.dart';
import 'package:tns_mobile_app/scheduleitem.dart';

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
      home: const TNSDefaultPage(),
    );
  }
}


class TNSDefaultPage extends StatefulWidget {
  const TNSDefaultPage({super.key, });

  @override
  State<TNSDefaultPage> createState() => _TNSDefaultPageState();
}


class _TNSDefaultPageState extends State<TNSDefaultPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 32, 255, 255),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(128), 
          child: InformationBar()
        )
      ),

      body: Container(
        margin: EdgeInsets.all(16),
        child: Center (
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("My Schedule", textScaler: TextScaler.linear(1.61),),
              ListView(
                shrinkWrap: true,
                children: [
                  SizedBox(width: double.infinity, child: ScheduleItem(),),
                  ScheduleItem(),
                  ScheduleItem(),
                  ScheduleItem(),
                  ScheduleItem(),
                ],
              )
            ]
          )
        )
      ),
    );
  }
}
