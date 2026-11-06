import 'package:flutter_test/flutter_test.dart';
import 'package:students_async/api/fake_api.dart';

void main() {
  test('fetch counts calls and fails every third request', () async {
    final api = FakeApi();

    expect(await api.fetchStudents(), hasLength(6));
    expect(await api.fetchStudents(), hasLength(6));
    await expectLater(
      api.fetchStudents(),
      throwsA(isA<NoConnectionException>()),
    );
    expect(api.calls, 3);
  });

  test('empty server returns an empty list', () async {
    final api = FakeApi(empty: true);

    expect(await api.fetchStudents(), isEmpty);
  });

  test('save rejects every second call with the submitted value', () async {
    final api = FakeApi();

    await api.save(6);
    await expectLater(
      api.save(6),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'server rejected 6',
        ),
      ),
    );
  });
}
