import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ilms/app/router/app_routes.dart';
import 'package:ilms/features/home/presentation/home_modules.dart';
import 'package:ilms/shared/models/census_entry.dart';
import 'package:ilms/shared/ui/feedback/app_snackbar.dart';
import 'package:ilms/shared/ui/tiles/census_entry_tile.dart';
import 'package:ilms/features/home/presentation/widgets/module_summary_card.dart';

class PremisePage extends StatelessWidget {
  const PremisePage({super.key, required this.module});

  final HomeModule module;

  static const _entries = <CensusEntry>[
    CensusEntry(title: 'Kedai Runcit Ahmad', subtitle: 'Jalan Merdeka No. 12', status: 'Verified'),
    CensusEntry(title: 'Rumah Kedai Mutiara', subtitle: 'Jalan Pasar, Taman Mutiara', status: 'Pending'),
    CensusEntry(title: 'Gerai Nasi Lemak', subtitle: 'Lorong Haji Musa', status: 'Rejected'),
    CensusEntry(title: 'Taman Suria Store', subtitle: 'Blok 5, Taman Suria', status: 'Verified'),
    CensusEntry(title: 'Warung Kopi Senja', subtitle: 'Jalan Besar', status: 'Pending'),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final verified = _entries.where((entry) => entry.status == 'Verified').length;

    return Scaffold(
      appBar: AppBar(title: Text(module.title), centerTitle: false),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.premiseFormWithMode('create')),
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
