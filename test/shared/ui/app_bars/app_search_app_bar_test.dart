import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/shared/ui/app_bars/app_search_app_bar.dart';

void main() {
  testWidgets('AppSearchAppBar renders title, chips, and filter action', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppSearchAppBar(
            title: 'Duplicate Premise',
            filterChips: const ['Bukit Bintang', 'Plaza BB'],
            onFilterTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Duplicate Premise'), findsOneWidget);
    expect(find.text('Bukit Bintang'), findsOneWidget);
    expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
  });

  test('AppSearchAppBar preferred size grows with chips and search', () {
    final bar = AppSearchAppBar(
      title: 'Search',
      filterChips: const ['A'],
      onSearchChanged: (_) {},
      onFilterTap: () {},
    );

    expect(bar.preferredSize.height, greaterThan(kToolbarHeight));
  });
}
