import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/premise/domain/entities/premise_gps.dart';
import 'package:ilms/features/premise/presentation/providers/premise_form_providers.dart';
import 'package:ilms/shared/ui/forms/app_map_field.dart';
import 'package:latlong2/latlong.dart';

class PremiseGpsSection extends ConsumerWidget {
  const PremiseGpsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = PremiseFormScope.of(context);
    final readOnly = ref.watch(premiseFormControllerProvider(session).select((s) => s.isReadOnly));
    final gps = ref.watch(premiseFormControllerProvider(session).select((s) => s.gps));
    final controller = ref.read(premiseFormControllerProvider(session).notifier);

    return AppMapField(
      location: _toLatLng(gps),
      readOnly: readOnly,
      label: 'Coordinate',
      onChanged: readOnly ? null : controller.setCoordinate,
    );
  }

  LatLng? _toLatLng(PremiseGps gps) {
    if (!gps.hasCoordinate) return null;
    final lat = double.tryParse(gps.latitude!);
    final lng = double.tryParse(gps.longitude!);
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }
}
