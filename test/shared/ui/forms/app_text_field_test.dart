import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/app/theme/app_theme.dart';
import 'package:ilms/shared/ui/forms/app_text_field.dart';

void main() {
  group('AppTextField', () {
    testWidgets('shows label and required marker', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: AppTextField(label: 'Company Name', required: true),
          ),
        ),
      );

      expect(find.textContaining('Company Name'), findsOneWidget);
      expect(find.textContaining('*'), findsOneWidget);
    });

    testWidgets('validator shows error text', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Form(
              key: formKey,
              child: AppTextField(
                label: 'Trade Name',
                required: true,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
            ),
          ),
        ),
      );

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('keyboardType defaults to text regardless of maxLines — callers opt into multiline explicitly', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: AppTextField(label: 'Address', maxLines: 2),
          ),
        ),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.keyboardType, TextInputType.text);
    });

    testWidgets('multiline keyboardType, once requested, gives Return a newline action', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: AppTextField(label: 'Address', maxLines: 2, keyboardType: TextInputType.multiline),
          ),
        ),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.keyboardType, TextInputType.multiline);
    });
  });
}
