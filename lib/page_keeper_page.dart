part of 'page_keeper.dart';

abstract class PageKeeperPage<T> extends Page<T> {
  PageKeeperPage({
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final popCompleter = Completer<T?>();

  Route<T> buildRoute(BuildContext context);

  bool isChildOfType(Type t);

  @override
  Route<T> createRoute(BuildContext context) {
    final route = buildRoute(context);
    route.popped.then((value) => popCompleter.complete(value));
    return route;
  }
}
