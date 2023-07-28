import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:todoist_hive/widgets/task_tile.dart';
import '../main.dart';
import '../model/task.dart';
import '../model/task_data.dart';
import '../screens/update_task_screen.dart';
import 'package:timezone/timezone.dart' as tz;

class TaskList extends StatelessWidget {
  const TaskList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Task>>(
        valueListenable: TaskData.getTasks().listenable(),
        builder: (context, box, _) {
          final tasks = box.values.toList().cast<Task>();
          return buildContent(tasks);
        });
  }
}
void scheduleNotification(
    {required tz.TZDateTime scheduledNotificationDateTime,
      required String text,
      required int id,
      required bool isRepeat}) async {
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
  isRepeat ? await flutterLocalNotificationsPlugin.zonedSchedule(id, 'ToDoIst', text,
    tz.TZDateTime.from(scheduledNotificationDateTime, tz.local),
    platformChannelSpecifics,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
    androidAllowWhileIdle: true,
  )
      : await flutterLocalNotificationsPlugin.zonedSchedule(id, 'ToDoIst', text,
    tz.TZDateTime.from(scheduledNotificationDateTime, tz.local),
    platformChannelSpecifics,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
  );
}


void delete(BuildContext context, Task task, int index) {
  const snackBar = SnackBar(
    backgroundColor: Colors.red,
    duration: Duration(milliseconds: 500),
    content: Text('Task deleted successfully'),
  );
  showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text(
            'Confirm Delete',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          content: const Text(
            'Are you sure to delete this task?',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.lightBlueAccent),
          ),
          actions: [
            TextButton(
                onPressed: () async {
                  Provider.of<TaskData>(context, listen: false)
                      .deleteTask(task);
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  Navigator.of(context).pop();
                  await flutterLocalNotificationsPlugin.cancel(index);
                },
                child: const Text(
                  'Yes',
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                )),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'No',
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ))
          ],
        );
      });
}

Future<TimeOfDay?> pickTime(BuildContext context) async {
  final initialTime =
  TimeOfDay.fromDateTime(DateTime.now().add(const Duration(minutes: 2)));
  final newTime = await showTimePicker(
    context: context,
    initialTime: initialTime,
  );

  if (newTime == null) return null;

  return newTime;
}

Widget buildContent(List<Task> tasks) {
  const snackBar = SnackBar(
    backgroundColor: Colors.green,
    duration: Duration(seconds: 2),
    content: Text('Task completed successfully'),
  );
  if (tasks.isEmpty) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            const Text(
              'No Tasks to show',
              style: TextStyle(
                  color: Colors.lightBlueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 24),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 300,
              width: 300,
              child: Image.asset('assets/image/waiting.png'),
            )
          ],
        ),
      ),
    );
  } else {
    return Consumer<TaskData>(
      builder: (context, box, child) {
        return ListView.builder(
          itemBuilder: (context, index) {
            final task = tasks[index];
            final id = task.id;
            return TaskTile(
              updateTask: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => UpdateTaskScreen(
                    dateTime: task.dateTime!,
                    taskName: task.name!,
                    task: task,
                    isRepeat: task.isRepeat!,
                    id: task.id!,
                  ),
                );
              },
              deleteItem: () {
                delete(context, task, id!);
              },
              taskTitle: task.name,
              isChecked: task.isDone,
              dateTime: task.dateTime,
              checkboxCallBack: (checkboxState) async{
                if (task.isDone == false) {
                  debugPrint("task.isDone = false ${task.isDone.toString()}");
                  await flutterLocalNotificationsPlugin.cancel(task.id!);
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }else{
                  final time = await pickTime(context);
                  final finalTime = time!=null? DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,time.hour,time.minute):DateTime.now().add(const Duration(minutes: 2));
                  var localTime = tz.TZDateTime.from(
                    finalTime,
                    tz.local,
                  );
                  debugPrint("task.isDone ${task.isDone.toString()}");
                  scheduleNotification(
                      id:task.id!,
                      text:task.name!,
                      isRepeat:task.isRepeat!,
                      scheduledNotificationDateTime:localTime);
                  Provider.of<TaskData>(context, listen: false)
                      .updateTask(task, task.name!, finalTime, task.id!, task.isRepeat!);
                }
                TaskData().updateCheckBox(task);
              },
            );
          },
          itemCount: TaskData().taskCount,
        );
      },
    );
  }
}
