import 'package:flutter/material.dart';
import 'package:ilms/app/router/app_routes.dart';
import 'package:ilms/features/home/data/datasources/home_menu_data_source.dart';
import 'package:ilms/features/home/domain/entities/home_module_group.dart';
import 'package:ilms/features/home/domain/entities/home_module_item.dart';

class MockHomeMenuDataSource implements HomeMenuDataSource {
  const MockHomeMenuDataSource();

  static final _groups = <HomeModuleGroup>[
    HomeModuleGroup(
      id: 'premise',
      permission: 'view-mobile-premise',
      title: 'Premise Census',
      icon: Icons.storefront_outlined,
      color: Color(0xFF2E7D32),
      items: [
        HomeModuleItem(
          id: 'premise-list',
          title: 'View All',
          icon: Icons.list_alt_outlined,
          route: AppRoutes.module('premise'),
        ),
        HomeModuleItem(
          id: 'premise-new',
          title: 'New Entry',
          icon: Icons.add_circle_outline,
          route: AppRoutes.premiseFormWithMode('create'),
        ),
        HomeModuleItem(id: 'premise-drafts', title: 'Drafts', icon: Icons.drafts_outlined),
      ],
    ),
    HomeModuleGroup(
      id: 'billboard',
      permission: 'view-mobile-billboard',
      title: 'Billboard Census',
      icon: Icons.campaign_outlined,
      color: Color(0xFF1565C0),
      items: [
        HomeModuleItem(
          id: 'billboard-list',
          title: 'View All',
          icon: Icons.list_alt_outlined,
          route: AppRoutes.module('billboard'),
        ),
        HomeModuleItem(id: 'billboard-new', title: 'New Entry', icon: Icons.add_circle_outline),
        HomeModuleItem(id: 'billboard-map', title: 'Map View', icon: Icons.map_outlined),
      ],
    ),
    HomeModuleGroup(
      id: 'investigation',
      permission: 'view-mobile-investigation',
      title: 'Investigation Census',
      icon: Icons.travel_explore_outlined,
      color: Color(0xFF6A1B9A),
      items: [
        HomeModuleItem(
          id: 'investigation-list',
          title: 'View All',
          icon: Icons.list_alt_outlined,
          route: AppRoutes.module('investigation'),
        ),
        HomeModuleItem(id: 'investigation-new', title: 'New Case', icon: Icons.add_circle_outline),
        HomeModuleItem(id: 'investigation-open', title: 'Open Cases', icon: Icons.folder_open_outlined),
      ],
    ),
  ];

  @override
  Future<List<HomeModuleGroup>> fetchGroups() async {
    return _groups;
  }
}
