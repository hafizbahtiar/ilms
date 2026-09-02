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

    testWidgets('preview recenters when location is updated', (tester) async {
      const first = LatLng(3.139012, 101.686901);
      const second = LatLng(3.150000, 101.700000);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: SizedBox(width: 360, child: _EditableLocationHarness())),
          ),
        ),
      );

      await tester.tap(find.text('Set first'));
      await tester.pumpAndSettle();

      final firstMap = tester.widget<FlutterMap>(find.byType(FlutterMap));
      expect(firstMap.options.initialCenter, first);

      await tester.tap(find.text('Set second'));
      await tester.pumpAndSettle();

      expect(find.text('3.150000, 101.700000'), findsOneWidget);
      final secondMap = tester.widget<FlutterMap>(find.byType(FlutterMap));
      expect(secondMap.options.initialCenter, second);
      expect(secondMap.key, isNot(equals(firstMap.key)));
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

class _EditableLocationHarness extends StatefulWidget {
  @override
  State<_EditableLocationHarness> createState() => _EditableLocationHarnessState();
}

class _EditableLocationHarnessState extends State<_EditableLocationHarness> {
  LatLng? _location;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppMapField(
          label: 'Map Location',
          location: _location,
          onChanged: (picked) => setState(() => _location = picked),
        ),
        TextButton(
          onPressed: () => setState(() => _location = const LatLng(3.139012, 101.686901)),
          child: const Text('Set first'),
        ),
        TextButton(
          onPressed: () => setState(() => _location = const LatLng(3.15, 101.7)),
          child: const Text('Set second'),
        ),
      ],
    );
  }
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
