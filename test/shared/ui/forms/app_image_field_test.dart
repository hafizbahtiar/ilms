import 'dart:convert';
import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/shared/models/app_image_item.dart';
import 'package:ilms/shared/ui/forms/app_image_field.dart';

final Uint8List _testPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

AppImageItem _item([int seed = 0]) => AppImageItem(bytes: _testPng, id: '$seed');

Future<void> _pumpField(WidgetTester tester, Widget field) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(width: 360, child: field),
        ),
      ),
    ),
  );
}

void main() {
  group('AppImageField', () {
    testWidgets('shows empty placeholder when there are no images', (tester) async {
      await _pumpField(tester, const AppImageField(images: []));

      expect(find.text('No images yet.'), findsOneWidget);
    });

    testWidgets('read-only empty state does not mention add', (tester) async {
      await _pumpField(tester, const AppImageField(images: [], readOnly: true));

      expect(find.text('No images.'), findsOneWidget);
    });

    testWidgets('edit mode shows add tile when below grid capacity', (tester) async {
      var added = false;

      await _pumpField(
        tester,
        AppImageField(
          images: [_item()],
          onAdd: () => added = true,
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byIcon(Icons.photo_camera_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.photo_camera_outlined));
      expect(added, isTrue);
    });

    testWidgets('read-only hides add tile and remove buttons', (tester) async {
      await _pumpField(
        tester,
        AppImageField(
          images: [_item(), _item(1)],
          readOnly: true,
          onAdd: () {},
          onRemove: (_) {},
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Add'), findsNothing);
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('edit overflow keeps add tile and shows +N on 8th cell', (tester) async {
      final images = List.generate(12, _item);

      await _pumpField(
        tester,
        AppImageField(
          images: images,
          onAdd: () {},
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('+4'), findsOneWidget);
      expect(find.byType(ExtendedImage), findsNWidgets(8));
      expect(find.byIcon(Icons.photo_camera_outlined), findsOneWidget);
    });

    testWidgets('read-only overflow shows +N without add tile', (tester) async {
      final images = List.generate(12, _item);

      await _pumpField(
        tester,
        AppImageField(images: images, readOnly: true),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('+4'), findsOneWidget);
      expect(find.byType(ExtendedImage), findsNWidgets(8));
      expect(find.byIcon(Icons.photo_camera_outlined), findsNothing);
    });

    testWidgets('shows overflow overlay on the last visible cell', (tester) async {
      final images = List.generate(13, _item);

      await _pumpField(
        tester,
        AppImageField(images: images, readOnly: true),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('+5'), findsOneWidget);
      expect(find.byType(ExtendedImage), findsNWidgets(8));
    });

    testWidgets('shows exactly nine thumbnails when count equals grid capacity', (tester) async {
      final images = List.generate(9, _item);

      await _pumpField(
        tester,
        AppImageField(images: images),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.textContaining('+'), findsNothing);
      expect(find.byType(ExtendedImage), findsNWidgets(9));
    });

    testWidgets('remove callback receives image index', (tester) async {
      int? removedIndex;

      await _pumpField(
        tester,
        AppImageField(
          images: [_item(), _item(1)],
          onRemove: (index) => removedIndex = index,
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      await tester.tap(find.byIcon(Icons.close).first);
      expect(removedIndex, 0);
    });

    testWidgets('hides add tile at maxImages limit', (tester) async {
      final images = List.generate(30, _item);

      await _pumpField(
        tester,
        AppImageField(
          images: images,
          maxImages: 30,
          onAdd: () {},
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byIcon(Icons.photo_camera_outlined), findsNothing);
      expect(find.byType(ExtendedImage), findsNWidgets(30));
    });

    testWidgets('shows image count in label', (tester) async {
      await _pumpField(
        tester,
        AppImageField(
          label: 'Photos',
          images: [_item(), _item(1)],
          maxImages: 30,
        ),
      );

      expect(find.text('Photos (2/30)'), findsOneWidget);
    });
  });
}
