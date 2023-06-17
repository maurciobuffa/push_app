import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:push_app/config/local_notifications/local_notifications.dart';
import 'package:push_app/firebase_options.dart';

import 'package:push_app/domain/entities/push_message.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  int pushNumberId = 0;

  final Future<void> Function()? requestLocalNotificationPermissions;
  final void Function({
    required int id,
    String? title,
    String? body,
    String? data,
  })? showLocalNotification;

  NotificationsBloc({
    this.showLocalNotification,
    this.requestLocalNotificationPermissions,
  }) : super(const NotificationsState()) {
    on<NotificationStatusChanged>(_notificationStatusChanged);
    on<NotificationReceived>(_onPushMessageReceived);

    // TODO: Create listener _onPushMessageReceived

    _initialStatusCheck();
    _onForegroundMessage();
  }

  static Future<void> initializeFCM() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  void _notificationStatusChanged(
    NotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    if (event is NotificationStatusChanged) {
      emit(state.copyWith(status: event.status));
      _getFCMToken();
    }
  }

  void _onPushMessageReceived(
    NotificationReceived event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(
      notifications: [
        event.pushMessage,
        ...state.notifications,
      ],
    ));
  }

  void _initialStatusCheck() async {
    NotificationSettings settings = await messaging.getNotificationSettings();

    add(NotificationStatusChanged(settings.authorizationStatus));
  }

  void _getFCMToken() async {
    if (state.status != AuthorizationStatus.authorized) return;

    String? token = await messaging.getToken();

    print('FCM Token: $token');
  }

  void handleRemoteMessage(RemoteMessage message) {
    if (message.notification == null) return;

    final notification = PushMessage(
      messageId:
          message.messageId?.replaceAll(':', '').replaceAll('%', '') ?? '',
      title: message.notification!.title ?? '',
      body: message.notification!.body ?? '',
      sentDate: message.sentTime ?? DateTime.now(),
      data: message.data,
      imageUrl: Platform.isIOS
          ? message.notification!.apple?.imageUrl
          : message.notification!.android?.imageUrl,
    );

    if (showLocalNotification != null) {
      showLocalNotification!(
        id: ++pushNumberId,
        title: notification.title,
        body: notification.body,
        data: notification.messageId,
      );
    }

    // LocalNotifications.showLocalNotification(
    //   id: ++pushNumberId,
    //   title: notification.title,
    //   body: notification.body,
    //   data: notification.data.toString(),
    // );

    add(NotificationReceived(notification));
  }

  void _onForegroundMessage() {
    FirebaseMessaging.onMessage.listen(handleRemoteMessage);
  }

  void requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    // Request permission for local notifications
    if (requestLocalNotificationPermissions != null) {
      await requestLocalNotificationPermissions!();
      // await LocalNotifications.requestPermissionLocalNotifications();
    }

    add(NotificationStatusChanged(settings.authorizationStatus));
  }

  PushMessage? getMessageById(String pushMessageId) {
    final exists = state.notifications
        .any((element) => element.messageId == pushMessageId);

    if (!exists) return null;

    return state.notifications.firstWhere(
      (element) => element.messageId == pushMessageId,
    );
  }
}
