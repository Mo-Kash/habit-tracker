import 'package:flutter/material.dart';
import 'package:habit_tracker/models/app_settings.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier{
  static late Isar isar;

  // S E T U P
  //initialize database
  static Future<void> initialize() async{
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
        [HabitSchema, AppSettingsSchema],
        directory: dir.path);
  }

  //save first date of app startup (for heatmap)
  Future<void> saveFirstLaunchDate() async{
    final existingSettings = await isar.appSettings.where().findFirst();
    if(existingSettings==null){
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(()=>isar.appSettings.put(settings));
    }
  }

  //get first date of app startup (for heatmap)
  Future<DateTime?> getFirstLaunchDate() async{
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

  // C R U D
  //List of habits
  final List<Habit> currentHabits = [];

  //Create - add a new habit
  Future<void> addHabit(String habitName) async{
    //create new habit
    final newHabit = Habit()..name = habitName;

    //save to db
    await isar.writeTxn(()=>isar.habits.put(newHabit));

    //re read from database
    readHabits();
  }

  //Read - read saved habits from db
  Future<void> readHabits() async{
    //fetch all habits from db
    List<Habit> fetchedHabits = await isar.habits.where().findAll();
    //give to current habits
    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);
    //update UI
    notifyListeners();
  }

  //Update - toggle completion of habit
  Future<void> updateHabitCompletion(int id, bool isCompleted) async{
    //find habit
    final habit = await isar.habits.get(id);
    //update status
    if(habit!=null){
      await isar.writeTxn(()async{
        //if completed, add current date to completed days list
        if(isCompleted && !habit.completedDays.contains(DateTime.now())){
          final today = DateTime.now();
          habit.completedDays.add(
            DateTime(
              today.year,
              today.month,
              today.day
            )
          );
        }
        //if habit is not completed, remove from completedDays list
        else{
          habit.completedDays.removeWhere((date)=>
              date.year==DateTime.now().year &&
              date.month==DateTime.now().month &&
              date.day == DateTime.now().day
          );
        }

        //save updated back to db
        await isar.habits.put(habit);
      });
    }

    //re read from db
    readHabits();
  }

  //Update - edit habit name
  Future<void> updateHabitName(int id, String newName) async{
    final habit = await isar.habits.get(id);

    if(habit!=null){
      habit.name = newName;
      await isar.writeTxn(() async{
        await isar.habits.put(habit);
      });
    }

    readHabits();
  }

  //Delete - remove habit
  Future<void> deleteHabit(int id) async{
      await isar.writeTxn(() async{
        await isar.habits.delete(id);
      });
      readHabits();
  }
}