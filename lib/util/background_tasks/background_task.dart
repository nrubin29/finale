import 'package:meta/meta.dart';
import 'package:workmanager/workmanager.dart';

abstract class BackgroundTask {
  final String name;

  final Duration frequency;

  const BackgroundTask(String name, {required this.frequency})
    : name = 'com.nrubintech.finale.$name';

  Future<bool> isEnabled();

  @mustCallSuper
  Future<void> setup() async {
    await register();
  }

  Future<bool> run();

  @protected
  @nonVirtual
  Future<void> cancel() async {
    await Workmanager().cancelByUniqueName(name);
  }

  /// Registers the task with [Workmanager] if it should be enabled.
  ///
  /// If [isEnabled] returns `false`, the task will be cancelled and won't be
  /// registered.
  @protected
  @nonVirtual
  Future<void> register() async {
    await cancel();

    if (!await isEnabled()) return;

    await Workmanager().registerPeriodicTask(
      name,
      name,
      frequency: frequency,
      constraints: Constraints(
        networkType: .connected,
        requiresCharging: false,
      ),
    );
  }
}
