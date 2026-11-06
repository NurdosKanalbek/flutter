import 'package:flutter/foundation.dart';

class Student {
  const Student({required this.name, required this.group, this.gpa});

  final String name;
  final String group;
  final double? gpa;
}

class NoConnectionException implements Exception {
  const NoConnectionException();
}

const _seed = [
  Student(name: 'Aida Nurlanova', group: 'IT-2301', gpa: 3.7),
  Student(name: 'Dias Seitkali', group: 'IT-2301', gpa: 3.1),
  Student(name: 'Aruzhan Bek', group: 'IT-2302'),
  Student(name: 'Timur Alibekov', group: 'IT-2302', gpa: 2.9),
  Student(name: 'Dana Omarova', group: 'IT-2303', gpa: 3.9),
  Student(name: 'Alikhan Kairatuly', group: 'IT-2303', gpa: 3.4),
];

class FakeApi {
  FakeApi({this.empty = false});

  final bool empty;
  int calls = 0;
  int saveCalls = 0;

  Future<List<Student>> fetchStudents() async {
    calls++;
    final call = calls;
    debugPrint('fetchStudents #$call');
    await Future<void>.delayed(const Duration(seconds: 2));
    if (call % 3 == 0) throw const NoConnectionException();
    return empty ? const [] : _seed;
  }

  Future<void> save(int value) async {
    saveCalls++;
    final call = saveCalls;
    await Future<void>.delayed(const Duration(seconds: 1));
    if (call.isEven) throw StateError('server rejected $value');
  }
}
