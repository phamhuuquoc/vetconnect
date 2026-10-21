import 'package:flutter/widgets.dart';
import '../data/app_data_repository.dart';

/// Makes cached Firestore snapshots reactive on every route, including dialogs
/// and pages opened from the clinic search.
class AppDataScope extends InheritedNotifier<ValueNotifier<int>> {
  AppDataScope({super.key, required super.child})
      : super(notifier: AppDataRepository.revision);
  static void watch(BuildContext context) {
    context.dependOnInheritedWidgetOfExactType<AppDataScope>();
  }
}
