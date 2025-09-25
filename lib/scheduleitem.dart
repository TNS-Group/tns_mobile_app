import 'package:flutter/material.dart';

class ScheduleItem extends StatelessWidget {
  final TimeOfDay start;
  final TimeOfDay end;

  final String? title;

  const ScheduleItem({ 
    super.key,
    this.title,
    this.start = const TimeOfDay(hour: 7, minute: 30), 
    this.end = const TimeOfDay(hour: 8, minute: 30),
  });

  @override Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      decoration: BoxDecoration(
        color: Color.fromARGB(16, 128, 128, 128),
        borderRadius: BorderRadius.all(Radius.circular(8))
      ),
      child: Row(
        children: [
          Flexible(
            flex: 1,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text("${formatTimeOfDay(start)} - ${formatTimeOfDay(end)}")
            )
          ),

          Flexible(
            flex: 1,
            child: Container(
              alignment: Alignment.centerRight,
              child:Text(title ?? "untitled", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),)
            )
          ),
        ],
      )
    );
  }
}

String formatTimeOfDay(TimeOfDay tod) {
  final hour = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
  final minute = tod.minute.toString().padLeft(2, '0');
  final period = tod.period == DayPeriod.am ? "AM" : "PM";
  return "$hour:$minute$period";
}
