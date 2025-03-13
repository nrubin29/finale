import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:workmanager/workmanager.dart';

abstract class BackgroundTask {
  final String name;

  const BackgroundTask(String name) : name = 'com.nrubintech.finale.$name';

  Future<bool> get shouldRun;

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

  /// Registers the task with [Workmanager] if it should run.
  ///
  /// If [shouldRun] is `false`, the task will be cancelled and won't be
  /// registered.
  @protected
  @nonVirtual
  Future<void> register({Duration initialDelay = Duration.zero}) async {
    await cancel();

    if (!await shouldRun) return;

    try {
      await Workmanager().registerOneOffTask(
        name,
        name,
        initialDelay: initialDelay,
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresCharging: false,
        ),
      );
    } on PlatformException {
      if (kDebugMode) {
        print(
          'Unable to register background task. This is expected in the '
          'simulator.',
        );
      }
    }
  }
}
