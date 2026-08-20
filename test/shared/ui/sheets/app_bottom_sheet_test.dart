import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/app/theme/app_theme.dart';
import 'package:ilms/shared/ui/sheets/app_bottom_sheet.dart';

void main() {
  Widget buildHarness(Widget child) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    );
  }

  group('showAppBottomSheet', () {
    testWidgets('renders dynamic header and compact content', (tester) async {
      await tester.pumpWidget(
        buildHarness(
          Builder(
            builder: (context) {
              return FilledButton(
                onPressed: () {
                  showAppBottomSheet<void>(
                    context: context,
                    preset: AppBottomSheetPreset.compact,
                    title: 'Filter',
                    subtitle: 'Choose one option',
                    builder: (context, scrollController) {
                      expect(scrollController, isNull);
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          ListTile(title: Text('Option A')),
                          ListTile(title: Text('Option B')),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Filter'), findsOneWidget);
      expect(find.text('Choose one option'), findsOneWidget);
      expect(find.text('Option A'), findsOneWidget);
      expect(find.text('Option B'), findsOneWidget);
      expect(find.byTooltip('Close'), findsOneWidget);
    });

    testWidgets('close button dismisses the sheet', (tester) async {
      await tester.pumpWidget(
        buildHarness(
          Builder(
            builder: (context) {
              return FilledButton(
                onPressed: () {
                  showAppBottomSheet<void>(
                    context: context,
                    preset: AppBottomSheetPreset.compact,
                    title: 'Filter',
                    builder: (context, scrollController) => const Text('Body'),
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Body'), findsNothing);
    });

    testWidgets('custom trailing replaces default close button', (tester) async {
      await tester.pumpWidget(
        buildHarness(
          Builder(
            builder: (context) {
              return FilledButton(
                onPressed: () {
                  showAppBottomSheet<void>(
                    context: context,
                    preset: AppBottomSheetPreset.compact,
                    title: 'Filter',
                    trailing: const Icon(Icons.more_horiz),
                    builder: (context, scrollController) => const Text('Body'),
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
      expect(find.byTooltip('Close'), findsNothing);
    });

    testWidgets('compact sheet wraps small content without excess height', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildHarness(
          Builder(
            builder: (context) {
              return FilledButton(
                onPressed: () {
                  showAppBottomSheet<void>(
                    context: context,
                    preset: AppBottomSheetPreset.compact,
                    title: 'Log out',
                    subtitle: 'Are you sure?',
                    builder: (context, scrollController) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OutlinedButton(onPressed: () {}, child: const Text('Cancel')),
                          const SizedBox(height: 12),
                          FilledButton(onPressed: () {}, child: const Text('Log out')),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Open logout'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open logout'));
      await tester.pumpAndSettle();

      final sheetFinder = find.byWidgetPredicate((widget) => widget is Material && widget.elevation == 8);
      final renderBox = tester.renderObject<RenderBox>(sheetFinder);

      expect(renderBox.size.height, lessThan(300));
    });

    testWidgets('auto preset uses scrollable mode for many items', (tester) async {
      await tester.pumpWidget(
        buildHarness(
          Builder(
            builder: (context) {
              return FilledButton(
                onPressed: () {
                  showAppBottomSheet<void>(
                    context: context,
                    itemCount: 8,
                    title: 'Select item',
                    builder: (context, scrollController) {
                      expect(scrollController, isNotNull);
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: 8,
                        itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
                      );
                    },
                  );
                },
                child: const Text('Open list'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open list'));
      await tester.pumpAndSettle();

      expect(find.text('Select item'), findsOneWidget);
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
    });

    testWidgets('supports fully custom header widget', (tester) async {
      await tester.pumpWidget(
        buildHarness(
          Builder(
            builder: (context) {
              return FilledButton(
                onPressed: () {
                  showAppBottomSheet<void>(
                    context: context,
                    preset: AppBottomSheetPreset.compact,
                    header: const Padding(padding: EdgeInsets.all(20), child: Text('Custom header')),
                    builder: (context, scrollController) => const Text('Body'),
                  );
                },
                child: const Text('Open custom'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open custom'));
      await tester.pumpAndSettle();

      expect(find.text('Custom header'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
    });
  });
}
