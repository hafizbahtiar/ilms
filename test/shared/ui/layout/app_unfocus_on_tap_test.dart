import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/shared/ui/layout/app_unfocus_on_tap.dart';

void main() {
  group('AppUnfocusOnTap', () {
    testWidgets('tapping empty space unfocuses the active field', (tester) async {
      final controller = TextEditingController();
      final fieldFocusNode = FocusNode();
      addTearDown(fieldFocusNode.dispose);
      const emptySpaceKey = Key('emptySpace');

      await tester.pumpWidget(
        MaterialApp(
          home: AppUnfocusOnTap(
            child: Scaffold(
              body: Column(
                children: [
                  TextField(controller: controller, focusNode: fieldFocusNode),
                  const Expanded(child: ColoredBox(key: emptySpaceKey, color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(fieldFocusNode.hasFocus, isTrue);

      await tester.tap(find.byKey(emptySpaceKey), warnIfMissed: false);
      // Focus changes apply on the following frame.
      await tester.pump();
      await tester.pump();

      expect(fieldFocusNode.hasFocus, isFalse);
    });

    testWidgets('tapping a button inside still triggers its own onPressed', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AppUnfocusOnTap(
            child: Scaffold(
              body: Center(
                child: FilledButton(onPressed: () => tapped = true, child: const Text('Go')),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
