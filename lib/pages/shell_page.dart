import 'package:dashboard/nav.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:dashboard/pages/events_page.dart';
import 'package:dashboard/pages/map_page.dart';
import 'package:dashboard/pages/reports_page.dart';
import 'package:dashboard/pages/settings_page.dart';

class AppShellPage extends StatelessWidget {
  final Widget child;
  const AppShellPage({super.key, required this.child});

  static const _tabs = <_ShellTabData>[
    _ShellTabData(route: AppRoutes.map, icon: Icons.location_on_outlined, label: 'Bản đồ'),
    _ShellTabData(route: AppRoutes.events, icon: Icons.list_alt_outlined, label: 'Sự kiện'),
    _ShellTabData(route: AppRoutes.reports, icon: Icons.insert_chart_outlined, label: 'Báo cáo'),
    _ShellTabData(route: AppRoutes.settings, icon: Icons.settings_outlined, label: 'Cài đặt'),
  ];

  int _indexForLocation(String location) {
    for (var i = 0; i < _tabs.length; i++) {
      final r = _tabs[i].route;
      if (location == r || location.startsWith('$r/')) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexForLocation(location);
    final cs = Theme.of(context).colorScheme;
    final hideNav = RegExp(r'/events/[^/]+').hasMatch(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: hideNav ? null : Container(
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(top: BorderSide(color: cs.outline.withValues(alpha: 0.12))),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            height: 64,
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              final route = _tabs[index].route;
              if (route == AppRoutes.map) {
                context.go(AppRoutes.map);
              } else if (route == AppRoutes.events) {
                context.go(AppRoutes.events);
              } else if (route == AppRoutes.reports) {
                context.go(AppRoutes.reports);
              } else {
                context.go(AppRoutes.settings);
              }
            },
            destinations: [
              for (final t in _tabs) NavigationDestination(icon: Icon(t.icon), label: t.label),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShellTabData {
  final String route;
  final IconData icon;
  final String label;
  const _ShellTabData({required this.route, required this.icon, required this.label});
}