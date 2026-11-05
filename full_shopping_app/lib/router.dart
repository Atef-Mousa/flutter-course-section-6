import 'package:full_shopping_app/test.dart';
import 'package:go_router/go_router.dart';

import 'home_page.dart';
import 'login_page.dart';
import 'products_page.dart';

final router = GoRouter(
  redirect: (context, state) {
    var url = state.matchedLocation;
    if (url.startsWith("/home") && !Database.isLoggedIn) {
      print("we are in redirect");
      return "/login";
    }
    return null;
  },
  initialLocation: "/login",
  routes: [
    GoRoute(
      path: "/home",
      builder: (context, state) => HomePage(),
      routes: [
        GoRoute(path: 'products', builder: (context, state) => ProductsPage()),
      ],
    ),
    GoRoute(path: "/login", builder: (context, state) => LoginPage()),
  ],
);
