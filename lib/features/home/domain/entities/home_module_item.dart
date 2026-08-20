import 'package:flutter/material.dart';

class HomeModuleItem {
  const HomeModuleItem({required this.id, required this.title, required this.icon, this.route, this.permission});

  final String id;
  final String title;
  final IconData icon;

  /// When null, the item is shown but not yet navigable.
  final String? route;

  /// When set, the item is only shown if the user has this permission.
  final String? permission;

  bool isVisibleFor(List<String> permissions) {
    final required = permission;
    if (required == null) return true;
    return permissions.contains(required);
  }
}
