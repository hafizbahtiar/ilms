import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/billboard/presentation/providers/billboard_form_providers.dart';
import 'package:ilms/shared/ui/forms/app_text_field.dart';

class BillboardMediaOwnerSection extends ConsumerWidget {
  const BillboardMediaOwnerSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = BillboardFormScope.of(context);
    final fields = ref.watch(billboardFormFieldsProvider(session));
    final readOnly = ref.watch(billboardFormControllerProvider(session).select((s) => s.isReadOnly));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(label: 'Media Owner Name', controller: fields.mediaOwnerName, readOnly: readOnly, uppercase: true),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Media Owner Tel',
          controller: fields.mediaOwnerTel,
          readOnly: readOnly,
          keyboardType: TextInputType.phone,
          uppercase: true,
        ),
      ],
    );
  }
}
