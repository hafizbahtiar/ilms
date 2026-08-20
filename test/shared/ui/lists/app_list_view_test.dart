import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/shared/ui/lists/app_list_view.dart';

void main() {
  group('AppListView', () {
    testWidgets('shows loading state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppListView(
              state: AppListState.loading,
              itemCount: 0,
              itemBuilder: _noop,
              loadingMessage: 'Loading items…',
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading items…'), findsOneWidget);
    });

    testWidgets('shows empty state with action', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppListView(
              state: AppListState.empty,
              itemCount: 0,
              itemBuilder: _noop,
              empty: AppListEmptyConfig(
                title: 'No drafts',
                subtitle: 'Start a new entry to create one.',
                actionLabel: 'New Entry',
                onAction: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('No drafts'), findsOneWidget);
      await tester.tap(find.text('New Entry'));
      expect(tapped, isTrue);
    });

    testWidgets('renders items in content state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppListView(
              state: AppListState.content,
              itemCount: 3,
              itemBuilder: _item,
            ),
          ),
        ),
      );

      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
    });

    testWidgets('shows retry on error state', (tester) async {
      var retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppListView(
              state: AppListState.error,
              itemCount: 0,
              itemBuilder: _noop,
              errorMessage: 'Network failed',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Network failed'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });
  });

  group('AppListTile', () {
    testWidgets('renders title and subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppListTile(title: 'Draft Premise', subtitle: 'ACME SDN BHD'),
          ),
        ),
      );

      expect(find.text('Draft Premise'), findsOneWidget);
      expect(find.text('ACME SDN BHD'), findsOneWidget);
    });
  });
}

Widget _noop(BuildContext context, int index) => const SizedBox.shrink();

Widget _item(BuildContext context, int index) => AppListTile(title: 'Item $index');
