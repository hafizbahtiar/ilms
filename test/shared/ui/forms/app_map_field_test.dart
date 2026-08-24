import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/shared/ui/forms/app_map_field.dart';
import 'package:latlong2/latlong.dart';

Future<void> _pumpField(WidgetTester tester, Widget field) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: SizedBox(width: 360, child: field)),
      ),
    ),
  );
}

void main() {
  group('AppMapField', () {
    testWidgets('shows empty actions when no location is set', (tester) async {
      await _pumpField(tester, AppMapField(label: 'Map Location', onChanged: (_) {}));

      expect(find.text('Map Location'), findsOneWidget);
      expect(find.text('Tap here or use the buttons below'), findsOneWidget);
      expect(find.text('Pick on Map'), findsOneWidget);
      expect(find.text('Current Location'), findsOneWidget);
    });

    testWidgets('read-only empty state hides action buttons', (tester) async {
      await _pumpField(tester, const AppMapField(label: 'Map Location', readOnly: true));

      expect(find.text('No location marked.'), findsOneWidget);
      expect(find.text('Pick on Map'), findsNothing);
      expect(find.text('Current Location'), findsNothing);
    });

    testWidgets('current location button resolves coordinates without opening map', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: SizedBox(width: 360, child: _LocationHarness())),
          ),
        ),
      );

      await tester.tap(find.text('Current Location'));
      await tester.pumpAndSettle();

      expect(find.text('3.120000, 101.680000'), findsOneWidget);
      expect(find.byType(FlutterMap), findsOneWidget);
    });

    testWidgets('shows coordinate preview when location is set', (tester) async {
      await _pumpField(tester, const AppMapField(label: 'Map Location', location: LatLng(3.139012, 101.686901)));

      expect(find.text('3.139012, 101.686901'), findsOneWidget);
      expect(find.byType(FlutterMap), findsOneWidget);
    });

    testWidgets('clear button removes location', (tester) async {
      LatLng? current = const LatLng(3.139012, 101.686901);

      await _pumpField(
        tester,
        AppMapField(label: 'Map Location', location: current, onChanged: (picked) => current = picked),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(current, isNull);
    });

    testWidgets('can hide individual empty-state actions', (tester) async {
      await _pumpField(tester, AppMapField(label: 'Map Location', showPickOnMapAction: false, onChanged: (_) {}));

      expect(find.text('Pick on Map'), findsNothing);
      expect(find.text('Current Location'), findsOneWidget);
    });
  });
}

class _LocationHarness extends StatefulWidget {
  @override
  State<_LocationHarness> createState() => _LocationHarnessState();
}

class _LocationHarnessState extends State<_LocationHarness> {
  LatLng? _location;

  @override
  Widget build(BuildContext context) {
    return AppMapField(
      label: 'Map Location',
      location: _location,
      onChanged: (picked) => setState(() => _location = picked),
      currentLocationResolver: () async => const LatLng(3.12, 101.68),
    );
  }
}
