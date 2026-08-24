import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/shared/ui/forms/app_map_field.dart';
import 'package:latlong2/latlong.dart';

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
  group('AppMapField', () {
    testWidgets('shows empty placeholder when no location is set', (tester) async {
      await _pumpField(
        tester,
        AppMapField(
          label: 'Map Location',
          onChanged: (_) {},
        ),
      );

      expect(find.text('Map Location'), findsOneWidget);
      expect(find.text('Tap to pick location on map'), findsOneWidget);
    });

    testWidgets('read-only empty state does not mention pick action', (tester) async {
      await _pumpField(
        tester,
        const AppMapField(
          label: 'Map Location',
          readOnly: true,
        ),
      );

      expect(find.text('No location marked.'), findsOneWidget);
    });

    testWidgets('shows coordinate preview when location is set', (tester) async {
      await _pumpField(
        tester,
        const AppMapField(
          label: 'Map Location',
          location: LatLng(3.139012, 101.686901),
        ),
      );

      expect(find.text('3.139012, 101.686901'), findsOneWidget);
      expect(find.byType(FlutterMap), findsOneWidget);
    });

    testWidgets('clear button removes location', (tester) async {
      LatLng? current = const LatLng(3.139012, 101.686901);

      await _pumpField(
        tester,
        AppMapField(
          label: 'Map Location',
          location: current,
          onChanged: (picked) => current = picked,
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(current, isNull);
    });
  });
}
