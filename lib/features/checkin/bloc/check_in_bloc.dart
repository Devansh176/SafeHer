import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../services/notification_service.dart';
import '../../../services/check_in_repository.dart';
import '../../../services/check_in_scheduler.dart';
import 'check_in_event.dart';
import 'check_in_state.dart';

class CheckInBloc extends Bloc<CheckInEvent, CheckInState> {
  final CheckInRepository repo;
  final NotificationService notifications;

  CheckInBloc({
    required this.repo,
    required this.notifications,
  }) : super(CheckInInitial()) {
    on<CheckInStart>(_onStart);
    on<CheckInCancel>(_onCancel);
    on<CheckInImSafe>(_onImSafe);

    // Listen to notification actions
    notifications.checkInActions.listen((action) {
      if (action == CheckInAction.imSafe) add(CheckInImSafe());
    });

    _restore();
  }

  Future<void> _restore() async {
    final active = await repo.getActive();
    if (active != null) {
      final remindAt = DateTime.parse(active['remindAt'] as String);
      final autoAlertAt = DateTime.parse(active['autoAlertAt'] as String);
      emit(CheckInActive(remindAt: remindAt, autoAlertAt: autoAlertAt));
    }
  }

  Future<void> _onStart(CheckInStart e, Emitter<CheckInState> emit) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final remindAt = DateTime.now().add(e.duration);
    final autoAlertAt = remindAt.add(e.gracePeriod);

    await repo.saveActive(id: id, remindAt: remindAt, autoAlertAt: autoAlertAt);

    // ✅ smart scheduling (exact preferred, fallback if needed)
    await notifications.scheduleCheckInReminderSmart(
      notificationId: id.hashCode,
      when: remindAt,
    );

    await CheckInScheduler.scheduleAutoAlert(autoAlertAt);

    emit(CheckInActive(remindAt: remindAt, autoAlertAt: autoAlertAt));
  }

  Future<void> _onCancel(CheckInCancel e, Emitter<CheckInState> emit) async {
    final active = await repo.getActive();
    if (active != null) {
      await notifications.cancel((active['id'] as String).hashCode);
    }
    await CheckInScheduler.cancelAll();
    await repo.clear();
    emit(CheckInInitial());
  }

  Future<void> _onImSafe(CheckInImSafe e, Emitter<CheckInState> emit) async {
    await _onCancel(const CheckInCancel(), emit);
  }
}
