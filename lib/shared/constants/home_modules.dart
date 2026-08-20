import 'package:flutter/material.dart';

/// Metadata for a census module shown on the home screen and module pages.
class HomeModule {
  const HomeModule({
    required this.id,
    required this.permission,
    required this.title,
    required this.icon,
    required this.color,
  });

  final String id;
  final String permission;
  final String title;
  final IconData icon;
  final Color color;
}

const homeModules = <HomeModule>[
  HomeModule(
    id: 'premise',
    permission: 'view-mobile-premise',
    title: 'Premise Census',
    icon: Icons.storefront_outlined,
    color: Color(0xFF2E7D32),
  ),
  HomeModule(
    id: 'billboard',
    permission: 'view-mobile-billboard',
    title: 'Billboard Census',
    icon: Icons.campaign_outlined,
    color: Color(0xFF1565C0),
  ),
  HomeModule(
    id: 'investigation',
    permission: 'view-mobile-investigation',
    title: 'Investigation Census',
    icon: Icons.travel_explore_outlined,
    color: Color(0xFF6A1B9A),
  ),
];

final homeModulesById = {for (final module in homeModules) module.id: module};

HomeModule? homeModuleForPermission(String permission) {
  for (final module in homeModules) {
    if (module.permission == permission) return module;
  }
  return null;
}

List<HomeModule> homeModulesForPermissions(List<String> permissions) {
  final modules = <HomeModule>[];
  for (final permission in permissions) {
    final module = homeModuleForPermission(permission);
    if (module != null) modules.add(module);
  }
  return modules;
}
