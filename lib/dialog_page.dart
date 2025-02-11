part of 'page_keeper.dart';

class DialogPage<T> extends PageKeeperPage<T> {
  DialogPage({
    super.key,
    required super.child,
    required super.name,
    this.barrierDismissible = true,
  });

  final bool barrierDismissible;

  @override
  Route<T> buildRoute(BuildContext context) {
    return RawDialogRoute(
      settings: this,
      barrierDismissible: barrierDismissible,
      pageBuilder: (context, animation, secondaryAnimation) => child,
    );
  }
}
