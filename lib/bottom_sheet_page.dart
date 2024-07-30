part of 'page_keeper.dart';

class BottomSheetPage<T> extends PageKeeperPage<T> {
  BottomSheetPage({
    super.key,
    required this.child,
    required super.name,
    this.transitionDuration,
    this.reverseTransitionDuration,
  });

  final Widget child;

  final Duration? transitionDuration;

  final Duration? reverseTransitionDuration;

  @override
  bool isChildOfType(Type t) => child.runtimeType == t;

  @override
  Route<T> buildRoute(BuildContext context) {
    return _BottomSheetPageRoute(
      settings: this,
      page: this,
      transitionDuration:
          transitionDuration ?? const Duration(milliseconds: 300),
      reverseTransitionDuration:
          reverseTransitionDuration ?? const Duration(milliseconds: 300),
    );
  }
}

class _BottomSheetPageRoute<T> extends PageRoute<T> {
  _BottomSheetPageRoute({
    super.settings,
    required this.page,
    this.barrierColor,
    this.barrierLabel,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.reverseTransitionDuration = const Duration(milliseconds: 300),
  });

  final BottomSheetPage page;

  @override
  final Duration transitionDuration;

  @override
  final Duration reverseTransitionDuration;

  @override
  final bool opaque = false;

  @override
  final bool barrierDismissible = false;

  @override
  final Color? barrierColor;

  @override
  final String? barrierLabel;

  @override
  final bool maintainState = true;

  @override
  String get debugLabel => '${super.debugLabel}(${page.name})';

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return page.child;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return Container(
      color: const Color(0x00000000).withAlpha((125 * animation.value).toInt()),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.fastOutSlowIn,
          ),
        ),
        child: child,
      ),
    );
  }
}
