import 'package:equatable/equatable.dart';

abstract class CheckInState extends Equatable {
  const CheckInState();

  @override
  List<Object?> get props => [];
}

/// Initial state (no active check-in)
class CheckInInitial extends CheckInState {}

/// While performing start/cancel actions
class CheckInInProgress extends CheckInState {}

/// Active check-in with reminders and auto-alert
class CheckInActive extends CheckInState {
  final DateTime remindAt;
  final DateTime autoAlertAt;

  const CheckInActive({
    required this.remindAt,
    required this.autoAlertAt,
  });

  @override
  List<Object?> get props => [remindAt, autoAlertAt];

  CheckInActive copyWith({
    DateTime? remindAt,
    DateTime? autoAlertAt,
  }) {
    return CheckInActive(
      remindAt: remindAt ?? this.remindAt,
      autoAlertAt: autoAlertAt ?? this.autoAlertAt,
    );
  }
}

/// When user confirms “I’m Safe” successfully
class CheckInCompleted extends CheckInState {}

/// Error case (e.g. scheduling failure, repo error)
class CheckInError extends CheckInState {
  final String message;
  const CheckInError(this.message);

  @override
  List<Object?> get props => [message];
}
