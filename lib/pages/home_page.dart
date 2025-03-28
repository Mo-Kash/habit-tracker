import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/components/habit_tile.dart';
import 'package:habit_tracker/components/my_heat_map.dart';
import 'package:habit_tracker/components/my_drawer.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/util/habit_utilities.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState(){
    //read existing habits on app startup
    Provider.of<HabitDatabase>(context, listen: false).readHabits();

    super.initState();
  }

  final TextEditingController textController = TextEditingController();

  void createNewHabit(){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: "Add a new habit",
              hintStyle: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic
              )
            ),
          ),
          actions: [
            MaterialButton(
              onPressed: (){
                String newHabitName = textController.text;
                context.read<HabitDatabase>().addHabit(newHabitName);
                Navigator.pop(context);
                textController.clear();
              },
              child: const Text("Save"),
            ),
            MaterialButton(
              onPressed: (){
                Navigator.pop(context);
                textController.clear();
              },
              child: const Text("Cancel"),
            ),
          ],
        )
    );
  }

  void checkHabitOnOff(bool? value, Habit habit){
    if(value!=null){
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  void editHabitBox(Habit habit){
    textController.text = habit.name;
    showDialog(
        context: context,
        builder: (context)=>AlertDialog(
          content: TextField(
            controller: textController,
          ),
          actions: [
            MaterialButton(
              onPressed: (){
                String newHabitName = textController.text;
                context.read<HabitDatabase>().updateHabitName(habit.id, newHabitName);
                Navigator.pop(context);
                textController.clear();
              },
              child: const Text("Save"),
            ),
            MaterialButton(
              onPressed: (){
                Navigator.pop(context);
                textController.clear();
              },
              child: const Text("Cancel"),
            ),
          ],
        )
    );
  }

  void deleteHabitBox(Habit habit){
    showDialog(
        context: context,
        builder: (context)=>AlertDialog(
          title: Text("Delete Habit?"),
          actions: [
            MaterialButton(
              onPressed: (){
                context.read<HabitDatabase>().deleteHabit(habit.id);
                Navigator.pop(context);
              },
              child: const Text("Yes"),
            ),
            MaterialButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: const Text("No"),
            ),
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daily Habit Tracker"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),

      ),
      body: ListView(
        children: [
          _buildHeatMapCalendar(),
          _buildHabitList()
        ],
      ),
    );
  }

  Widget _buildHabitList(){
    final habitDatabase = context.watch<HabitDatabase>();
    List<Habit> currentHabits = habitDatabase.currentHabits;
    
    return ListView.builder(
      itemCount: currentHabits.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index){
        final habit = currentHabits[index];

        bool isCompletedToday = isHabitCompletedToday(habit.completedDays);

        return HabitTile(
          text: habit.name,
          isCompleted: isCompletedToday,
          onChanged: (value)=>checkHabitOnOff(value, habit),
          editHabit: (context)=>editHabitBox(habit),
          deleteHabit: (context)=>deleteHabitBox(habit),
        );
      }
    );
  }

  Widget _buildHeatMapCalendar(){
    final habitDatabase = context.watch<HabitDatabase>();
    List<Habit> currentHabits = habitDatabase.currentHabits;
    
    return FutureBuilder(
        future: habitDatabase.getFirstLaunchDate(),
        builder: (context, snapshot){
          if(snapshot.hasData){
            return MyHeatMap(
                startDate: snapshot.data!,
                datasets: prepHeatMapDataset(currentHabits),
            );
          }else{
            return Container();
          }
        }
    );
  }
}
