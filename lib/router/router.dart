import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_app/pages/detail/view.dart';
import 'package:miru_app/pages/extension/view.dart';
import 'package:miru_app/pages/extension_repo/view.dart';
import 'package:miru_app/pages/extension_settings/view.dart';
import 'package:miru_app/pages/home/view.dart';
import 'package:miru_app/pages/main/view.dart';
import 'package:miru_app/pages/search/pages/search_extension.dart';
import 'package:miru_app/pages/search/view.dart';
import 'package:miru_app/pages/settings/view.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return DesktopMainPage(
          shellContext: _shellNavigatorKey.currentContext,
          state: state,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => _animation(const HomePage()),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => _animation(const SearchPage()),
        ),
        GoRoute(
          path: '/search_extension',
          builder: (context, state) => _animation(
            SearchExtensionPage(
              package: state.queryParameters['package']!,
              keyWord: state.queryParameters['keyWord'],
            ),
          ),
        ),
        GoRoute(
          path: '/extension',
          builder: (context, state) => _animation(const ExtensionPage()),
        ),
        GoRoute(
          path: '/extension_settings',
          builder: (context, state) => _animation(
            ExtensionSettingsPage(
              package: state.queryParameters['package']!,
            ),
          ),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => _animation(const SettingsPage()),
        ),
        GoRoute(
          path: '/extension_repo',
          builder: (context, state) => _animation(const ExtensionRepoPage()),
        ),
        GoRoute(
          path: '/detail',
          builder: (context, state) => _animation(
            DetailPage(
              url: state.queryParameters['url']!,
              package: state.queryParameters['package']!,
            ),
          ),
        ),
      ],
    )
  ],
);

_animation(Widget child) {
  return Animate(
    child: child,
  ).moveY(
    begin: 40,
    end: 0,
    curve: Curves.easeOutCubic,
  );
}
