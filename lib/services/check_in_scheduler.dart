import 'dart:io';
import 'package:workmanager/workmanager.dart';
import 'check_in_repository.dart';

const String kCheckInAutoAlertTask = 'safeher_checkin_auto_alert';

class CheckInScheduler {
  static Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  }

  static Future<void> scheduleAutoAlert(DateTime at) async {
    if (Platform.isAndroid) {
      final delay = at.difference(DateTime.now());
      await Workmanager().registerOneOffTask(
        'auto_alert_${at.millisecondsSinceEpoch}',
        kCheckInAutoAlertTask,
        initialDelay: delay.isNegative ? const Duration(seconds: 1) : delay,
        constraints: Constraints(networkType: NetworkType.notRequired),
        backoffPolicy: BackoffPolicy.linear,
      );
    }
  }

  static Future<void> cancelAll() async {
    if (Platform.isAndroid) {
      await Workmanager().cancelAll();
    }
  }
}

/// Background entry point
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == kCheckInAutoAlertTask) {
      final repo = CheckInRepository();
      final active = await repo.getActive();
      if (active != null) {
        // If still active at this time, user did not confirm; send auto SOS.
        await repo.triggerSOSAuto('No response to check-in timer.');
        await repo.clear();
      }
    }
    return true;
  });
}
