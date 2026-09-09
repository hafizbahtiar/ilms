import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/app/theme/app_theme.dart';
import 'package:ilms/features/premise/presentation/controllers/premise_form_state.dart';
import 'package:ilms/features/premise/presentation/providers/premise_form_providers.dart';
import 'package:ilms/features/premise/presentation/widgets/premise_business_activity_sheet.dart';
import 'package:ilms/shared/lookups/providers/general_lookup_providers.dart';
import 'package:ilms/shared/models/general_model.dart';
import 'package:ilms/shared/ui/forms/app_text_field.dart';

void main() {
  testWidgets('business activity sheet scrolls content within a short viewport', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const session = PremiseFormSession(mode: PremiseFormMode.create, instanceKey: 'activity-sheet-test');
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: PremiseFormScope(
            session: session,
            child: Builder(
              builder: (context) => Scaffold(
                body: FilledButton(
                  onPressed: () => showPremiseBusinessActivitySheet(context, session: session),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('floor picker opens immediately while its lookup is loading', (tester) async {
    final floors = Completer<List<GeneralModel>>();
    const session = PremiseFormSession(mode: PremiseFormMode.create, instanceKey: 'floor-picker-test');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [generalFloorsProvider.overrideWith((ref) => floors.future)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: PremiseFormScope(
            session: session,
            child: Builder(
              builder: (context) => Scaffold(
                body: FilledButton(
                  onPressed: () => showPremiseBusinessActivitySheet(context, session: session),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).last, const Offset(0, -300));
    await tester.pump();
    await tester.tap(find.byType(AppPickerField).last);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Select one or more floors'), findsOneWidget);
  });
}
