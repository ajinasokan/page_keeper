part of 'page_keeper.dart';

class DialogPage<T> extends PageKeeperPage<T> {
  DialogPage({
    super.key,
    required this.child,
    required super.name,
    this.barrierDismissible = true,
  });

  final Widget child;

  final bool barrierDismissible;

  @override
  bool isChildOfType(Type t) => child.runtimeType == t;

  @override
  Route<T> buildRoute(BuildContext context) {
    return RawDialogRoute(
      settings: this,
      barrierDismissible: barrierDismissible,
      pageBuilder: (context, animation, secondaryAnimation) => child,
    );
  }
}
