import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.envName});

  final String envName;

  static const _features = [
    _Feature(Icons.menu_book_outlined, 'Courses', 'Browse your enrolled courses'),
    _Feature(Icons.assignment_outlined, 'Assignments', 'Track pending tasks'),
    _Feature(Icons.grade_outlined, 'Grades', 'View your performance'),
    _Feature(Icons.people_outline, 'Classmates', 'Connect with peers'),
    _Feature(Icons.event_outlined, 'Schedule', 'Upcoming classes & events'),
    _Feature(Icons.settings_outlined, 'Settings', 'Manage your preferences'),
  ];

  Color _envColor(ColorScheme cs) {
    return switch (envName) {
      'dev' => Colors.blueAccent,
      'stg' => Colors.orangeAccent,
      _ => cs.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final envColor = _envColor(cs);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ILMS'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              label: Text(
                envName.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  fontSize: 12,
                ),
              ),
              backgroundColor: envColor.withValues(alpha: 0.16),
              labelStyle: TextStyle(color: envColor),
              side: BorderSide(color: envColor.withValues(alpha: 0.5)),
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: cs.secondary, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/logo.png',
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Icon(
                          Icons.apps_sharp,
                          size: 28,
                          color: cs.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome to ILMS',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your learning hub — all in one place.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.35,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final feature = _features[index];
                    return Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${feature.title} coming soon.')),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                feature.icon,
                                size: 28,
                                color: cs.primary,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                feature.title,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                feature.subtitle,
                                style: textTheme.bodySmall?.copyWith(
                                  color: cs.onSurface.withValues(alpha: 0.55),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: _features.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _Feature {
  const _Feature(this.icon, this.title, this.subtitle);

  final IconData icon;
  final String title;
  final String subtitle;
}
