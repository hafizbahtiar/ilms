import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_gps.dart';
import 'package:ilms/features/billboard/presentation/providers/billboard_form_providers.dart';
import 'package:ilms/shared/ui/forms/app_map_field.dart';
import 'package:latlong2/latlong.dart';

class BillboardGpsSection extends ConsumerWidget {
  const BillboardGpsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = BillboardFormScope.of(context);
    final readOnly = ref.watch(billboardFormControllerProvider(session).select((s) => s.isReadOnly));
    final gps = ref.watch(billboardFormControllerProvider(session).select((s) => s.gps));
    final controller = ref.read(billboardFormControllerProvider(session).notifier);

    return AppMapField(
      location: _toLatLng(gps),
      readOnly: readOnly,
      label: 'Coordinate',
      onChanged: readOnly ? null : controller.setCoordinate,
    );
  }

  LatLng? _toLatLng(BillboardGps gps) {
    if (!gps.hasCoordinate) return null;
    final lat = double.tryParse(gps.latitude!);
    final lng = double.tryParse(gps.longitude!);
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }
}
