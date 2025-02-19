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

class PageKeeper extends StatefulWidget {
  const PageKeeper({
    super.key,
    required this.pages,
  });

  final List<PageKeeperPage> pages;

  @override
  State<PageKeeper> createState() => PageKeeperState();

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

  static PageKeeperState of(BuildContext context) {
    return context.findAncestorStateOfType<PageKeeperState>()!;
  }

  static PageKeeperState? _pageKeeperRef;
  static PageKeeperState get instance => _pageKeeperRef!;
}

class PageKeeperState extends State<PageKeeper> with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();
  List<PageKeeperPage<dynamic>> _pages = [];

  Future<T?> navigate<T>(PageKeeperPage<T> page) async {
    _pages = [..._pages, page];
    setState(() {});
    return await page.popCompleter.future;
  }

  Future<T?> replace<T>(PageKeeperPage<T> page) async {
    _pages = [..._pages.sublist(0, _pages.length - 1), page];
    setState(() {});
    return await page.popCompleter.future;
  }

  Future<T?> only<T>(PageKeeperPage<T> page) async {
    _pages = [page];
    setState(() {});
    return await page.popCompleter.future;
  }

  void reset(List<PageKeeperPage> pages) {
    _pages = [...pages];
    setState(() {});
  }

  void pop([dynamic result]) {
    return _navigatorKey.currentState!.pop(result);
  }

  bool popFirstOfPage(Type type) {
    int i = _pages.lastIndexWhere((e) => e.child.runtimeType == type);
    if (i == -1) return false;

    _pages.removeAt(i);
    _pages = [..._pages];
    setState(() {});

    return true;
  }

  bool containsPage(Type type) {
    return _pages.any((e) => e.child.runtimeType == type);
  }

  bool isTopmostPage(Type type) {
    return _pages.last.child.runtimeType == type;
  }

  Future<bool> maybePop([dynamic result]) async {
    return await _navigatorKey.currentState!.maybePop(result);
  }

  void _onDidRemovePage(Page page) {
    _pages.remove(page);
    _pages = [..._pages];
  }

  @override
  void initState() {
    super.initState();
    PageKeeper._pageKeeperRef = this;
    _pages.addAll(widget.pages);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    PageKeeper._pageKeeperRef = null;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // back button handling
  @override
  Future<bool> didPopRoute() => _navigatorKey.currentState!.maybePop();

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print(
          "\x1b[36mNavigation: ${_pages.map((e) => e.name!).join(" → ")} \x1b[0m");
    }
    return Navigator(
      key: _navigatorKey,
      pages: _pages,
      onDidRemovePage: _onDidRemovePage,
    );
  }
}
