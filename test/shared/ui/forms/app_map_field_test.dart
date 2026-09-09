import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google;
import 'package:ilms/shared/ui/forms/app_map_field.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

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
      await _pumpField(
        tester,
        AppMapField(label: 'Map Location', onChanged: (_) {}),
      );

      expect(find.text('Map Location'), findsOneWidget);
      expect(find.text('Tap here or use the buttons below'), findsOneWidget);
      expect(find.text('Pick on Map'), findsOneWidget);
      expect(find.text('Current Location'), findsOneWidget);
    });

    testWidgets('read-only empty state hides action buttons', (tester) async {
      await _pumpField(
        tester,
        const AppMapField(label: 'Map Location', readOnly: true),
      );

      expect(find.text('No location marked.'), findsOneWidget);
      expect(find.text('Pick on Map'), findsNothing);
      expect(find.text('Current Location'), findsNothing);
    });

    testWidgets(
      'current location button resolves coordinates without opening map',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SizedBox(width: 360, child: _LocationHarness()),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Current Location'));
        await tester.pumpAndSettle();

        expect(find.text('3.120000, 101.680000'), findsOneWidget);
        expect(find.byType(google.GoogleMap), findsOneWidget);
      },
    );

    testWidgets(
      'shows permission dialog and skips location when permission is denied',
      (tester) async {
        var resolverCalled = false;
        await _pumpField(
          tester,
          AppMapField(
            onChanged: (_) {},
            locationPermissionResolver: () async => PermissionStatus.denied,
            currentLocationResolver: () async {
              resolverCalled = true;
              return const LatLng(3.12, 101.68);
            },
          ),
        );

        await tester.tap(find.text('Current Location'));
        await tester.pump();

        expect(find.text('Location Permission Required'), findsOneWidget);
        expect(
          find.text(
            'Location permission is required to use your current location.',
          ),
          findsOneWidget,
        );
        expect(resolverCalled, isFalse);
      },
    );

    testWidgets('opens settings from permanently denied permission dialog', (
      tester,
    ) async {
      var settingsOpened = false;
      await _pumpField(
        tester,
        AppMapField(
          onChanged: (_) {},
          locationPermissionResolver: () async =>
              PermissionStatus.permanentlyDenied,
          openAppSettings: () async {
            settingsOpened = true;
            return true;
          },
        ),
      );

      await tester.tap(find.text('Current Location'));
      await tester.pump();
      await tester.tap(find.text('Open Settings'));
      await tester.pumpAndSettle();

      expect(settingsOpened, isTrue);
    });

    testWidgets('shows coordinate preview when location is set', (
      tester,
    ) async {
      await _pumpField(
        tester,
        const AppMapField(
          label: 'Map Location',
          location: LatLng(3.139012, 101.686901),
        ),
      );

      expect(find.text('3.139012, 101.686901'), findsOneWidget);
      expect(find.byType(google.GoogleMap), findsOneWidget);
    });

    testWidgets('preview recenters when location is updated', (tester) async {
      const first = LatLng(3.139012, 101.686901);
      const second = LatLng(3.150000, 101.700000);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(width: 360, child: _EditableLocationHarness()),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Set first'));
      await tester.pumpAndSettle();

      final firstMap = tester.widget<google.GoogleMap>(
        find.byType(google.GoogleMap),
      );
      expect(
        firstMap.initialCameraPosition.target,
        google.LatLng(first.latitude, first.longitude),
      );

      await tester.tap(find.text('Set second'));
      await tester.pumpAndSettle();

      expect(find.text('3.150000, 101.700000'), findsOneWidget);
      final secondMap = tester.widget<google.GoogleMap>(
        find.byType(google.GoogleMap),
      );
      expect(
        secondMap.initialCameraPosition.target,
        google.LatLng(second.latitude, second.longitude),
      );
      expect(secondMap.key, isNot(equals(firstMap.key)));
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

    testWidgets('can hide individual empty-state actions', (tester) async {
      await _pumpField(
        tester,
        AppMapField(
          label: 'Map Location',
          showPickOnMapAction: false,
          onChanged: (_) {},
        ),
      );

      expect(find.text('Pick on Map'), findsNothing);
      expect(find.text('Current Location'), findsOneWidget);
    });
  });
}

class _EditableLocationHarness extends StatefulWidget {
  @override
  State<_EditableLocationHarness> createState() =>
      _EditableLocationHarnessState();
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
          onPressed: () =>
              setState(() => _location = const LatLng(3.139012, 101.686901)),
          child: const Text('Set first'),
        ),
        TextButton(
          onPressed: () =>
              setState(() => _location = const LatLng(3.15, 101.7)),
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
      locationPermissionResolver: () async => PermissionStatus.granted,
    );
  }
}
