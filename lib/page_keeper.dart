library page_keeper;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show MaterialRouteTransitionMixin;
import 'package:flutter/cupertino.dart' show CupertinoRouteTransitionMixin;

part 'page_keeper_page.dart';
part 'full_page.dart';
part 'dialog_page.dart';
part 'bottom_sheet_page.dart';

abstract class PageKeeper {
  static late _RouterDelegate _delegate;
  static RouterConfig<Uri>? _routerConfig;

  /// Create a router config for use with MaterialApp.router.
  ///
  /// Note: This method caches the RouterConfig. Subsequent calls return
  /// the same instance to prevent navigation state from being reset on rebuilds.
  ///
  /// Example:
  /// ```dart
  /// MaterialApp.router(
  ///   routerConfig: PageKeeper.config(
  ///     pages: [PageKeeper.page(child: Splash(), type: PageType.cupertino)],
  ///     onDeepLink: (uri) => handleDeepLink(uri),
  ///     builder: (navigator) => MyWrapper(child: navigator),
  ///   ),
  /// )
  /// ```
  static RouterConfig<Uri> config({
    required List<PageKeeperPage> pages,
    void Function(List<PageKeeperPage<dynamic>> pages)? onNavigate,
    void Function(Uri uri)? onDeepLink,
    Widget Function(Widget navigator)? builder,
  }) {
    // Return cached config if already created
    if (_routerConfig != null) {
      return _routerConfig!;
    }

    _delegate = _RouterDelegate(
      initialPages: pages,
      onNavigate: onNavigate,
      onDeepLink: onDeepLink,
      builder: builder,
    );

    _routerConfig = RouterConfig(
      routeInformationProvider: PlatformRouteInformationProvider(
        initialRouteInformation: RouteInformation(
          uri: Uri.parse(
              WidgetsBinding.instance.platformDispatcher.defaultRouteName),
        ),
      ),
      routeInformationParser: const _RouteParser(),
      routerDelegate: _delegate!,
      backButtonDispatcher: RootBackButtonDispatcher(),
    );

    return _routerConfig!;
  }

  /// Navigate to a new page, adding it to the stack.
  static Future<T?> navigate<T>(PageKeeperPage<T> page) =>
      _delegate.navigate(page);

  /// Replace the top page with a new page.
  static Future<T?> replace<T>(PageKeeperPage<T> page) =>
      _delegate.replace(page);

  /// Replace the entire stack with a single page.
  static Future<T?> only<T>(PageKeeperPage<T> page) => _delegate.only(page);

  /// Reset the entire navigation stack.
  static void reset(List<PageKeeperPage> pages) => _delegate.reset(pages);

  /// Pop the top page from the stack.
  static void pop([dynamic result]) => _delegate.pop(result);

  /// Try to pop the top page, returns false if it can't be popped.
  static Future<bool> maybePop([dynamic result]) => _delegate.maybePop(result);

  /// Check if the stack contains a page of the given type.
  static bool containsPage(Type type) => _delegate.containsPage(type);

  /// Check if the topmost page is of the given type.
  static bool isTopmostPage(Type type) => _delegate.isTopmostPage(type);

  /// Remove the first page of the given type from the stack.
  static bool popFirstOfPage(Type type) => _delegate.popFirstOfPage(type);

  /// Insert an overlay entry into the navigator's overlay.
  static void insertOverlay(OverlayEntry entry) {
    _delegate.navigatorKey.currentState!.overlay!.insert(entry);
  }

  /// Create a page for use with PageKeeper.
  static PageKeeperPage<T> page<T>({
    required Widget child,
    required PageType type,
    LocalKey? key,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    bool maintainState = true,
  }) {
    late PageKeeperPage<T> pageRoute;
    if (type == PageType.cupertino || type == PageType.material) {
      pageRoute = FullPage(
        child: child,
        name: child.runtimeType.toString(),
        key: key,
        kind: type,
        transitionDuration: transitionDuration,
        maintainState: maintainState,
      );
    } else if (type == PageType.dialog) {
      pageRoute = DialogPage(
        child: child,
        name: child.runtimeType.toString(),
        key: key,
      );
    } else if (type == PageType.bottomsheet) {
      pageRoute = BottomSheetPage(
        child: child,
        name: child.runtimeType.toString(),
        transitionDuration: transitionDuration,
        reverseTransitionDuration: reverseTransitionDuration,
        key: key,
      );
    }
    return pageRoute;
  }
}

/// Router delegate that manages PageKeeper navigation and handles deep links.
class _RouterDelegate extends RouterDelegate<Uri>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Uri> {
  _RouterDelegate({
    required List<PageKeeperPage> initialPages,
    this.onNavigate,
    this.onDeepLink,
    this.builder,
  }) : _pages = [...initialPages] {
    _notifyNavigationChange();
  }

  List<PageKeeperPage<dynamic>> _pages;
  final void Function(List<PageKeeperPage<dynamic>> pages)? onNavigate;

  /// Called when a deep link is received from the system.
  final void Function(Uri uri)? onDeepLink;

  /// Optional builder to wrap the Navigator widget.
  final Widget Function(Widget navigator)? builder;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Current configuration - returns null since PageKeeper manages its own state
  /// and we don't want to sync with the browser URL bar by default.
  @override
  Uri? get currentConfiguration => null;

  /// Called when a deep link arrives.
  @override
  Future<void> setNewRoutePath(Uri uri) async {
    if (uri.path.isEmpty || uri.path == '/') return;
    onDeepLink?.call(uri);
  }

  void _notifyNavigationChange() {
    try {
      onNavigate?.call(_pages);
    } catch (e, st) {
      if (kDebugMode) {
        print('PageKeeper onNavigate error: $e\n$st');
      }
    }
  }

  /// Navigate to a new page, adding it to the stack.
  Future<T?> navigate<T>(PageKeeperPage<T> page) async {
    _pages = [..._pages, page];
    notifyListeners();
    _notifyNavigationChange();
    return await page.popCompleter.future;
  }

  /// Replace the top page with a new page.
  Future<T?> replace<T>(PageKeeperPage<T> page) async {
    _pages = [..._pages.sublist(0, _pages.length - 1), page];
    notifyListeners();
    _notifyNavigationChange();
    return await page.popCompleter.future;
  }

  /// Replace the entire stack with a single page.
  Future<T?> only<T>(PageKeeperPage<T> page) async {
    _pages = [page];
    notifyListeners();
    _notifyNavigationChange();
    return await page.popCompleter.future;
  }

  /// Reset the entire navigation stack.
  void reset(List<PageKeeperPage> pages) {
    _pages = [...pages];
    notifyListeners();
    _notifyNavigationChange();
  }

  /// Pop the top page from the stack.
  void pop([dynamic result]) {
    navigatorKey.currentState!.pop(result);
  }

  /// Try to pop the top page, returns false if it can't be popped.
  Future<bool> maybePop([dynamic result]) async {
    return await navigatorKey.currentState!.maybePop(result);
  }

  /// Remove the first page of the given type from the stack.
  bool popFirstOfPage(Type type) {
    int i = _pages.lastIndexWhere((e) => e.child.runtimeType == type);
    if (i == -1) return false;

    _pages.removeAt(i);
    _pages = [..._pages];
    notifyListeners();
    _notifyNavigationChange();

    return true;
  }

  /// Check if the stack contains a page of the given type.
  bool containsPage(Type type) {
    return _pages.any((e) => e.child.runtimeType == type);
  }

  /// Check if the topmost page is of the given type.
  bool isTopmostPage(Type type) {
    return _pages.last.child.runtimeType == type;
  }

  void _onDidRemovePage(Page<Object?> page) {
    final removed = _pages.remove(page);
    if (!removed) {
      return;
    }

    _pages = [..._pages];
    notifyListeners();
    _notifyNavigationChange();
  }

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator(
      key: navigatorKey,
      pages: _pages,
      onDidRemovePage: _onDidRemovePage,
    );

    return builder?.call(navigator) ?? navigator;
  }
}

/// Minimal route parser that passes through the Uri without transformation.
class _RouteParser extends RouteInformationParser<Uri> {
  const _RouteParser();

  @override
  Future<Uri> parseRouteInformation(RouteInformation routeInformation) async {
    return routeInformation.uri;
  }

  @override
  RouteInformation restoreRouteInformation(Uri configuration) {
    return RouteInformation(uri: configuration);
  }
}
