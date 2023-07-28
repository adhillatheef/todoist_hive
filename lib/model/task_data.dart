import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todoist_hive/model/task.dart';

class TaskData extends ChangeNotifier {
  static Box<Task> getTasks() => Hive.box('tasks');
  int get taskCount {
    return getTasks().length;
  }

  addTask(
      String newTask, DateTime newDateTime, int newId, bool isRepeat) async {
    final task = Task(
        name: newTask, dateTime: newDateTime, id: newId, isRepeat: isRepeat);
    final box = getTasks();
    box.add(task);
    notifyListeners();
  }

  updateCheckBox(Task task) {
    task.toggleDone();
    task.save();
    notifyListeners();
  }

  updateTask(
      Task task, String taskName, DateTime dateTime, int id, bool isRepeat) {
    task.id = id;
    task.name = taskName;
    task.dateTime = dateTime;
    task.isRepeat = isRepeat;
    task.save();
  }

  deleteTask(Task task) {
    task.delete();
    notifyListeners();
  }
}
