import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/premise/domain/entities/premise_remark.dart';
import 'package:ilms/features/premise/presentation/providers/premise_form_providers.dart';
import 'package:ilms/features/premise/presentation/widgets/premise_remark_sheet.dart';

class RemarksSection extends ConsumerWidget {
  const RemarksSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = PremiseFormScope.of(context);
    final readOnly = ref.watch(premiseFormControllerProvider(session).select((s) => s.isReadOnly));
    final remarks = ref.watch(premiseFormControllerProvider(session).select((s) => s.remarks));
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (remarks.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
            child: Text(
              'No remarks yet.',
              style: textTheme.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.65)),
            ),
          )
        else
          for (var i = 0; i < remarks.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _RemarkTile(
              remark: remarks[i],
              onTap: readOnly
                  ? null
                  : () => showPremiseRemarkSheet(context, session: session, index: i, initial: remarks[i]),
            ),
          ],
        if (!readOnly) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => showPremiseRemarkSheet(context, session: session),
            icon: const Icon(Icons.comment_outlined),
            label: const Text('Add Remark'),
          ),
        ],
      ],
    );
  }
}

class _RemarkTile extends StatelessWidget {
  const _RemarkTile({required this.remark, this.onTap});

  final PremiseRemark remark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final description = remark.description?.trim();

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
              Icon(Icons.flag_outlined, color: cs.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      remark.remarkDesc ?? remark.remark ?? '-',
                      style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (description != null && description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: textTheme.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.72)),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null) Icon(Icons.chevron_right_rounded, color: cs.onSurface.withValues(alpha: 0.35)),
            ],
          ),
        ),
      ),
    );
  }
}
