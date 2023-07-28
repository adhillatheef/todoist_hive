import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../model/task.dart';
import '../model/task_data.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class UpdateTaskScreen extends StatefulWidget {
  final int id;
  final String taskName;
  DateTime dateTime;
  bool isRepeat;
  final Task task;
  UpdateTaskScreen(
      {Key? key,
      required this.id,
      required this.taskName,
      required this.isRepeat,
      required this.dateTime,
      required this.task})
      : super(key: key);

  @override
  State<UpdateTaskScreen> createState() => _UpdateTaskScreenState();
}

class _UpdateTaskScreenState extends State<UpdateTaskScreen> {
  final textController = TextEditingController();
  DateTime? dateTime;

  @override
  void initState() {
    super.initState();
    dateTime = widget.dateTime;
    textController.text = widget.taskName;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        color: const Color(0xFF757575),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              const Text(
                'Update Task',
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.lightBlueAccent,
                    fontWeight: FontWeight.bold),
              ),
              TextField(
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                decoration: const InputDecoration(
                    border: InputBorder.none, hintText: 'Eg: Buy Milk'),
                controller: textController,
                autofocus: true,
              ),
              Row(
                children: [
                  const Text(
                    'Repeat Alert',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  Switch(
                    value: widget.isRepeat,
                    onChanged: (value) {
                      setState(() {
                        widget.isRepeat = value;
                      });
                    },
                    activeTrackColor: Colors.lightBlueAccent,
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      onPressed: () {
                        pickDateTime(context);
                      },
                      child: Text(
                        dateTime == null
                            ? 'Choose Date & Time'
                            : DateFormat('h:mm a dd/MM/yyyy').format(dateTime!),
                        style: const TextStyle(
                            color: Colors.lightBlueAccent,
                            fontWeight: FontWeight.bold),
                      )),
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Colors.lightBlueAccent)),
                      onPressed: () {
                        submitData(
                            widget.id, textController.text, widget.isRepeat);
                      },
                      child: const Text(
                        'UPDATE TASK',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  submitData(int id, String taskName, bool isRepeat) {
    if (taskName.isEmpty || dateTime == null) {
      taskName.isEmpty
          ? _showMyDialog('Please enter a task')
          : _showMyDialog('Please pick a date and time');
    } else {
      Provider.of<TaskData>(context, listen: false)
          .updateTask(widget.task, taskName, dateTime!, id, isRepeat);
      var time = tz.TZDateTime.from(
        dateTime!,
        tz.local,
      );
      scheduleNotification(time, taskName, id, isRepeat);
      Navigator.pop(context);
    }
  }

  Future<void> _showMyDialog(String text) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Alert',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  text,
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Ok',
                style: TextStyle(
                    color: Colors.lightBlueAccent, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future pickDateTime(BuildContext context) async {
    final date = await pickDate();
    if (date == null) return;
    final time = await pickTime();
    if (time == null) return;

    setState(() {
      dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<DateTime?> pickDate() async {
    final initialDate = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: dateTime ?? initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 0)),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (newDate == null) return null;

    return newDate;
  }

  Future<TimeOfDay?> pickTime() async {
    final initialTime =
        TimeOfDay.fromDateTime(DateTime.now().add(const Duration(minutes: 2)));
    final newTime = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay(hour: initialTime.hour, minute: initialTime.minute),
    );

    if (newTime == null) return null;

    return newTime;
  }

  void scheduleNotification(tz.TZDateTime scheduledNotificationDateTime,
      String text, int id, bool isRepeat) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'task_notify',
      'task_notify',
      channelDescription: 'Channel for Task notification',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'todo',
      playSound: true,
      sound: RawResourceAndroidNotificationSound('correct'),
      largeIcon: DrawableResourceAndroidBitmap('todo'),
      enableVibration: true,
      visibility: NotificationVisibility.public,
      showWhen: true,
      enableLights: true,
    );

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    isRepeat
        ? await flutterLocalNotificationsPlugin.zonedSchedule(
            id,
            'ToDoIst',
            text,
            tz.TZDateTime.from(scheduledNotificationDateTime, tz.local),
            platformChannelSpecifics,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time,
            androidAllowWhileIdle: true,
          )
        : await flutterLocalNotificationsPlugin.zonedSchedule(
            id,
            'ToDoIst',
            text,
            tz.TZDateTime.from(scheduledNotificationDateTime, tz.local),
            platformChannelSpecifics,
            androidAllowWhileIdle: true,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
  }
}
