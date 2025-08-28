import 'package:flutter/material.dart';

import '../component/app_route_observer.dart';
import 'base_controller.dart';

abstract class BasePage<Controller extends BaseController>
    extends StatelessWidget {
  final Controller controller;

  const BasePage({super.key, required this.controller});

  void initPage(BuildContext context) {}

  Widget buildPage(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return _BasePageWrapper(
      controller: controller,
      page: buildPage(context),
      initPage: initPage,
    );
  }
}

class _BasePageWrapper<Controller extends BaseController>
    extends StatefulWidget {
  final Controller controller;
  final Widget page;
  final Function(BuildContext context) initPage;

  const _BasePageWrapper({
    super.key,
    required this.controller,
    required this.page,
    required this.initPage,
  });

  @override
  State<_BasePageWrapper> createState() => _BasePageWrapperState();
}

class _BasePageWrapperState extends State<_BasePageWrapper>
    with WidgetsBindingObserver, RouteAware, TickerProviderStateMixin {
  PageRoute? _route;
  bool _isVisible = false;
  bool _isInitFirstFrameCallback = false;
  bool _isAppInForeground = true;

  bool get isTopPage =>
      _route != null && appRouteObserver.currentTopRoute == _route;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller.initTickerProvider(this);
    widget.controller.onInit();
    widget.initPage?.call(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      _route = route;
      appRouteObserver.subscribe(this, route);

      // 确保在路由订阅后调用 onFirstFrameRendering
      if (!_isInitFirstFrameCallback) {
        _isInitFirstFrameCallback = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            widget.controller.onFirstFrameRendering();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.page;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_route != null) {
      appRouteObserver.unsubscribe(this);
    }
    _route = null;
    widget.controller.onClose();
    super.dispose();
  }

  @override
  void didPop() {
    // Logger().i("didPop - $_route");
    _updateVisibility();
  }

  @override
  void didPush() {
    // Logger().i("didPush - $_route");
    _updateVisibility();
  }

  @override
  void didPushNext() {
    // Logger().i("didPushNext - $_route");
    _updateVisibility();
  }

  @override
  void didPopNext() {
    // Logger().i("didPopNext - $_route");
    _updateVisibility();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Logger().i("didChangeAppLifecycleState: $state");
    if (!isTopPage) return;
    switch (state) {
      case AppLifecycleState.resumed: // 应用回到前台
        _isAppInForeground = true;
        break;
      case AppLifecycleState.paused: // 应用进入后台
      case AppLifecycleState.hidden:
      case AppLifecycleState.inactive: // 下拉通知栏、多任务、锁屏
        _isAppInForeground = false;
        break;
      case AppLifecycleState.detached: // App 即将销毁
        break;
    }
    _updateVisibility();
  }

  void updateItemVisibility(bool visible) {
    final nowVisible =
        visible && _isAppInForeground && (_route?.isCurrent ?? false);
    _updateVisibilityReal(nowVisible);
  }

  void _updateVisibility() {
    final nowVisible = _isAppInForeground && (_route?.isCurrent ?? false);
    _updateVisibilityReal(nowVisible);
  }

  void _updateVisibilityReal(bool visible) {
    if (_isVisible == visible) return;
    _isVisible = visible;
    widget.controller.onUpdateVisible(visible);
  }
}
