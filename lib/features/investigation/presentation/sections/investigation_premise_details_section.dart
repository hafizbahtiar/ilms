import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/investigation/presentation/providers/investigation_form_providers.dart';
import 'package:ilms/features/investigation/presentation/widgets/investigation_section_header.dart';
import 'package:ilms/shared/ui/forms/app_text_field.dart';

/// Maklumat Premis — the largest, fully-editable section: nearby premises,
/// building info, entertainment/business activity, pollution/disturbance,
/// and advertisement. No mandatory fields (matches legacy).
class InvestigationPremiseDetailsSection extends ConsumerWidget {
  const InvestigationPremiseDetailsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = InvestigationFormScope.of(context);
    final fields = ref.watch(investigationFormFieldsProvider(session));
    final readOnly = ref.watch(investigationFormControllerProvider(session).select((s) => s.isReadOnly));
    final premiseDetails = ref.watch(investigationFormControllerProvider(session).select((s) => s.premiseDetails));
    final pollution = ref.watch(investigationFormControllerProvider(session).select((s) => s.pollutionDisturbance));
    final advertisement = ref.watch(investigationFormControllerProvider(session).select((s) => s.advertisement));
    final controller = ref.read(investigationFormControllerProvider(session).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const InvestigationSectionHeader(title: 'Nearby Premises'),
        AppTextField(label: 'Premise Position', controller: fields.premisePosition, readOnly: readOnly),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppTextField(label: 'Left', controller: fields.premiseLeft, readOnly: readOnly),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(label: 'Right', controller: fields.premiseRight, readOnly: readOnly),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppTextField(label: 'Above', controller: fields.premiseAbove, readOnly: readOnly),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(label: 'Below', controller: fields.premiseBelow, readOnly: readOnly),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const InvestigationSectionHeader(title: 'Building'),
        AppTextField(label: 'Building Type', controller: fields.buildingType, readOnly: readOnly),
        const SizedBox(height: 12),
        AppTextField(label: 'Level', controller: fields.level, readOnly: readOnly),
        const SizedBox(height: 12),
        AppTextField(label: 'Building Status', controller: fields.buildingStatus, readOnly: readOnly),
        const SizedBox(height: 12),
        _YesNoRow(
          label: 'Premise Modification',
          value: premiseDetails.premiseModification,
          onChanged: readOnly ? null : controller.setPremiseModification,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: 'Premise Length',
                controller: fields.premiseLength,
                readOnly: readOnly,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                label: 'Premise Width',
                controller: fields.premiseWidth,
                readOnly: readOnly,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Similar Premises Count',
          controller: fields.similarPremisesCount,
          readOnly: readOnly,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 24),
        const InvestigationSectionHeader(title: 'Business Activity'),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: 'Floor Length',
                controller: fields.floorLength,
                readOnly: readOnly,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                label: 'Floor Width',
                controller: fields.floorWidth,
                readOnly: readOnly,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppTextField(label: 'Opening Time', controller: fields.openingTime, readOnly: readOnly),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(label: 'Closing Time', controller: fields.closingTime, readOnly: readOnly),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const InvestigationSectionHeader(title: 'Pollution / Disturbance'),
        _YesNoRow(
          label: 'Obstruction of Public Areas',
          value: pollution.placingFurniture,
          onChanged: readOnly ? null : controller.setPlacingFurniture,
        ),
        if (pollution.placingFurniture) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Chairs',
                  controller: fields.chairCount,
                  readOnly: readOnly,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  label: 'Tables',
                  controller: fields.tableCount,
                  readOnly: readOnly,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  label: 'Stalls',
                  controller: fields.stallCount,
                  readOnly: readOnly,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: 'Machines',
                controller: fields.machineCount,
                readOnly: readOnly,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                label: 'Hair Salon Chairs',
                controller: fields.hairSalonChairCount,
                readOnly: readOnly,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: 'Rooms',
                controller: fields.roomCount,
                readOnly: readOnly,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                label: 'Students',
                controller: fields.studentCount,
                readOnly: readOnly,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: 'Petrol (L)',
                controller: fields.petrolLiters,
                readOnly: readOnly,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                label: 'Diesel (L)',
                controller: fields.dieselLiters,
                readOnly: readOnly,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                label: 'Gas (L)',
                controller: fields.gasLiters,
                readOnly: readOnly,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Other Activities',
          controller: fields.otherActivities,
          readOnly: readOnly,
          maxLines: 3,
          keyboardType: TextInputType.multiline,
        ),
        const SizedBox(height: 24),
        const InvestigationSectionHeader(title: 'Advertisement'),
        _YesNoRow(
          label: 'Advertisement Displayed',
          value: advertisement.displayed,
          onChanged: readOnly ? null : controller.setAdvertisementDisplayed,
        ),
        if (advertisement.displayed) ...[
          const SizedBox(height: 12),
          AppTextField(label: 'Advertisement Location', controller: fields.advertisementLocation, readOnly: readOnly),
        ],
        const SizedBox(height: 12),
        _YesNoRow(
          label: 'Advertisement Compliant',
          value: advertisement.compliant,
          onChanged: readOnly ? null : controller.setAdvertisementCompliant,
        ),
        if (!advertisement.compliant) ...[
          const SizedBox(height: 12),
          AppTextField(
            label: 'Non-Compliant Reason',
            controller: fields.advertisementNonCompliantReason,
            readOnly: readOnly,
            maxLines: 2,
            keyboardType: TextInputType.multiline,
          ),
        ],
        const SizedBox(height: 12),
        _YesNoRow(
          label: 'Malay Language',
          value: advertisement.malayLanguage,
          onChanged: readOnly ? null : controller.setMalayLanguage,
        ),
        _YesNoRow(
          label: 'Size Compliant',
          value: advertisement.sizeCompliant,
          onChanged: readOnly ? null : controller.setSizeCompliant,
        ),
        _YesNoRow(
          label: 'Spelling Compliant',
          value: advertisement.spellingCompliant,
          onChanged: readOnly ? null : controller.setSpellingCompliant,
        ),
      ],
    );
  }
}

class _YesNoRow extends StatelessWidget {
  const _YesNoRow({required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
