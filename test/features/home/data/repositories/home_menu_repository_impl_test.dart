import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/home/data/datasources/home_menu_data_source.dart';
import 'package:ilms/features/home/data/datasources/mock_home_menu_data_source.dart';
import 'package:ilms/features/home/data/repositories/home_menu_repository_impl.dart';
import 'package:ilms/features/home/domain/entities/home_module_group.dart';
import 'package:ilms/features/home/domain/entities/home_module_item.dart';

void main() {
  group('HomeMenuRepositoryImpl', () {
    late HomeMenuRepositoryImpl repository;

    setUp(() {
      repository = HomeMenuRepositoryImpl(const MockHomeMenuDataSource());
    });

    test('returns only groups matching user permissions', () async {
      final groups = await repository.getGroups(['view-mobile-premise']);

      expect(groups, hasLength(1));
      expect(groups.first.id, 'premise');
      expect(groups.first.title, 'Premise Census');
    });

    test('returns all groups when user has every permission', () async {
      final groups = await repository.getGroups([
        'view-mobile-premise',
        'view-mobile-billboard',
        'view-mobile-investigation',
      ]);

      expect(groups, hasLength(3));
      expect(groups.map((group) => group.id), ['premise', 'billboard', 'investigation']);
    });

    test('filters items by item-level permission when set', () async {
      final testRepository = HomeMenuRepositoryImpl(_RestrictedItemDataSource());

      final groups = await testRepository.getGroups(['view-mobile-premise']);

      expect(groups, hasLength(1));
      expect(groups.first.items, hasLength(1));
      expect(groups.first.items.first.id, 'premise-list');
    });
  });
}

class _RestrictedItemDataSource implements HomeMenuDataSource {
  @override
  Future<List<HomeModuleGroup>> fetchGroups() async {
    return const [
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
            route: '/module/premise',
          ),
          HomeModuleItem(
            id: 'premise-admin',
            title: 'Admin',
            icon: Icons.admin_panel_settings_outlined,
            permission: 'admin-premise',
          ),
        ],
      ),
    ];
  }
}
