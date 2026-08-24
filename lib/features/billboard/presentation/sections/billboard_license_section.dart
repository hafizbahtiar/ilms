import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/billboard/presentation/providers/billboard_form_providers.dart';
import 'package:ilms/shared/ui/forms/app_text_field.dart';

class BillboardLicenseSection extends ConsumerWidget {
  const BillboardLicenseSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = BillboardFormScope.of(context);
    final fields = ref.watch(billboardFormFieldsProvider(session));
    final readOnly = ref.watch(billboardFormControllerProvider(session).select((s) => s.isReadOnly));

    return AppTextField(label: 'License File No.', controller: fields.licenseFileNo, readOnly: readOnly);
  }
}
