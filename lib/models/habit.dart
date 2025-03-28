import 'package:isar/isar.dart';

part 'habit.g.dart'; //g=generate

@Collection()
class Habit{
  Id id = Isar.autoIncrement;

  late String name;

  List<DateTime> completedDays = [
    //DateTime(year, month, day)
  ];
}