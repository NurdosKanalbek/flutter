import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:users_api/core/api/api_client.dart';
import 'package:users_api/features/users/user_repository.dart';
import 'package:users_api/features/users/users_model.dart';
import 'package:users_api/main.dart';

void main() {
  testWidgets('App smoke test builds with provider', (
    WidgetTester tester,
  ) async {
    final model = UsersModel(UserRepository(ApiClient(http.Client())));
    await tester.pumpWidget(
      ChangeNotifierProvider<UsersModel>.value(
        value: model,
        child: const App(),
      ),
    );
    expect(find.byType(App), findsOneWidget);
  });
}
