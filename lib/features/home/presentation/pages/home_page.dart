import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ilms/features/auth/domain/entities/auth_user.dart';
import 'package:ilms/features/auth/presentation/providers/auth_providers.dart';
import 'package:ilms/features/billboard/presentation/widgets/billboard_home_section.dart';
import 'package:ilms/features/investigation/presentation/widgets/investigation_home_section.dart';
import 'package:ilms/features/premise/presentation/widgets/premise_home_section.dart';
import 'package:ilms/features/profile/presentation/widgets/profile_tab_view.dart';
import 'package:ilms/shared/constants/home_modules.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with SingleTickerProviderStateMixin {
  static const _bannerExpandedHeight = 200.0;

  final _scrollController = ScrollController();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    if (user == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: _bannerExpandedHeight,
            backgroundColor: cs.primary,
            centerTitle: true,
            // FlexibleSpaceBar's own title only repositions/rescales on
            // collapse — it never actually goes transparent — so the
            // hide-while-expanded/fade-in-on-collapse has to be driven by
            // hand from the real scroll offset. AnimatedBuilder rebuilds
            // just this Opacity every scroll tick, so it tracks the
            // gesture 1:1 instead of lagging behind it.
            title: AnimatedBuilder(
              animation: _scrollController,
              builder: (context, child) {
                final fadeDistance = _bannerExpandedHeight - kToolbarHeight;
                final offset = _scrollController.hasClients ? _scrollController.offset : 0.0;
                final opacity = fadeDistance <= 0 ? 1.0 : (offset / fadeDistance).clamp(0.0, 1.0);
                return Opacity(opacity: opacity, child: child);
              },
              child: Text(
                'ILMS',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  ShaderMask(
                    shaderCallback: (rect) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Colors.white, Colors.transparent],
                      stops: [0, 0.5, 1],
                    ).createShader(rect),
                    blendMode: BlendMode.dstIn,
                    child: Opacity(opacity: 0.5, child: Image.asset('assets/banner.jpeg', fit: BoxFit.cover)),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [cs.primary.withValues(alpha: 0.5), Colors.transparent],
                        stops: const [0, 0.55],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: cs.onPrimary,
              indicatorWeight: 3,
              labelColor: cs.onPrimary,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
              tabs: const [
                Tab(text: 'Dashboard'),
                Tab(text: 'Profile'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _DashboardTab(user: user),
            ProfileTabView(tabController: _tabController, tabIndex: 1),
          ],
        ),
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final visibleModules = homeModulesForPermissions(user.permissions);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Welcome back', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            'Here is your account overview.',
            style: textTheme.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
          ),
          if (visibleModules.isNotEmpty) ...[
            const SizedBox(height: 16),
            const PremiseHomeSection(),
            const BillboardHomeSection(),
            const InvestigationHomeSection(),
          ],
        ],
      ),
    );
  }
}
