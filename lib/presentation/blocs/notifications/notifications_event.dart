part of 'notifications_bloc.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();
}

class NotificationStatusChanged extends NotificationsEvent {
  final AuthorizationStatus status;

  const NotificationStatusChanged(this.status);

  @override
  List<Object> get props => [status];
}

class NotificationReceived extends NotificationsEvent {
  final PushMessage pushMessage;

  const NotificationReceived(this.pushMessage);

  @override
  List<Object> get props => [pushMessage];
}
