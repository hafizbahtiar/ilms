import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/shared/ui/media/app_image_source_sheet.dart';

void main() {
  testWidgets('showAppImageSourceSheet returns camera or gallery choice', (tester) async {
    AppImageSourceChoice? choice;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: FilledButton(
                onPressed: () async {
                  choice = await showAppImageSourceSheet(context);
                },
                child: const Text('Pick'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Pick'));
    await tester.pumpAndSettle();

    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);

    await tester.tap(find.text('Gallery'));
    await tester.pumpAndSettle();

    expect(choice, AppImageSourceChoice.gallery);
  });
}
