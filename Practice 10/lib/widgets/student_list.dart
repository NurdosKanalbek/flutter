import 'package:flutter/material.dart';

import '../api/fake_api.dart';

class StudentList extends StatelessWidget {
  const StudentList({super.key, required this.students, this.compact = false});

  final List<Student> students;
  final bool compact;

  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
    itemCount: students.length,
    itemBuilder: (context, index) {
      final student = students[index];
      return Card(
        child: ListTile(
          dense: compact,
          leading: CircleAvatar(child: Text(student.name.substring(0, 1))),
          title: Text(student.name),
          subtitle: Text(student.group),
          trailing: Text(
            student.gpa?.toStringAsFixed(1) ?? '—',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
    },
  );
}
