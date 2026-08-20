import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/app/theme/app_theme.dart';
import 'package:ilms/shared/ui/forms/app_text_field.dart';

void main() {
  testWidgets('AppPickerField opens bottom sheet and sets controller text', (tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppPickerField<String>(
            label: 'Business Type',
            controller: controller,
            options: const ['Retail', 'Food & Beverage', 'Service'],
            optionLabel: (value) => value,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();

    expect(find.text('Business Type'), findsWidgets);
    expect(find.text('Retail'), findsOneWidget);

    await tester.tap(find.text('Food & Beverage'));
    await tester.pumpAndSettle();

    expect(controller.text, 'Food & Beverage');
  });
}
