import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tns_mobile_app/availability.dart';
import 'package:tns_mobile_app/models/teacher.dart';
import 'package:tns_mobile_app/network/api.dart';
import 'package:tns_mobile_app/weekday.dart';
import 'package:tns_mobile_app/widgets/infobar.dart';
import 'package:tns_mobile_app/widgets/schedule_item.dart';
import 'package:tns_mobile_app/models/school_class.dart';
import 'package:tns_mobile_app/models/schedule.dart';
import 'package:tns_mobile_app/constants.dart' as constants;
import 'package:tns_mobile_app/globals.dart' as globals;


class TNSRootPage extends StatefulWidget {
  final Teacher initialTeacher;

  const TNSRootPage({super.key, required this.initialTeacher});

  @override
  State<TNSRootPage> createState() => _TNSRootPageState();
}

class _TNSRootPageState extends State<TNSRootPage> with TickerProviderStateMixin {
  late PageController _pageViewController;
  late TabController _tabController;
  final GlobalKey _bottomBarBuilderKey = GlobalKey();

  bool _dndVacant = true;

  // Input Controllers
  late TextEditingController prefixTextController;
  late TextEditingController postfixTextController;
  late TextEditingController nameTextController;
  late TextEditingController subjectTextController;

  bool showLoading = true;
  int _selectedPageIndex = 0;

  int _cacheBusterssssssssssssss = 0;

  // Teacher Data
  late Teacher self;

  Map<int, Schedule> schedules = {};
  Map<int, SchoolClass> classes = {};

  Availability _availability = Availability.absent;

  WeekDay selectedDay = WeekDay.fromCode(DateTime.now().weekday - 1);

  late Stream<Map<String, dynamic>> _teacherStream;

  void _clearAllImageCache() {
    setState(() {
      imageCache.clear(); 
      imageCache.clearLiveImages(); 
    }); 
  }

  Future<XFile?> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    
    // Use .pickImage for pictures or .pickVideo for videos
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery, // Or ImageSource.camera
    );

    return file;
  }

  void showAvailabilityUntilPopup(BuildContext context) {
    TimeOfDay? untilTime;
    Availability? selectedAvailability;
    String? errorMessage;

    Future<void> pickTime() async {
      final now = TimeOfDay.now();
      final picked = await showTimePicker(
        context: context,
        initialTime: untilTime ?? now,
      );

      if (picked != null) {
      untilTime = picked;
    }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Set Availability"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                // Assuming this Column extension for spacing exists in your project.
                // If not, replace with default Column and add SizedBox between children.
                // For example: replace Column(spacing: 8, ...) with Column(..., children: [..., const SizedBox(height: 8), ...])
                // For simplicity, I'll use a standard Column with SizedBoxes.
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Display error message at the top if there is one
                  if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),

                  // ---- AVAILABILITY DROPDOWN ----
                  DropdownButtonFormField<Availability>(
                  decoration: const InputDecoration(
                    labelText: "Availability Status",
                    border: OutlineInputBorder(),
                  ),
                  value: selectedAvailability,
                  items: Availability.values
                  .map((a) => DropdownMenuItem(
                    value: a,
                    child: Text(a.label)
                  ))
                  .toList(),
                  onChanged: (v) => setState(() {
                    selectedAvailability = v;
                    errorMessage = null; // Clear error on change
                  }),
                ),

                  const SizedBox(height: 16),

                  // ---- UNTIL TIME PICKER ----
                  InkWell(
                    onTap: () async {
                      await pickTime();
                      setState(() {
                        errorMessage = null; // Clear error on change
                      });
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: "Until Time",
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        untilTime != null
                        ? untilTime!.format(context)
                        : "Select time",
                        style: untilTime == null ? const TextStyle(color: Colors.grey) : null,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () {
                // VALIDATION
                if (selectedAvailability == null || untilTime == null) {
                  setState(() {}); // <-- not needed for AlertDialog, but safe
                  errorMessage = "Please fill in all fields";
                  (context as Element).markNeedsBuild();
                  return;
                }

                forceAvailability(selectedAvailability!, untilTime!, self.token!);
                Navigator.pop(context);
              },
              child: const Text("Set"),
            ),
          ],
        );
      },
    );
  }

  void showPasswordChangePopup(BuildContext context) {
    TextEditingController oldPassInputController = TextEditingController();
    TextEditingController newPassInputController = TextEditingController();

    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Change Password"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                spacing: 8,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Old Password",
                      errorText: errorMessage
                    ),
                    controller: oldPassInputController
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: "New Password",
                    ),
                    controller: newPassInputController
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () {
                updateProfile(token: self.token as String, oldPassword: oldPassInputController.text, newPassword: newPassInputController.text).then((response){
                  setState(() {
                    if (response == null) {
                      setState(() {});
                      errorMessage = "Invalid";
                      (context as Element).markNeedsBuild();
                      return;
                    }
                    self.token = response["token"] as String;
                    Navigator.pop(context);
                  });
                });
                //
                // final scfMsgr = ScaffoldMessenger.of(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void showScheduleEditPopup(BuildContext context, int index) {
    WeekDay? selectedDay = schedules[index]?.weekday;
    TextEditingController subjectInputController = TextEditingController();
    SchoolClass? selectedClass = classes[schedules[index]?.classId];
    TimeOfDay? startTime = schedules[index]?.timeIn;
    TimeOfDay? endTime = schedules[index]?.timeOut;

    subjectInputController.text = schedules[index]?.subject ?? '';

    String? errorMessage;
    String? errorTimeInMessage;
    String? errorTimeOutMessage;

    Future<void> pickTime(bool isStart) async {
      final now = TimeOfDay.now();
      final picked = await showTimePicker(
        context: context,
        initialTime: (isStart ? startTime : endTime) ?? now,
      );

      if (picked != null) {
        if (isStart) {
          startTime = picked;
          if (endTime != null && picked.isAfter(endTime!)) {
            startTime = null;
            errorTimeInMessage = "Invalid Time";
          }
        } else {
          endTime = picked;
          if (startTime != null && startTime!.isAfter(picked)) {
            endTime = null;
            errorTimeOutMessage = "Invalid Time";
          }
        }
      } else {
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Edit Schedule"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                spacing: 8,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Subject",
                      errorText: errorMessage
                    ),
                    controller: subjectInputController
                  ),

                  // ---- DAY DROPDOWN ----
                  DropdownButtonFormField<WeekDay>(
                  decoration: InputDecoration(
                    labelText: "Day",
                    errorText: errorMessage
                  ),
                  initialValue: selectedDay,
                  items: WeekDay.values
                    .map((d) => DropdownMenuItem(value: d, child: Text(d.label)))
                    .toList(),
                  onChanged: (v) => setState(() => selectedDay = v),
                ),

                  const SizedBox(height: 12),

                  // ---- CLASS DROPDOWN ----
                  DropdownButtonFormField<SchoolClass>(
                    decoration: InputDecoration(
                      labelText: "Class",
                      errorText: errorMessage
                    ),
                    initialValue: selectedClass,
                    items: classes.values
                      .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                      .toList(),
                    onChanged: (v) => setState(() => selectedClass = v
                  ),
                ),

                  const SizedBox(height: 12),

                  // ---- START TIME ----
                  InkWell(
                    onTap: () async {
                      await pickTime(true);
                      setState(() {});
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Start Time",
                        border: OutlineInputBorder(),
                        errorText: errorTimeInMessage,
                      ),
                      child: Text(
                        startTime != null
                        ? startTime!.format(context)
                        : "Select time",
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ---- END TIME ----
                  InkWell(
                    onTap: () async {
                      await pickTime(false);
                      setState(() {});
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "End Time",
                        border: OutlineInputBorder(),
                        errorText: errorTimeOutMessage,
                      ),
                      child: Text(
                        endTime != null
                        ? endTime!.format(context)
                        : "Select time",
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: (){
                deleteSchedule(index, self.token ?? '');

                setState(() {
                  schedules.remove(index);
                });
                Navigator.pop(context);
              },
              child: const Text("Delete")
            ),
            FilledButton(
              onPressed: () {
                // VALIDATION → Show warning if something is missing
                if (selectedDay == null ||
                  selectedClass == null ||
                  startTime == null ||
                  endTime == null) {
                  setState(() {}); // <-- not needed for AlertDialog, but safe
                  errorMessage = "Please fill in all fields";
                  (context as Element).markNeedsBuild();
                  return;
                }

                Navigator.pop(context);

                Schedule sched = Schedule(
                  index, selectedClass?.id ?? 0, self.id, subjectInputController.text, selectedDay ?? WeekDay.monday, startTime ?? TimeOfDay.now(), endTime ?? TimeOfDay.now());

                final scfMsgr = ScaffoldMessenger.of(context);
                editSchedule(sched, self.token ?? '')
                .then((id){
                  if (id == null) {
                    scfMsgr.clearSnackBars();
                    scfMsgr.showSnackBar(
                      SnackBar(content: Text('Error occured..'))
                    );
                    return;
                  }

                  sched.id = id;

                  setState(() {
                    schedules[id] = sched;
                  });
                });
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void showScheduleAddPopup(BuildContext context) {
    WeekDay? selectedDay = this.selectedDay;
    TextEditingController subjectInputController = TextEditingController();
    SchoolClass? selectedClass;
    TimeOfDay? startTime;
    TimeOfDay? endTime;

    String? errorMessage;
    String? errorTimeInMessage;
    String? errorTimeOutMessage;

    Future<void> pickTime(bool isStart) async {
      final now = TimeOfDay.now();
      final picked = await showTimePicker(
        context: context,
        initialTime: (isStart ? startTime : endTime) ?? now,
      );

      if (picked != null) {
        if (isStart) {
          startTime = picked;
          if (endTime != null && picked.isAfter(endTime!)) {
            startTime = null;
            errorTimeInMessage = "Invalid Time";
          }
        } else {
          endTime = picked;
          if (startTime != null && startTime!.isAfter(picked)) {
            endTime = null;
            errorTimeOutMessage = "Invalid Time";
          }
        }
      } else {
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Add Schedule"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                spacing: 8,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Subject",
                      errorText: errorMessage
                    ),
                    controller: subjectInputController
                  ),

                  // ---- DAY DROPDOWN ----
                  DropdownButtonFormField<WeekDay>(
                  decoration: InputDecoration(
                    labelText: "Day",
                    errorText: errorMessage
                  ),
                  initialValue: selectedDay,
                  items: WeekDay.values
                    .map((d) => DropdownMenuItem(value: d, child: Text(d.label)))
                    .toList(),
                  onChanged: (v) => setState(() => selectedDay = v),
                ),

                  const SizedBox(height: 12),

                  // ---- CLASS DROPDOWN ----
                  DropdownButtonFormField<SchoolClass>(
                    decoration: InputDecoration(
                      labelText: "Class",
                      errorText: errorMessage
                    ),
                    initialValue: selectedClass,
                    items: classes.values
                      .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                      .toList(),
                    onChanged: (v) => setState(() => selectedClass = v
                  ),
                ),

                  const SizedBox(height: 12),

                  // ---- START TIME ----
                  InkWell(
                    onTap: () async {
                      errorTimeInMessage = null;
                      await pickTime(true);
                      setState(() {});
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Start Time",
                        border: OutlineInputBorder(),
                        errorText: errorTimeInMessage,
                      ),
                      child: Text(
                        startTime != null
                        ? startTime!.format(context)
                        : "Select time",
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ---- END TIME ----
                  InkWell(
                    onTap: () async {
                      await pickTime(false);
                      setState(() {});
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "End Time",
                        border: OutlineInputBorder(),
                        errorText: errorTimeOutMessage,
                      ),
                      child: Text(
                        endTime != null
                        ? endTime!.format(context)
                        : "Select time",
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () {
                // VALIDATION → Show warning if something is missing
                errorMessage = null;
                if (selectedDay == null || selectedClass == null || startTime == null || endTime == null) {
                  setState(() {});
                  errorMessage = "Please fill in all fields";
                  (context as Element).markNeedsBuild();
                  return;
                }
                Navigator.pop(context);

                Schedule sched = Schedule(
                  0, 
                  selectedClass?.id ?? 0, 
                  self.id,
                  subjectInputController.text, 
                  selectedDay ?? WeekDay.monday, 
                  startTime ?? TimeOfDay.now(), 
                  endTime ?? TimeOfDay.now()
                );

                final scfMsgr = ScaffoldMessenger.of(context);
                createSchedule(sched, self.token ?? '')
                .then((id){
                  if (id == null) {
                    scfMsgr.clearSnackBars();
                    scfMsgr.showSnackBar(
                      SnackBar(content: Text('Error occured..'))
                    );
                    return;
                  }

                  sched.id = id;

                  setState(() {
                    schedules[id] = sched;
                  });
                });
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> loadState() async {
    final clss = await getClassesList();
    final schds = await getTeacherSchedules(self.id);

    setState((){
      classes.addAll({
        for (final c in clss) c.id: c
      });
      schedules.addAll({
        for (final s in schds) s.id: s
      });
      showLoading = false;
    });
  }

  bool _isDialogShowing = false;

  void _showEventDialog(String tabletSession) {
    if (_isDialogShowing) return;

    TextEditingController messageController = TextEditingController();

    _isDialogShowing = true;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Notification"),
        content: Column(
          spacing: 16,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("A person is calling you from the TNS Kiosk.", textAlign: TextAlign.start),
            SizedBox(
              width: double.infinity,
              child: TextField(
                controller: messageController,
                maxLines: null,
                minLines: 5,
                decoration: InputDecoration(
                  hintText: "Response",
                  border: OutlineInputBorder(),
                ),
              )
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.pop(context);
            }, 
            child: const Text("Ignore")
          ),
          FilledButton(
            onPressed: (){
              Navigator.pop(context);
              respond(messageController.text, tabletSession, self.token!);
            }, 
            child: const Text("Respond")
          )
        ],
      ),
    ).then((_) => _isDialogShowing = false); // Reset when closed
  }

  @override void initState() {
    super.initState();
    _pageViewController = PageController();
    _tabController = TabController(length: 3, vsync: this);

    loadState();

    nameTextController = TextEditingController();
    prefixTextController = TextEditingController();
    postfixTextController = TextEditingController();
    subjectTextController = TextEditingController();

    self = widget.initialTeacher;

    nameTextController.text = self.name;
    prefixTextController.text = self.prefix ?? '';
    postfixTextController.text = self.suffix ?? '';
    subjectTextController.text = self.subject ?? '';

    _pageViewController.addListener((){
      if (_bottomBarBuilderKey.currentState != null) {
        _bottomBarBuilderKey.currentState!.setState((){
          _selectedPageIndex = _tabController.index = (_pageViewController.page?.round() ?? 0);
        });
      }
    });

    _teacherStream = listenToTeacherEvents(self.token!);
    _teacherStream.listen((data) {
      _showEventDialog(data["tablet_session"]);
    });

    getTeacherPrefs(self.token!).then((d){
      _dndVacant = d!["dnd_vacant"];
    });
    // SharedPreferences.getInstance().then((v){
    //   prefs = v;
    //
    //   if (!prefs.containsKey("dndVacant")) {
    //     prefs.setBool("dndVacant", true);
    //   } else {
    //     _dndVacant = prefs.getBool("dndVacant")!;
    //   }
    // });
  }

  @override void dispose() {
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

  @override Widget build(BuildContext context) {
    final sortedSchedules = schedules.values.toList();
    sortedSchedules.sort((a,b) => a.timeIn.compareTo(b.timeIn));

    // Home Page
    final quickSettings = Column(
      spacing: 16,
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                spacing: 8,
                children: [
                  Icon(Icons.person, size: 32,),
                  const Text("Availability"),
                ],
              )
            ),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<Availability>(
                decoration: InputDecoration(),
                initialValue: _availability,
                items: Availability.values.map((d) => DropdownMenuItem(value: d, child: Text(d.label))).toList(),
                onChanged: (v) => setState(() {
                  _availability = v ?? Availability.absent;
                }),
              )
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => showAvailabilityUntilPopup(context),
            child: Padding( 
              padding: EdgeInsets.all(16),
              child: const Text("Set Availability Until")
            )
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _availability != Availability.absent ? null : (){
              setState(() {
                _availability = Availability.available;
              });
            }, 
            child: Padding( 
              padding: EdgeInsets.all(16),
              child: Text(_availability != Availability.absent ? "Already Checked In" : "Check In")
            )
          ),
        ),
      ],
    );

    final lsVwChildren = [ for (Schedule i in sortedSchedules) 
      if (TimeOfDay.now().isBefore(i.timeOut))
      Padding(
        padding: EdgeInsetsGeometry.only(bottom: 8), 
        child: ScheduleItem(
          start: i.timeIn,
          end: i.timeOut,
          className: classes[i.classId]?.name ?? '',
          subject: i.subject,
          weekday: i.weekday,
        )
      ) 
    ];

    final classesList = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: double.infinity,
        height: 256,
        child: Stack(
          children: [

            // Scrollable List
            ListView(
              shrinkWrap: true,
              children: lsVwChildren,
            ),

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

    final homePage = SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column (
        spacing: 8,
        children: [
          quickSettings,
          const SizedBox(height: 32,),
          if (lsVwChildren.isNotEmpty) const Text(
            'Next Classes'
          )

          else const Text(
            "Woohoo! You have no upcoming classes", 
            style: TextStyle(fontStyle: FontStyle.italic
            ),
          ),
          classesList
        ],
      )
    );

    // Schedule Page
    final schedPage = SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        spacing: 16,
        children: [
          Row(
            children: [ for (final w in WeekDay.values)
              Expanded(
                child: w == selectedDay ? FilledButton(
                  onPressed: (){
                    setState((){
                      selectedDay = w;
                    });
                  }, 
                  child: Text(w.label.substring(0, 3))
                ) : TextButton(
                  onPressed: (){
                    setState((){
                      selectedDay = w;
                    });
                  }, 
                  child: Text(w.label.substring(0, 3))
                ),
              )
            ],
          ),
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ListView(
                    shrinkWrap: true,
                    children: (sortedSchedules.isEmpty) ? [ Center(
                      child: const Text(
                        "Woohoo! You have no upcoming classes", 
                        style: TextStyle(fontStyle: FontStyle.italic,
                        ),
                      ),
                    )] : [ for (Schedule i in sortedSchedules)
                      if (i.weekday == selectedDay)
                      Padding(
                        padding: EdgeInsetsGeometry.only(bottom: 8), 
                        child: Ink(
                          child: InkWell( 
                            splashColor: Colors.blue,
                            onTap: () {
                              showScheduleEditPopup(context, i.id);
                            },
                            child: Stack(
                              fit: StackFit.loose,
                              children: [
                                ScheduleItem(
                                  start: i.timeIn,
                                  end: i.timeOut,
                                  className: classes[i.classId]?.name ?? '',
                                  subject: i.subject,
                                  weekday: i.weekday,
                                ),
                                Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: Padding( 
                                      padding: EdgeInsetsGeometry.all(16),
                                      child: Icon(
                                        Icons.edit,
                                      )
                                    )
                                  )
                                )
                              ],
                            )
                          )
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                  bottom: 1,
                  right: 1,
                  child: FilledButton(
                    onPressed: () { showScheduleAddPopup(context); }, 
                    child: const Padding(
                      padding: EdgeInsetsGeometry.symmetric(vertical: 16, horizontal: 32),
                      child: Text("+ Add New")
                    )
                  ),
                )
              ],
            )
          ),
        ],
      )
    );

    // Settings Page
    final profilePage = SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        spacing: 16,
        children: [
          Row (
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 32,
            children: [
              // Preview
              Expanded(
                flex: 1,
                child: InkWell(
                  onTap: () {
                    _pickImage().then((f){
                      if (f == null) return;
                      uploadProfilePicture(f, self.token!).then((_){
                        Future.delayed(Duration(milliseconds: 250)).then((_){
                          setState(() {
                            _cacheBusterssssssssssssss++;
                          });
                        });
                      });
                      
                    });                    
                  },

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: AspectRatio(
                        aspectRatio: 2/3,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(
                              color: Theme.of(context).colorScheme.surface
                            ),
                            Positioned.fill(
                              child: Opacity(
                                opacity: _availability == Availability.available ? 1 : constants.opacityUnavailable,
                                child: Image(
                                  image: NetworkImage('${globals.baseURL}/api/profilePicture/${self.id}?a=$_cacheBusterssssssssssssss'),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.broken_image, size: 64, color: Theme.of(context).colorScheme.onSurface);
                                  },
                                )
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(16),
                              alignment: Alignment.bottomLeft,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.center,
                                  colors: [
                                    Theme.of(context).colorScheme.surfaceContainerHigh,
                                    Theme.of(context).colorScheme.surfaceContainerHigh.withAlpha(0),
                                  ]
                                )
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    self.name, 
                                    textScaler: TextScaler.linear(constants.phi), 
                                    style: TextStyle(
                                      color: _availability == Availability.available ? 
                                      Theme.of(context).colorScheme.onSurface :
                                      Theme.of(context).colorScheme.onSurface.withAlpha(128)
                                    ),
                                  ),
                                  Text(_availability.label,
                                    style: TextStyle(
                                      color: _availability == Availability.available ? 
                                      Colors.green :
                                      Colors.red,
                                      fontWeight: FontWeight.bold
                                    )
                                  ),
                                ],
                              )
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: EdgeInsetsGeometry.all(8),
                                child: Icon(
                                  Icons.edit,
                                )
                              ),
                            )
                          ],
                        ),
                      )
                    )
                  )
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 32,
                  children: [
                    Row(
                      spacing: 16,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: prefixTextController,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'Prefix',
                            ), 
                          )
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: postfixTextController,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'Suffix',
                            ), 
                          )
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: nameTextController,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Full Name',
                        icon: Icon(Icons.perm_identity)
                      ), 
                    ),
                    TextFormField(
                      controller: subjectTextController,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Subject',
                        icon: Icon(Icons.subject)
                      ), 
                    ),
                    Row(
                      children: [
                        Expanded(child: const Text("Turn-on DND while vacant")),
                        Switch(
                          onChanged: (value) {
                            setTeacherPrefs(self.token!, dndVacant: value);
                            setState((){
                              _dndVacant = value;
                            });
                          },
                          value: _dndVacant,
                        ),
                      ],
                    )
                  ],
                )
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => showPasswordChangePopup(context), 
              child: Padding( 
                padding: EdgeInsets.all(16),
                child: Text("Change Password")
              )
            )
          ),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: (){
                updateProfile(
                  token: self.token ?? '',
                  fullName: nameTextController.text, 
                  prefix: prefixTextController.text,
                  suffix: postfixTextController.text, 
                  mainSubject: subjectTextController.text
                ).then((response){
                  if (response != null) {
                    setState(() {
                      self.name = nameTextController.text;
                      self.prefix = prefixTextController.text;
                      self.suffix = postfixTextController.text;
                      self.subject = subjectTextController.text;
                    });
                  }
                });
              }, 
              child: Padding( 
                padding: EdgeInsets.all(16),
                child: Text("Save Changes")
              )
            ),
          ),
        ],
      )
    );

    // Main / Root
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(96),
          child: InformationBar(
            name: self.name,
            prefix: self.prefix,
            postfix: self.suffix,
            subject: self.subject.toString(),
            availability: _availability,
          ),
        ),
      ),

      body: Stack(
        children: [
          PageView(
            controller: _pageViewController,
            children: [
              homePage,
              schedPage,
              profilePage
            ],
          ),

          if (showLoading)
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
        ]
      ),

      bottomNavigationBar: StatefulBuilder(
        key: _bottomBarBuilderKey,
        builder: (ctx, innerSetState) {
        return SalomonBottomBar(
          margin: EdgeInsets.symmetric(vertical: 16, horizontal: 32),

          currentIndex: _selectedPageIndex,
          onTap: (index) {
            innerSetState(() {
              _tabController.index = index;
              _selectedPageIndex = index;
              _updateCurrentPageIndex(index);
            });
          },
          items: _destinations,
        );
      }),
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
    icon: const Icon(Icons.settings),
    title: const Text("Settings"),
    selectedColor: Colors.teal
  ),
];
