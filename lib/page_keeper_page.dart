part of 'page_keeper.dart';

abstract class PageKeeperPage<T> extends Page<T> {
  PageKeeperPage({
    LocalKey? key,
    super.name,
    super.arguments,
    super.restorationId,
    required this.child,
  }) : super(key: key ?? ValueKey("${child.runtimeType}"));

  final Widget child;

  final popCompleter = Completer<T?>();

  Route<T> buildRoute(BuildContext context);

  @override
  Route<T> createRoute(BuildContext context) {
    final route = buildRoute(context);
    route.popped.then((value) => popCompleter.complete(value));
    return route;
  }
}
