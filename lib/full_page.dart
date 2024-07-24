part of 'page_keeper.dart';

class FullPage<T> extends PageKeeperPage<T> {
  FullPage({
    required this.child,
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.allowSnapshotting = true,
    super.key,
    required super.name,
    super.arguments,
    super.restorationId,
    required this.kind,
    this.transitionDuration,
  });

  final PageType kind;

  final Duration? transitionDuration;

  final Widget child;

  final bool maintainState;

  final bool fullscreenDialog;

  final bool allowSnapshotting;

  @override
  bool isChildOfType(Type t) => child.runtimeType == t;

  @override
  Route<T> buildRoute(BuildContext context) {
    if (kind == PageType.cupertino) {
      return _CupertinoPageRoute(
        page: this,
        allowSnapshotting: allowSnapshotting,
        transitionDuration: transitionDuration,
      );
    }
    return _MaterialPageRoute(
      page: this,
      allowSnapshotting: allowSnapshotting,
      transitionDuration: transitionDuration,
    );
  }
}

class _MaterialPageRoute<T> extends PageRoute<T>
    with MaterialRouteTransitionMixin<T> {
  _MaterialPageRoute({
    required FullPage<T> page,
    super.allowSnapshotting,
    Duration? transitionDuration,
  })  : _transitionDuration = transitionDuration,
        super(settings: page) {
    assert(opaque);
  }

  final Duration? _transitionDuration;

  @override
  Duration get transitionDuration =>
      _transitionDuration ?? super.transitionDuration;

  FullPage<T> get _page => settings as FullPage<T>;

  @override
  Widget buildContent(BuildContext context) {
    return _page.child;
  }

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';
}

class _CupertinoPageRoute<T> extends PageRoute<T>
    with CupertinoRouteTransitionMixin<T> {
  _CupertinoPageRoute({
    required FullPage<T> page,
    super.allowSnapshotting = true,
    Duration? transitionDuration = const Duration(milliseconds: 500),
  })  : _transitionDuration = transitionDuration,
        super(settings: page) {
    assert(opaque);
  }

  final Duration? _transitionDuration;

  @override
  Duration get transitionDuration =>
      _transitionDuration ?? super.transitionDuration;

  FullPage<T> get _page => settings as FullPage<T>;

  @override
  Widget buildContent(BuildContext context) => _page.child;

  @override
  String? get title => null;

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';
}

enum PageType {
  material,
  cupertino,
  dialog,
  bottomsheet,
}
