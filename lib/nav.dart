import 'package:dashboard/pages/event_detail_page.dart';
import 'package:dashboard/pages/events_page.dart';
import 'package:dashboard/pages/map_page.dart';
import 'package:dashboard/pages/reports_page.dart';
import 'package:dashboard/pages/settings_page.dart';
import 'package:dashboard/pages/shell_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.map,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShellPage(child: child),
        routes: [
          GoRoute(path: AppRoutes.map, name: 'map', pageBuilder: (context, state) => const NoTransitionPage(child: MapPage())),
          GoRoute(
            path: AppRoutes.events,
            name: 'events',
            pageBuilder: (context, state) => const NoTransitionPage(child: EventsPage()),
            routes: [
              GoRoute(
                path: ':id',
                name: 'event_detail',
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return CustomTransitionPage(
                    child: EventDetailPage(eventId: id),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
                      return FadeTransition(opacity: curved, child: SlideTransition(position: Tween(begin: const Offset(0.02, 0.02), end: Offset.zero).animate(curved), child: child));
                    },
                  );
                },
              ),
            ],
          ),
          GoRoute(path: AppRoutes.reports, name: 'reports', pageBuilder: (context, state) => const NoTransitionPage(child: ReportsPage())),
          GoRoute(path: AppRoutes.settings, name: 'settings', pageBuilder: (context, state) => const NoTransitionPage(child: SettingsPage())),
        ],
      ),
    ],
  );
}

class AppRoutes {
  static const String map = '/map';
  static const String events = '/events';
  static const String reports = '/reports';
  static const String settings = '/settings';
}
