import 'package:flutter/material.dart';
import 'package:ilms/features/home/presentation/home_modules.dart';
import 'package:ilms/shared/models/census_entry.dart';
import 'package:ilms/shared/ui/feedback/app_snackbar.dart';
import 'package:ilms/shared/ui/tiles/census_entry_tile.dart';
import 'package:ilms/features/home/presentation/widgets/module_summary_card.dart';

class InvestigationPage extends StatelessWidget {
  const InvestigationPage({super.key, required this.module});

  final HomeModule module;

  static const _entries = <CensusEntry>[
    CensusEntry(title: 'K1/2026', subtitle: 'Premis tidak berlesen, Jalan Amin', status: 'Open'),
    CensusEntry(title: 'K2/2026', subtitle: 'Aduan papan iklan haram', status: 'In Progress'),
    CensusEntry(title: 'K3/2026', subtitle: 'Siaran tanpa kebenaran', status: 'Closed'),
    CensusEntry(title: 'K4/2026', subtitle: 'Pendaftaran perusahaan', status: 'Open'),
    CensusEntry(title: 'K5/2026', subtitle: 'Tindakan penguatkuasaan', status: 'In Progress'),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final verified = _entries.where((entry) => entry.status == 'Closed').length;

    return Scaffold(
      appBar: AppBar(title: Text(module.title), centerTitle: false),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AppSnackbar.info(context, 'Add ${module.title} entry coming soon.'),
        tooltip: 'Add entry',
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          children: [
            ModuleSummaryCard(module: module, total: _entries.length, verified: verified),
            const SizedBox(height: 24),
            Text('Recent Entries', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            for (final entry in _entries) ...[
              CensusEntryTile(
                icon: module.icon,
                color: module.color,
                title: entry.title,
                subtitle: entry.subtitle,
                status: entry.status,
                onTap: () => AppSnackbar.info(context, '${entry.title} details coming soon.'),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}
