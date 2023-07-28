import 'package:hive/hive.dart';
part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String? name;
  @HiveField(1)
  bool? isDone;
  @HiveField(2)
  DateTime? dateTime;
  @HiveField(3)
  int? id;
  @HiveField(4)
  bool? isRepeat;
  Task({this.name, this.isDone = false, this.dateTime, this.id, this.isRepeat});

  void toggleDone() {
    isDone = !isDone!;
  }
}
