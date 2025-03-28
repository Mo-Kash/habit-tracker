// given a habit list of completion days,
// is the habit completed today?

import 'package:habit_tracker/models/habit.dart';

bool isHabitCompletedToday(List<DateTime>  completedDays){
  final today = DateTime.now();
  return completedDays.any((date)=>
      date.year == today.year &&
      date.month == today.month &&
      date.day == today.day
  );
}

//prepare heatmap dataset
Map<DateTime, int>prepHeatMapDataset(List<Habit> habits){
  Map<DateTime,int> dataset = {};
  for(var habit in habits){
    for(var date in habit.completedDays){
      final normalizeDate = DateTime(date.year, date.month, date.day);

      if(dataset.containsKey(normalizeDate)){
        dataset[normalizeDate] = dataset[normalizeDate]! + 1;
      }else{
        dataset[normalizeDate] = 1;
      }
    }
  }

  return dataset;
}