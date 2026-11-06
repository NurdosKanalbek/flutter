import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:students_async/api/fake_api.dart';
import 'package:students_async/students_future_screen.dart';
import 'package:students_async/students_screen.dart';

class ImmediateApi extends FakeApi {
  ImmediateApi({this.students = const [], this.error});

  final List<Student> students;
  final Object? error;
  int fetchCount = 0;

  @override
  Future<List<Student>> fetchStudents() async {
    fetchCount++;
    if (error case final value?) throw value;
    return students;
  }
}

const _students = [
  Student(name: 'Aida Nurlanova', group: 'IT-2301', gpa: 3.7),
  Student(name: 'Aruzhan Bek', group: 'IT-2302'),
];

void main() {
  testWidgets('manual screen renders data including missing GPA', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: StudentsScreen(api: ImmediateApi(students: _students)),
      ),
    );
    await tester.pump();

    expect(find.text('Aida Nurlanova'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('manual screen renders the error and retry action', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: StudentsScreen(
          api: ImmediateApi(error: const NoConnectionException()),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Could not load students'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('FutureBuilder switch does not fetch again', (tester) async {
    final api = ImmediateApi(students: _students);
    await tester.pumpWidget(MaterialApp(home: StudentsFutureScreen(api: api)));
    await tester.pump();
    expect(api.fetchCount, 1);

    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(api.fetchCount, 1);
    expect(find.text('Aida Nurlanova'), findsOneWidget);
  });

  testWidgets('FutureBuilder treats an empty response as empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: StudentsFutureScreen(api: ImmediateApi())),
    );
    await tester.pump();

    expect(find.text('No students yet'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
