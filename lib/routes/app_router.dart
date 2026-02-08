import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/alerts/presentation/screens/alerts_screen.dart';
import '../features/portfolio/presentation/screens/portfolio_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/watchlist/presentation/screens/watchlist_screen.dart';
import '../shared/widgets/app_bottom_nav.dart';

/// go_router による宣言的ルーティング定義。
/// ルートはここに集約する。4タブは StatefulShellRoute で構成する。
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (
        BuildContext context,
        GoRouterState state,
        StatefulNavigationShell navigationShell,
      ) {
        return AppBottomNav(navigationShell: navigationShell);
      },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/',
              name: 'portfolio',
              builder: (context, state) => const PortfolioScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/watchlist',
              name: 'watchlist',
              builder: (context, state) => const WatchlistScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/alerts',
              name: 'alerts',
              builder: (context, state) => const AlertsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/settings',
              name: 'settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
