import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:get_storage/get_storage.dart';
import 'package:start3x_app/admin/client_management_controller.dart';
import 'package:start3x_app/app/models/lead_model.dart';
import 'package:start3x_app/app/screens/bottom_bar/bottom_controller.dart';
import 'package:start3x_app/app/screens/group/group_controller.dart';
import 'package:start3x_app/app/screens/home/home_controller.dart';
import 'package:start3x_app/constants/api_constant.dart';
import 'package:start3x_app/constants/colors.dart';
import 'package:start3x_app/constants/local_keys.dart';
import 'package:start3x_app/routes/routes.dart';
import 'package:start3x_app/services/api_handler.dart';

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
  static StreamSubscription<String>? tokenRefreshSubscription;
  static String _androidNotificationIcon = '@drawable/ic_notification';

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

      await localNotification();

      // Listen for FCM token refresh and sync to backend
      tokenRefreshSubscription?.cancel();
      tokenRefreshSubscription =
          FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        try {
          storage.write(LocalKeys.fcmToken, newToken);
          if (storage.hasData(LocalKeys.userData)) {
            final uData = storage.read(LocalKeys.userData);
            final jwt = uData?['token']?.toString() ?? '';
            if (jwt.isNotEmpty && newToken.isNotEmpty) {
              await httpRequest(
                REQUEST.put,
                updateDeviceTokenApiEndPoint,
                {"deviceToken": newToken},
                token: jwt,
              );
            }
          }
        } catch (e) {
          debugPrint("FCM token refresh sync error: $e");
        }
      });

      streamSubscription?.cancel();
      streamSubscription = FirebaseMessaging.onMessage.listen((
        RemoteMessage message,
      ) {
        final msgType = message.data['type']?.toString().toLowerCase() ?? '';
        if (msgType == 'session_expired') {
          forceLogoutToLogin(
            title: message.notification?.title ?? "Session Expired",
            description: message.notification?.body ??
                "Your account was signed in on another device.",
          );
          return;
        }
        // Suppress foreground chat banner if user is currently viewing Group Chat
        if (msgType == 'chat_message' && _isCurrentlyViewingGroupChat()) {
          return;
        }

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

      // Handle cold-start notification tap via FirebaseMessaging.getInitialMessage
      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        Future.delayed(const Duration(milliseconds: 1200), () {
          notificationNavigation(initialMessage.data);
        });
      }
    } catch (e) {
      debugPrint("🔥 Firebase notification init error: $e");
    }
  }

  static bool _isCurrentlyViewingGroupChat() {
    if (Get.currentRoute == AppRoutes.groupScreen) return true;
    if (Get.currentRoute == AppRoutes.mainScreen &&
        Get.isRegistered<BottomController>()) {
      return Get.find<BottomController>().selectedIndex == 2;
    }
    return false;
  }

  static Future<void> localNotification() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    void onNotificationTap(NotificationResponse notificationResponse) {
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
    }

    _androidNotificationIcon = '@drawable/ic_notification';
    try {
      await flutterLocalNotificationsPlugin.initialize(
        InitializationSettings(
          android: AndroidInitializationSettings(_androidNotificationIcon),
          iOS: const DarwinInitializationSettings(),
        ),
        onDidReceiveNotificationResponse: onNotificationTap,
      );
    } on PlatformException catch (e) {
      if (e.code == 'invalid_icon') {
        _androidNotificationIcon = '@mipmap/ic_launcher';
        await flutterLocalNotificationsPlugin.initialize(
          InitializationSettings(
            android: AndroidInitializationSettings(_androidNotificationIcon),
            iOS: const DarwinInitializationSettings(),
          ),
          onDidReceiveNotificationResponse: onNotificationTap,
        );
      } else {
        rethrow;
      }
    }

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
          icon: _androidNotificationIcon,
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
    if (!storage.hasData(LocalKeys.userData)) return;
    if (!payload.containsKey("type")) return;

    final userData = storage.read(LocalKeys.userData);
    final bool isAdmin = userData?['role']?.toString() == 'admin';
    final String type = payload['type'].toString().toLowerCase();
    final String passkey = payload['passkey']?.toString() ?? '';
    final String leadId = payload['leadId']?.toString() ?? '';

    debugPrint("🔔 Notification clicked -> type: $type, passkey: $passkey, leadId: $leadId");

    if (passkey.isNotEmpty && isAdmin) {
      storage.write('clientPasskey', passkey);
    }

    if (type == "session_expired") {
      forceLogoutToLogin(
        title: "Session Expired",
        description: "Your account was signed in on another device.",
      );
      return;
    }

    if (type == "chat_message") {
      if (isAdmin && passkey.isNotEmpty) {
        Get.toNamed(
          AppRoutes.groupScreen,
          arguments: {'passkey': passkey, 'showBackButton': true},
        );
      } else {
        if (Get.currentRoute != AppRoutes.mainScreen) {
          Get.offAllNamed(AppRoutes.mainScreen);
        }
        Future.delayed(const Duration(milliseconds: 250), () {
          if (Get.isRegistered<BottomController>()) {
            Get.find<BottomController>().onItemTapped(2);
          }
          if (Get.isRegistered<GroupController>()) {
            Get.find<GroupController>().fetchChatMessagesFromApi();
          }
        });
      }
      return;
    }

    if (type == "lead_assigned" ||
        type == "lead_updated" ||
        type == "response_added" ||
        type == "task_reminder" ||
        type == "task_missed" ||
        type == "deal_closed") {
      if (Get.currentRoute != AppRoutes.mainScreen) {
        Get.toNamed(
          AppRoutes.mainScreen,
          arguments: passkey.isNotEmpty ? {'passkey': passkey} : null,
        );
      }

      Future.delayed(const Duration(milliseconds: 300), () async {
        if (Get.isRegistered<HomeController>()) {
          final homeCtrl = Get.find<HomeController>();
          if (passkey.isNotEmpty && homeCtrl.clientPasskey != passkey) {
            homeCtrl.clientPasskey = passkey;
          }
          await homeCtrl.fetchLeads();
          if (leadId.isNotEmpty) {
            final LeadModel? matched =
                homeCtrl.leads.firstWhereOrNull((l) => l.id == leadId);
            if (matched != null) {
              Get.toNamed(AppRoutes.callingScreen, arguments: matched);
              return;
            }
          }
        }
        if ((type == "task_reminder" || type == "task_missed") &&
            Get.isRegistered<BottomController>()) {
          Get.find<BottomController>().onItemTapped(1);
        }
      });
      return;
    }

    if (type == "client_setup_completed" ||
        type == "web_enquiry" ||
        (type == "team_member_joined" && isAdmin)) {
      if (isAdmin) {
        if (Get.isRegistered<ClientManagementController>()) {
          Get.find<ClientManagementController>().fetchPasskeys(force: true);
        }
        if (Get.currentRoute != AppRoutes.adminDashboardScreen) {
          Get.offAllNamed(AppRoutes.adminDashboardScreen);
        }
      }
      return;
    }

    if (type == "team_member_joined" && !isAdmin) {
      Get.toNamed(AppRoutes.teamScreen);
      return;
    }

    if (type == "client_info_updated" || type == "passkey_status") {
      if (Get.currentRoute != AppRoutes.mainScreen && !isAdmin) {
        Get.offAllNamed(AppRoutes.mainScreen);
      }
    }
  }

  static Future<void> clearAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
