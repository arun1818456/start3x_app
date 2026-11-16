import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:get_storage/get_storage.dart';
import 'package:start3x_app/app/constants/colors.dart';
import 'package:start3x_app/app/constants/local_keys.dart';
import 'package:start3x_app/app/routes/routes.dart';

class MyNotification {
  static const alertChannelId = "alert_channel";
  static const alertChannelName = "Alert Notifications";
  static const alertChannelDesc = "Notifications with sound and vibration";
  static const silentChannelId = "silent_channel";
  static const silentChannelName = "Silent Notifications";
  static const silentChannelDesc = "Notifications without sound or vibration";
  static final storage = GetStorage();
  static late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  static final Debouncer debounce = Debouncer(
    delay: const Duration(milliseconds: 750),
  );

  static StreamSubscription<RemoteMessage>? streamSubscription;
  static StreamSubscription<RemoteMessage>? streamSubscriptionOpenApp;

  static Future<void> firebaseNotification() async {
    try {
      final NotificationSettings settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      localNotification();

      streamSubscription?.cancel();
      streamSubscription = FirebaseMessaging.onMessage.listen((
        RemoteMessage message,
      ) {
        if (!kIsWeb && Platform.isAndroid) {
          RemoteNotification? notification = message.notification;
          if (notification != null) {
            showNotification(
              notification.hashCode,
              notification.title,
              notification.body,
              message.data,
            );
          }
        }
      });

      streamSubscriptionOpenApp?.cancel();
      streamSubscriptionOpenApp = FirebaseMessaging.onMessageOpenedApp.listen((
        RemoteMessage message,
      ) async {
        debounce(() {
          notificationNavigation(message.data);
        });
      });
    } catch (e) {
      debugPrint("🔥 Firebase notification init error: $e");
    }
  }

  static void localNotification() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (
        NotificationResponse notificationResponse,
      ) {
        storage.write(
          LocalKeys.notificationId,
          notificationResponse.id ?? "",
        );
        Map<String, dynamic> payload = {};
        try {
          if (notificationResponse.payload != null &&
              notificationResponse.payload!.isNotEmpty) {
            payload = jsonDecode(notificationResponse.payload!);
          }
        } catch (e) {
          debugPrint("Payload decode error: $e");
        }
        debounce(() {
          if (Get.isSnackbarOpen) {
            Get.back();
            Future.delayed(const Duration(milliseconds: 1000), () {
              notificationNavigation(payload);
            });
          } else {
            notificationNavigation(payload);
          }
        });
      },
    );

    if (!kIsWeb && Platform.isAndroid) {
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();

      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              alertChannelId,
              alertChannelName,
              description: alertChannelDesc,
              importance: Importance.max,
              playSound: true,
              enableVibration: true,
            ),
          );

      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              silentChannelId,
              silentChannelName,
              description: silentChannelDesc,
              importance: Importance.low,
              playSound: false,
              enableVibration: false,
            ),
          );
    }

    if (!kIsWeb && Platform.isIOS) {
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails()
        .then((value) {
          if (value != null &&
              value.notificationResponse != null &&
              value.didNotificationLaunchApp) {
            if (!storage.hasData(LocalKeys.notificationId) ||
                (storage.read(LocalKeys.notificationId) !=
                    value.notificationResponse?.id)) {
              storage.write(
                LocalKeys.notificationId,
                value.notificationResponse?.id ?? "",
              );
              Map<String, dynamic> payload = {};
              try {
                if (value.notificationResponse?.payload != null &&
                    value.notificationResponse!.payload!.isNotEmpty) {
                  payload = jsonDecode(value.notificationResponse!.payload!);
                }
              } catch (e) {
                debugPrint("Payload decode error: $e");
              }
              debounce(() {
                notificationNavigation(payload);
              });
            }
          }
        });
  }

  static void showNotification(
    int hashCode,
    String? title,
    String? body,
    Map<String, dynamic> payload,
  ) {
    String channelID = alertChannelId;
    String channelName = alertChannelName;
    String channelDesc = alertChannelDesc;
    Importance importance = Importance.max;
    Priority priority = Priority.high;
    bool playSound = true;
    bool enableVibration = true;

    flutterLocalNotificationsPlugin.show(
      hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelID,
          channelName,
          channelDescription: channelDesc,
          icon: '@mipmap/ic_launcher',
          color: AppColors.primaryBlue,
          priority: priority,
          importance: importance,
          playSound: playSound,
          enableVibration: enableVibration,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: playSound,
        ),
      ),
      payload: jsonEncode(payload),
    );
  }

  static Future<void> notificationNavigation(
    Map<String, dynamic> payload,
  ) async {
    if (payload.containsKey("type")) {
      String type = payload['type'].toString().toLowerCase();
      debugPrint("🔔 Notification clicked with type: $type");
      if (type == "lead_assigned" || type == "response_added") {
        if (Get.currentRoute != AppRoutes.mainScreen) {
          Get.toNamed(AppRoutes.mainScreen);
        }
      } else if (type == "chat_message") {
        if (Get.currentRoute != AppRoutes.mainScreen) {
          Get.toNamed(AppRoutes.mainScreen);
        }
      }
    }
  }

  static Future<void> clearAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
