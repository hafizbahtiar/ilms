import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/features/premise/data/mappers/premise_census_image_mapper.dart';
import 'package:ilms/features/premise/domain/entities/premise_address.dart';
import 'package:ilms/features/premise/domain/entities/premise_business_activity.dart';
import 'package:ilms/features/premise/domain/entities/premise_detail_record.dart';
import 'package:ilms/features/premise/domain/entities/premise_license.dart';
import 'package:ilms/features/premise/domain/entities/premise_remark.dart';
import 'package:ilms/features/premise/presentation/providers/premise_detail_providers.dart';
import 'package:ilms/shared/formatters/app_date_format.dart';
import 'package:ilms/shared/ui/forms/app_image_field.dart';
import 'package:ilms/shared/ui/lists/app_list_view.dart';

/// Read-only "document style" record view — reached from the History tab.
/// Unlike [PremiseFormPage] (which reuses the editable wizard in a read-only
/// mode), this renders every section as its own card: nothing here is meant
/// to become editable.
class PremiseDetailPage extends ConsumerStatefulWidget {
  const PremiseDetailPage({super.key, required this.visitNo});

  final String visitNo;

  @override
  ConsumerState<PremiseDetailPage> createState() => _PremiseDetailPageState();
}

class _PremiseDetailPageState extends ConsumerState<PremiseDetailPage> {
  late Future<PremiseDetailRecord> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<PremiseDetailRecord> _load() {
    return ref.read(premiseDetailRepositoryProvider).getDetailRecord(widget.visitNo);
  }

  void _retry() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLow,
      appBar: AppBar(title: const Text('Premise Detail'), centerTitle: false),
      body: SafeArea(
        child: FutureBuilder<PremiseDetailRecord>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            if (snapshot.hasError) {
              return AppListView(
                state: AppListState.error,
                itemCount: 0,
                itemBuilder: (_, _) => const SizedBox.shrink(),
                errorMessage: 'Unable to load premise details.',
                onRetry: _retry,
              );
            }

            final record = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _DetailHeaderCard(record: record),
                const SizedBox(height: 20),
                _DetailSection(
                  icon: Icons.apartment_rounded,
                  title: 'Company & Contact',
                  children: [
                    _FieldGroup([
                      _Field('Company Name', record.companyContact.companyName),
                      _Field('Register No.', record.companyContact.registerNumber),
                      _Field('Tel No.', record.companyContact.companyTelNo),
                      _Field('Fax No.', record.companyContact.companyFaxNo),
                      _Field('Sticker No.', record.companyContact.stickerNo),
                      _Field('Census Date', record.companyContact.censusDate),
                    ]),
                    _FieldGroup([
                      _Field('Contact Person', record.companyContact.contactPersonName),
                      _Field('Phone', record.companyContact.contactPersonPhone),
                      _Field('Email', record.companyContact.contactPersonEmail),
                      _Field('Position', record.companyContact.contactPersonPosition),
                    ]),
                    _FieldGroup([
                      _Field(
                        'Address',
                        [
                          record.companyContact.unit,
                          record.companyContact.building,
                          record.companyContact.street1,
                          record.companyContact.street2,
                        ].where((v) => v != null && v.isNotEmpty).join(', '),
                      ),
                      _Field('Area', record.companyContact.areaDescription),
                      _Field('Postcode', record.companyContact.postcode),
                      _Field('State', record.companyContact.stateDescription),
                    ]),
                  ],
                ),
                const SizedBox(height: 14),
                _DetailSection(
                  icon: Icons.storefront_rounded,
                  title: 'Premise Details',
                  children: [
                    _FieldGroup([
                      _Field('Trade Name', record.details.traderName),
                      _Field(
                        'Business Type',
                        record.details.businessTypeDescription ?? record.details.businessTypeCode,
                      ),
                      _Field('Premise Type', record.details.premiseTypeDescription ?? record.details.premiseTypeCode),
                      _Field(
                        'Measurement',
                        record.details.width == null && record.details.length == null
                            ? null
                            : '${record.details.width ?? '-'} x ${record.details.length ?? '-'}',
                      ),
                    ]),
                  ],
                ),
                if (record.addresses.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _DetailSection(
                    icon: Icons.location_on_rounded,
                    title: 'Premise Address',
                    count: record.addresses.length,
                    children: [for (final address in record.addresses) _AddressTile(address: address)],
                  ),
                ],
                if (record.businessActivities.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _DetailSection(
                    icon: Icons.store_rounded,
                    title: 'Business Activities',
                    count: record.businessActivities.length,
                    children: [
                      for (final activity in record.businessActivities) _BusinessActivityTile(activity: activity),
                    ],
                  ),
                ],
                if (record.licenses.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _DetailSection(
                    icon: Icons.verified_rounded,
                    title: 'License Information',
                    count: record.licenses.length,
                    children: [for (final license in record.licenses) _LicenseTile(license: license)],
                  ),
                ],
                if (record.remarks.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _DetailSection(
                    icon: Icons.sticky_note_2_rounded,
                    title: 'Remarks',
                    count: record.remarks.length,
                    children: [for (final remark in record.remarks) _RemarkTile(remark: remark)],
                  ),
                ],
                const SizedBox(height: 14),
                _DetailSection(
                  icon: Icons.photo_library_rounded,
                  title: 'Census Images',
                  count: record.censusImages.length,
                  children: [
                    AppImageField(
                      images: PremiseCensusImageMapper.toAppImageItems(record.censusImages),
                      readOnly: true,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _RecordInfoFooter(record: record),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DetailHeaderCard extends StatelessWidget {
  const _DetailHeaderCard({required this.record});

  final PremiseDetailRecord record;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary, cs.primary.withValues(alpha: 0.82)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: cs.primary.withValues(alpha: 0.28), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.store_mall_directory_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.displayTitle,
                      style: textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                    if (record.displaySubtitle != record.displayTitle) ...[
                      const SizedBox(height: 2),
                      Text(
                        record.displaySubtitle,
                        style: textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeaderChip(icon: Icons.numbers_rounded, label: record.visitNo),
              if (record.visitStatus != null) _HeaderChip(icon: Icons.task_alt_rounded, label: record.visitStatus!),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.9)),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// Flat, shadow-elevated section card — the document's primary content unit.
/// Deliberately avoids combining a non-uniform [Border] with [borderRadius]:
/// that combination is unreliable to paint and previously left every section
/// but the header rendering as an empty white box.
class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.icon, required this.title, required this.children, this.count});

  final IconData icon;
  final String title;
  final List<Widget> children;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 18, color: cs.onPrimaryContainer),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
              ),
              if (count != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    '$count',
                    style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(height: 10), children[i]],
        ],
      ),
    );
  }
}

/// One flat block of label/value pairs within a section — separated from
/// sibling groups with a hairline divider instead of nesting cards.
class _FieldGroup extends StatelessWidget {
  const _FieldGroup(this.fields);

  final List<_Field> fields;

  @override
  Widget build(BuildContext context) {
    final visible = fields.where((f) => (f.value?.trim().isNotEmpty ?? false)).toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < visible.length; i++) ...[
          if (i > 0) Divider(height: 18, color: cs.outlineVariant.withValues(alpha: 0.3)),
          _InfoRow(visible[i]),
        ],
      ],
    );
  }
}

class _Field {
  const _Field(this.label, this.value);

  final String label;
  final String? value;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.field);

  final _Field field;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 108,
          child: Text(
            field.label,
            style: textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.55),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(field.value!.trim(), style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

/// Nested, softly tinted tile used for one repeated record (address,
/// business activity, license, remark) within a section.
class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.icon, required this.children});

  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(height: 8), children[i]],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TileText extends StatelessWidget {
  const _TileText(this.label, this.value, {this.emphasize = false});

  final String label;
  final String? value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final text = value?.trim();
    if (text == null || text.isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (emphasize) {
      return Text(text, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800));
    }

    return RichText(
      text: TextSpan(
        style: textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.8)),
        children: [
          TextSpan(
            text: '$label: ',
            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.w600),
          ),
          TextSpan(text: text),
        ],
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({required this.address});

  final PremiseAddress address;

  @override
  Widget build(BuildContext context) {
    final line = [
      address.unitNo,
      address.floor,
      address.blockNo,
      address.building,
      address.streetName,
    ].where((v) => v != null && v.isNotEmpty).join(', ');

    return _RecordTile(
      icon: Icons.location_on_outlined,
      children: [
        _TileText('', line.isEmpty ? null : line, emphasize: true),
        _TileText('Area', address.area),
        _TileText('Parliament', address.parliament),
        _TileText('Postcode', address.postcode),
      ],
    );
  }
}

class _BusinessActivityTile extends StatelessWidget {
  const _BusinessActivityTile({required this.activity});

  final PremiseBusinessActivity activity;

  @override
  Widget build(BuildContext context) {
    return _RecordTile(
      icon: Icons.store_outlined,
      children: [
        _TileText('', activity.businessTypeDesc ?? activity.businessType, emphasize: true),
        _TileText('Status', activity.statusDesc ?? activity.status),
        _TileText('Description', activity.description),
      ],
    );
  }
}

class _LicenseTile extends StatelessWidget {
  const _LicenseTile({required this.license});

  final PremiseLicense license;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final validPeriod = license.validFrom == null && license.validTo == null
        ? null
        : '${license.validFrom ?? '-'} — ${license.validTo ?? '-'}';

    return _RecordTile(
      icon: Icons.badge_outlined,
      children: [
        _TileText('', license.licenseNo ?? license.licenseFileNo, emphasize: true),
        _TileText('File No.', license.licenseFileNo),
        _TileText('Status', license.statusDesc ?? license.status),
        _TileText('Valid Period', validPeriod),
        if (license.businessActivities.isNotEmpty) ...[
          const SizedBox(height: 4),
          for (final item in license.businessActivities)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '• ${item.businessTypeDesc ?? item.businessType ?? '-'} — ${item.description ?? '-'} (RM ${item.amount ?? '0.00'})',
                style: textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.75)),
              ),
            ),
        ],
      ],
    );
  }
}

class _RemarkTile extends StatelessWidget {
  const _RemarkTile({required this.remark});

  final PremiseRemark remark;

  @override
  Widget build(BuildContext context) {
    return _RecordTile(
      icon: Icons.chat_bubble_outline_rounded,
      children: [
        _TileText('', remark.remarkDesc ?? remark.remark, emphasize: true),
        _TileText('Description', remark.description),
      ],
    );
  }
}

/// Quiet metadata footer (created/updated by + at) — deliberately muted and
/// unshadowed so it reads as an audit trail, not primary document content.
class _RecordInfoFooter extends StatelessWidget {
  const _RecordInfoFooter({required this.record});

  final PremiseDetailRecord record;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final createdStamp = formatAuditStamp(record.createdAt);
    final updatedStamp = formatAuditStamp(record.updatedAt);
    final lines = <String>[
      if (record.createdBy != null) 'Created by ${record.createdBy}${createdStamp != null ? ' · $createdStamp' : ''}',
      if (record.updatedBy != null) 'Updated by ${record.updatedBy}${updatedStamp != null ? ' · $updatedStamp' : ''}',
    ];
    if (lines.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(line, style: textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.45))),
            ),
        ],
      ),
    );
  }
}
