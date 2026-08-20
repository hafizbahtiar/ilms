import 'package:flutter/material.dart';
import 'package:ilms/features/home/domain/entities/home_module_item.dart';
import 'package:ilms/features/home/presentation/home_modules.dart';

class HomeModuleGroup {
  const HomeModuleGroup({
    required this.id,
    required this.permission,
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  final String id;
  final String permission;
  final String title;
  final IconData icon;
  final Color color;
  final List<HomeModuleItem> items;

  HomeModule toModule() {
    return HomeModule(id: id, permission: permission, title: title, icon: icon, color: color);
  }

  List<HomeModuleItem> visibleItemsFor(List<String> permissions) {
    return items.where((item) => item.isVisibleFor(permissions)).toList(growable: false);
  }
}
