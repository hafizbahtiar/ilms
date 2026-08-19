import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/app/app.dart';
import 'package:ilms/core/config/app_config.dart';
import 'package:ilms/core/config/app_flavor.dart';
import 'package:ilms/features/auth/presentation/pages/login_page.dart';

void main() {
  tearDown(AppConfig.reset);

  testWidgets('app opens on the login screen', (tester) async {
    await AppConfig.init(
      flavor: AppFlavor.dev,
      loader: (_) async => {'APP_ENV': 'dev'},
    );

    await tester.pumpWidget(const App());

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Demo: demo@ilms.com / password123'), findsOneWidget);
  });
}
