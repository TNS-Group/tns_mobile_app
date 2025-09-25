import 'package:flutter/material.dart';

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

class InformationBar extends StatelessWidget {
  const InformationBar({super.key,});

  @override Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 96, height: 96,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                  child: FlutterLogo(size: 96)
                ),
              )
            ),
          ),
          Column(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RichText(
                text: TextSpan(
                  text: "Mr. ",
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 24, color: Colors.white),
                  children: [
                    TextSpan(text: "Aidan Ocmer", style: TextStyle(fontWeight: FontWeight.bold))
                  ]
                )
              ),
              RichText(
                text: TextSpan(
                  text: "Mathematics Teacher",
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.white),
                )
              ),
              RichText(
                text: TextSpan(
                  text: "Shown as ",
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.white),
                  children: [
                    TextSpan(
                      text: "Available",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ]
                )
              )
            ],
          ),
        ],
      )
    );
  }
}

class TNSDefaultPage extends StatefulWidget {
  const TNSDefaultPage({super.key, });

  @override
  State<TNSDefaultPage> createState() => _TNSDefaultPageState();
}

class _TNSDefaultPageState extends State<TNSDefaultPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 96, 255, 255),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(128), 
          child: InformationBar()
        )
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
