import 'package:flutter/material.dart';
import 'package:ilms/shared/constants/home_modules.dart';
import 'package:ilms/shared/models/census_entry.dart';
import 'package:ilms/shared/ui/feedback/app_snackbar.dart';
import 'package:ilms/shared/ui/home/home_module_summary_card.dart';
import 'package:ilms/shared/ui/tiles/census_entry_tile.dart';

class BillboardPage extends StatelessWidget {
  const BillboardPage({super.key, required this.module});

  final HomeModule module;

  static const _entries = <CensusEntry>[
    CensusEntry(title: 'Billboard A1', subtitle: 'Lebuhraya Utara KM 12', status: 'Verified'),
    CensusEntry(title: 'Papan Iklan Genting', subtitle: 'Jalan Genting Klang', status: 'Pending'),
    CensusEntry(title: 'LED Screen Sentral', subtitle: 'Stesen Sentral KL', status: 'Verified'),
    CensusEntry(title: 'Billboard Banjaran', subtitle: 'Persiaran Banjaran', status: 'Rejected'),
    CensusEntry(title: 'Mini Billboard Plaza', subtitle: 'Plaza Damas', status: 'Pending'),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final verified = _entries.where((entry) => entry.status == 'Verified').length;

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
            HomeModuleSummaryCard(module: module, total: _entries.length, verified: verified),
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
