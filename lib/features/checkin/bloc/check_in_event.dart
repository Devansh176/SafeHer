import 'package:equatable/equatable.dart';

abstract class CheckInEvent extends Equatable {
  const CheckInEvent();
  @override
  List<Object?> get props => [];
}

class CheckInStart extends CheckInEvent {
  final Duration duration;     // e.g., 30 minutes
  final Duration gracePeriod;  // e.g., 5 minutes to auto-alert
  const CheckInStart({required this.duration, required this.gracePeriod});
}

class CheckInCancel extends CheckInEvent {
  const CheckInCancel();
}

class CheckInImSafe extends CheckInEvent {
  const CheckInImSafe();
}
