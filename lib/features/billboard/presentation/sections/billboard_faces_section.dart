import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_face.dart';
import 'package:ilms/features/billboard/presentation/providers/billboard_form_providers.dart';
import 'package:ilms/features/billboard/presentation/widgets/billboard_face_dialog.dart';

class BillboardFacesSection extends ConsumerWidget {
  const BillboardFacesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = BillboardFormScope.of(context);
    final readOnly = ref.watch(billboardFormControllerProvider(session).select((s) => s.isReadOnly));
    final faces = ref.watch(billboardFormControllerProvider(session).select((s) => s.faces));
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (faces.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
            child: Text(
              'No faces added yet.',
              style: textTheme.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.65)),
            ),
          )
        else
          for (var i = 0; i < faces.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _FaceTile(
              face: faces[i],
              onTap: readOnly
                  ? null
                  : () => showBillboardFaceDialog(context, session: session, index: i, initial: faces[i]),
            ),
          ],
        if (!readOnly) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => showBillboardFaceDialog(context, session: session),
            icon: const Icon(Icons.crop_square_outlined),
            label: const Text('Add Face'),
          ),
        ],
      ],
    );
  }
}

class _FaceTile extends StatelessWidget {
  const _FaceTile({required this.face, this.onTap});

  final BillboardFace face;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.crop_square_outlined, color: cs.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${face.width ?? '-'} × ${face.height ?? '-'} mm',
                      style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Count: ${face.count ?? '-'}',
                      style: textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
              if (onTap != null) Icon(Icons.edit_outlined, color: cs.onSurface.withValues(alpha: 0.35)),
            ],
          ),
        ),
      ),
    );
  }
}
