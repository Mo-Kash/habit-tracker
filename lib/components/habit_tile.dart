import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HabitTile extends StatelessWidget {
  final bool isCompleted;
  final String text;
  final void Function(bool?)? onChanged;
  final void Function(BuildContext)? editHabit;
  final void Function(BuildContext)? deleteHabit;
  const HabitTile({
    super.key,
    required this.text,
    required this.isCompleted,
    required this.onChanged,
    required this.editHabit,
    required this.deleteHabit
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
      child: Slidable(
        endActionPane: ActionPane(
            motion: const StretchMotion(),
            children: [
              SlidableAction(
                onPressed: editHabit,
                backgroundColor: Colors.grey.shade800,
                icon: Icons.edit,
                borderRadius: BorderRadius.circular(12),
              ),
              SlidableAction(
                onPressed: deleteHabit,
                backgroundColor: Colors.red.shade400,
                icon: Icons.delete,
                borderRadius: BorderRadius.circular(12),
              )
            ]
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.green
                : Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(12)
          ),
          padding: const EdgeInsets.all(15),
          child: ListTile(
            title: Text(
                text,
              style: TextStyle(
                color: isCompleted
                    ?Theme.of(context).colorScheme.secondary
                    :Theme.of(context).colorScheme.inversePrimary
              ),
            ),
            leading: Checkbox(
              activeColor: Colors.green,
              value: isCompleted,
              onChanged: onChanged
            ),
          ),
        ),
      ),
    );
  }
}
