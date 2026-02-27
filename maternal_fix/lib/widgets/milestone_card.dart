import 'package:flutter/material.dart';

class MilestoneCard extends StatelessWidget {
  final String title;
  final String date;
  final bool isCompleted;

  const MilestoneCard({
    super.key,
    required this.title,
    required this.date,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isCompleted ? Colors.green : Colors.grey,
        ),
        title: Text(title),
        subtitle: Text(date),
      ),
    );
  }
}
