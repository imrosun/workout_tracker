import 'package:flutter/material.dart';
import 'package:workout_tracker/pages/exercise_detail_page.dart';
import 'package:workout_tracker/models/workout_data.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      appBar: AppBar(
        title: Text('Workouts', style: TextStyle(color: textColor)),
      ),
      body: ListView.builder(
        itemCount: workouts.length,
        itemBuilder: (context, index) {
          final workout = workouts[index];
          return Card(
            margin: EdgeInsets.all(12),
            child: ListTile(
              leading: Image.asset(workout['image'], width: 60, height: 60),
              title: Text(workout['name'], style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExerciseDetailPage(workout: workout),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
