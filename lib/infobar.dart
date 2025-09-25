import 'package:flutter/material.dart';
import 'package:tns_mobile_app/availability.dart';


class InformationBar extends StatefulWidget {
  const InformationBar({super.key,});

  @override
  State<InformationBar> createState() => InformationBarState();
}


class InformationBarState extends State<InformationBar> {
  String name = "Juan Dela Cruz";
  String subject = "N/A";
  String? prefix;
  String? postfix;

  Availability availability = Availability.absent;

  @override Widget build(BuildContext context) {
    final Widget nameWidget = RichText(
      text: TextSpan(
        text: (prefix == null) ? "" : "$prefix ",
        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 24, color: Colors.white),
        children: [
          TextSpan(text: name, style: TextStyle(fontWeight: FontWeight.bold)),
          if ( postfix != null ) TextSpan(text: ", $postfix")
        ]
      )
    );

    final Widget subjectWidget = RichText(
      text: TextSpan(
        text: "$subject Teacher",
        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.white),
      )
    );
    
    final Widget availabilityWidget = RichText(
      text: TextSpan(
        text: "Shown as ",
        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.white),
        children: [
          TextSpan(
            text: availability.label,
            style: TextStyle(fontWeight: FontWeight.bold),
          )
        ]
      )
    );

    final Widget profileIcon = FlutterLogo(size: 96); // Placeholder

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
                  child: profileIcon
                ),
              )
            ),
          ),
          Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [ nameWidget, subjectWidget, availabilityWidget ],
          ),
        ],
      )
    );
  }
}
