import 'package:flutter/material.dart';

final AppRouteObserver appRouteObserver = AppRouteObserver();

class AppRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  PageRoute? _currentTopRoute;

  PageRoute? get currentTopRoute => _currentTopRoute;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _currentTopRoute = route;
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute) {
      _currentTopRoute = previousRoute;
    } else {
      _currentTopRoute = null;
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute) {
      _currentTopRoute = newRoute;
    }
  }
}
