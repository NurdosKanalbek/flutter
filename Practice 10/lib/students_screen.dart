import 'dart:async';

import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/student_list.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key, required this.api});

  final FakeApi api;

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<Student>? _students;
  Object? _error;
  bool _saving = false;

  FakeApi get _api => widget.api;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  void _startLoad() => unawaited(_load());

  Future<void> _load() async {
    setState(() {
      _students = null;
      _error = null;
    });
    try {
      final list = await _api.fetchStudents();
      if (!mounted) return;
      setState(() => _students = list);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    }
  }

  Future<void> _save() async {
    final students = _students;
    if (students == null || _saving) return;
    final currentContext = context;
    setState(() => _saving = true);
    try {
      await _api.save(students.length);
      if (!currentContext.mounted) return;
      Navigator.pop(currentContext);
    } on StateError catch (error) {
      if (!currentContext.mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(currentContext)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget body;
    if (_error != null) {
      body = ErrorView(onRetry: _startLoad);
    } else if (_students == null) {
      body = const LoadingView();
    } else if (_students!.isEmpty) {
      body = const EmptyView();
    } else {
      body = StudentList(students: _students!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Students · by hand'),
        actions: [
          IconButton(
            onPressed: _saving ? null : _startLoad,
            tooltip: 'Reload students',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: body,
      floatingActionButton: _students == null || _error != null
          ? null
          : FloatingActionButton(
              onPressed: _saving ? null : _save,
              tooltip: 'Save students',
              child: _saving
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
            ),
    );
  }
}
