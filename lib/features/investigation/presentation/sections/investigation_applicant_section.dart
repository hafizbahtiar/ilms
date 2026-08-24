import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/investigation/presentation/providers/investigation_form_providers.dart';

/// Read-only — sourced from the case record, not editable from the app.
class InvestigationApplicantSection extends ConsumerWidget {
  const InvestigationApplicantSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = InvestigationFormScope.of(context);
    final applicant = ref.watch(investigationFormControllerProvider(session).select((s) => s.applicant));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ReadOnlyRow(label: 'License File No.', value: applicant.licenseFileNo),
        _ReadOnlyRow(label: 'Applicant Name', value: applicant.applicantName),
        _ReadOnlyRow(label: 'Identification No.', value: applicant.identificationNo),
        _ReadOnlyRow(label: 'Company Name', value: applicant.companyName),
        _ReadOnlyRow(label: 'Registration No.', value: applicant.registrationNo),
        const SizedBox(height: 12),
        Text('Business Types', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        if (applicant.businessTypes.isEmpty)
          const _EmptyHint(text: 'No business types listed')
        else
          for (final type in applicant.businessTypes) Text('• ${type.description ?? type.code ?? '-'}'),
        const SizedBox(height: 12),
        Text(
          'Advertisement Types',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        if (applicant.advertisementTypes.isEmpty)
          const _EmptyHint(text: 'No advertisement types listed')
        else
          for (final type in applicant.advertisementTypes) Text('• ${type.description ?? type.code ?? '-'}'),
      ],
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.labelMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
          const SizedBox(height: 2),
          Text(
            (value == null || value!.trim().isEmpty) ? '-' : value!,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
    );
  }
}
