import 'dart:convert';
import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/shared/models/app_image_item.dart';
import 'package:ilms/shared/ui/media/app_image_viewer_page.dart';

final Uint8List _testPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

void main() {
  group('AppImageViewerPage', () {
    testWidgets('shows page indicator and closes', (tester) async {
      final images = List.generate(3, (i) => AppImageItem(bytes: _testPng, id: '$i'));

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: FilledButton(
                  onPressed: () => showAppImageViewer(context, images: images, initialIndex: 1),
                  child: const Text('Open'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('2 / 3'), findsOneWidget);
      expect(find.byType(ExtendedImageGesturePageView), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('has no rotate button when onRotate is omitted', (tester) async {
      final images = [AppImageItem(bytes: _testPng, id: '0')];

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: FilledButton(
                  onPressed: () => showAppImageViewer(context, images: images),
                  child: const Text('Open'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.rotate_right_rounded), findsNothing);
    });

    testWidgets('rotate button calls onRotate for the current index and swaps in the result', (tester) async {
      final images = [AppImageItem(bytes: _testPng, id: '0')];
      final rotatedItem = AppImageItem(bytes: _testPng, id: 'rotated');
      final calledIndexes = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: FilledButton(
                  onPressed: () => showAppImageViewer(
                    context,
                    images: images,
                    onRotate: (index) async {
                      calledIndexes.add(index);
                      return rotatedItem;
                    },
                  ),
                  child: const Text('Open'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.rotate_right_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.rotate_right_rounded));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(calledIndexes, [0]);
    });
  });
}
