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
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        spacing: 16,
        children: [
          Flexible(
            flex: 4,
            child: Container(
              alignment: Alignment.centerRight,
              child: Text("${formatTimeOfDay(start)} - ${formatTimeOfDay(end)}")
            )
          ),
          Flexible(
            flex: 11,
            child: SizedBox(
                height: 64,
              child: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16), 
                  color: Color.fromARGB(32, 128, 128, 128)
                ),
                child:Text(title ?? "untitled", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
              )
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
  // final period = tod.period == DayPeriod.am ? "AM" : "PM";
  return "$hour:$minute";
}
