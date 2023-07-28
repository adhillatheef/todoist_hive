import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskTile extends StatelessWidget {
  bool? isChecked = false;
  String? taskTitle;
  DateTime? dateTime;
  Function(bool?) checkboxCallBack;
  Function()? deleteItem;
  Function()? updateTask;
  TaskTile(
      {Key? key,
      this.isChecked,
      this.taskTitle,
      this.dateTime,
      required this.checkboxCallBack,
      this.deleteItem,
      this.updateTask})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: updateTask,
      title: Text(
        taskTitle!,
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            decoration: isChecked! ? TextDecoration.lineThrough : null),
      ),
      subtitle: Text(
        DateFormat('h:mm a MMM d').format(dateTime!),
        style: const TextStyle(
            fontWeight: FontWeight.bold, color: Colors.lightBlueAccent),
      ),
      leading: Transform.scale(
        scale: 1.3,
        child: Checkbox(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          activeColor: Colors.green,
          onChanged: checkboxCallBack,
          value: isChecked,
        ),
      ),
      trailing: IconButton(
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
            size: 25,
          ),
          onPressed: deleteItem),
    );
  }
}
