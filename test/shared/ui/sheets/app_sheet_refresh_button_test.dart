import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/shared/ui/sheets/app_sheet_refresh_button.dart';

void main() {
  testWidgets('spins and disables the button while refresh is running', (tester) async {
    final refreshCompleter = Completer<void>();
    var refreshCalls = 0;
    final refreshTransition = find.descendant(of: find.byType(IconButton), matching: find.byType(RotationTransition));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppSheetRefreshIconButton(
            onRefresh: () {
              refreshCalls++;
              return refreshCompleter.future;
            },
          ),
        ),
      ),
    );

    expect(refreshTransition, findsOneWidget);
    expect(tester.widget<IconButton>(find.byType(IconButton)).onPressed, isNotNull);

    await tester.tap(find.byType(IconButton));
    await tester.pump();

    expect(refreshCalls, 1);
    expect(tester.widget<IconButton>(find.byType(IconButton)).onPressed, isNull);
    expect(tester.widget<RotationTransition>(refreshTransition).turns.isAnimating, isTrue);

    refreshCompleter.complete();
    await tester.pumpAndSettle();

    expect(tester.widget<IconButton>(find.byType(IconButton)).onPressed, isNotNull);
    expect(tester.widget<RotationTransition>(refreshTransition).turns.isAnimating, isFalse);
  });
}
