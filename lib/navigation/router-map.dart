import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:groceryapp/screens/browse_screen.dart';
import 'package:groceryapp/screens/profile_screen.dart';
import 'package:groceryapp/screens/stores_screen.dart';

import '../screens/shoping_list_screen.dart';
import '../screens/sign_in_screen.dart';
import '../screens/tab_layout.dart';

enum AppRoute {
  auth("/auth"),
  browse("/"),
  stores("/stores"),
  list("/list", subPaths: ["/chat"]),
  profile("/profile");

  final String path;
  final List<String> subPaths;

  const AppRoute(this.path, {this.subPaths = const []});
}

final GoRouter appRouterMap = GoRouter(
  initialLocation: AppRoute.browse.path,
  routes: [
    GoRoute(
      path: AppRoute.auth.path,
      builder: (context, state) {
        return SignInScreen();
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => TabLayout(navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoute.browse.path,
              builder: (context, state) {
                return BrowseScreen();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoute.stores.path,
              builder: (context, state) {
                return const StoresScreen();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoute.list.path,
              builder: (context, state) {
                return ShoppingListScreen();
              },
            ),
            // GoRoute(
            //   path: AppRoute.chat.path,
            //   builder: (context, state) {
            //     return ChatScreen();
            //   },
            // ),
            // GoRoute(
            //   path: "/dog",
            //   builder: (context, state) {
            //     return Placeholder();
            //   },
            // ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoute.profile.path,
              builder: (context, state) {
                return const ProfileScreen();
              },
            ),
          ],
        ),
      ],
    ),
  ],
);