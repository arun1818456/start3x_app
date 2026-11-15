import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:start3x_app/app/constants/api_constant.dart';
import 'package:start3x_app/app/constants/local_keys.dart';
import 'package:start3x_app/app/mixin/base_class.dart';
import 'package:start3x_app/app/screens/group/group_controller.dart';

class MySocketController extends GetxController with BaseClass {
  Rx<Socket?> socket = Rx<Socket?>(null);
  RxInt timeCount = 10.obs;
  Rx<Timer?> timer = Rx<Timer?>(null);
  RxBool isSocketConnected = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Only connect if user is already logged in
    if (storage.hasData(LocalKeys.userData)) {
      initializeSocket();
    }
  }

  void initializeSocket() {
    if (socket.value != null) {
      if (!socket.value!.connected) {
        debugPrint("-----------Socket Re-Connected-----------");
        socket.value!.connect();
      } else {
        joinChat();
      }
    } else {
      debugPrint("-----------Socket Init ($baseUrl)-----------");
      socket.value = io(baseUrl, {
        'autoConnect': false,
        'transports': ['websocket'],
        'reconnection': true,
      });

      socket.value!.onConnect((_) {
        debugPrint("-----------Socket Connected-----------");
        joinChat();

        if (timer.value != null) {
          timer.value!.cancel();
        }
        isSocketConnected.value = true;
        update();
      });

      socket.value!.onDisconnect((_) {
        debugPrint("-----------Socket Disconnected-----------");
        if (storage.hasData(LocalKeys.userData)) {
          startTimer();
        }
        isSocketConnected.value = false;
        update();
      });

      socket.value!.onConnectError((e) {
        debugPrint("-----------Socket Connection Error == $e-----------");
        if (storage.hasData(LocalKeys.userData)) {
          startTimer();
        }
        isSocketConnected.value = false;
        update();
      });

      onMethods();
      socket.value!.connect();
    }
  }

  /// Reconnection countdown timer (exactly matching reference)
  void startTimer() {
    timeCount.value = 10;
    if (timer.value != null) {
      timer.value!.cancel();
    }
    update();
    timer.value = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (timeCount.value < 1) {
        initializeSocket();
        t.cancel();
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (socket.value != null && !socket.value!.connected) {
            startTimer();
          }
        });
      } else {
        timeCount.value = timeCount.value - 1;
      }
      update();
    });
  }

  /// Listen on Full App Socket Methods
  void onMethods() {
    // Listen for new messages in real-time
    socket.value!.on("receive_message", (data) {
      debugPrint(">> receive_message >> $data");
      if (data != null && data is Map) {
        final mapData = Map<String, dynamic>.from(data);
        if (Get.isRegistered<GroupController>()) {
          Get.find<GroupController>().onSocketMessageReceived(mapData);
        }
      }
    });

    // Listen for typing indicator
    socket.value!.on("user_typing", (data) {
      debugPrint(">> user_typing >> $data");
      if (data != null && data is Map) {
        final mapData = Map<String, dynamic>.from(data);
        if (Get.isRegistered<GroupController>()) {
          Get.find<GroupController>().onUserTyping(mapData);
        }
      }
    });

    // Joined chat confirmation
    socket.value!.on("joined_chat", (data) {
      debugPrint(">> joined_chat >> $data");
    });

    // Chat errors
    socket.value!.on("chat_error", (data) {
      debugPrint(">> chat_error >> $data");
      if (data != null && data is Map) {
        showMySnackBar(
          data["message"]?.toString() ?? "Chat error",
          alert: true,
        );
      }
    });
  }

  /// Join passkey room (supports targetPasskey when Admin opens a client)
  void joinChat({String? targetPasskey}) {
    if (storage.hasData(LocalKeys.userData)) {
      final userData = getUserData();
      final bool isAdmin = userData.role == 'admin';
      final passkey = (targetPasskey != null && targetPasskey.isNotEmpty)
          ? targetPasskey
          : (!isAdmin && userData.passkey != null && userData.passkey!.isNotEmpty)
              ? userData.passkey!
              : (storage.read('clientPasskey')?.toString() ?? 'default');

      final sender = isAdmin ? 'Admin' : (userData.name ?? 'User');

      Map<String, dynamic> data = {
        "passkey": passkey,
        "userId": userData.id ?? '',
        "userName": sender,
        "role": userData.role ?? 'user',
      };
      debugPrint("-----------Socket Joining Chat Room: $data-----------");
      socket.value?.emit("join_chat", data);
    }
  }

  /// Send chat message via socket (supports target passkey when Admin chats with client)
  void sendChatMessage({
    required String messageText,
    String messageType = 'text',
    String? passkey,
    String? leadId,
    String? leadRank,
    List<String>? leadIds,
  }) {
    if (socket.value == null || !socket.value!.connected) {
      initializeSocket();
    }
    final userData = getUserData();
    final bool isAdmin = userData.role == 'admin';
    final activePasskey = (passkey != null && passkey.isNotEmpty)
        ? passkey
        : (!isAdmin && userData.passkey != null && userData.passkey!.isNotEmpty)
            ? userData.passkey!
            : (storage.read('clientPasskey')?.toString() ?? 'default');

    final sender = isAdmin ? 'Admin' : (userData.name ?? 'User');

    Map<String, dynamic> data = {
      "passkey": activePasskey,
      "senderId": userData.id ?? '',
      "senderName": sender,
      "role": userData.role ?? 'user',
      "messageText": messageText,
      "messageType": messageType,
      if (leadId != null && leadId.isNotEmpty) "leadId": leadId,
      if (leadRank != null && leadRank.isNotEmpty) "leadRank": leadRank,
      if (leadIds != null && leadIds.isNotEmpty) "leadIds": leadIds,
    };
    debugPrint(">>>> Socket send_message: $data");
    socket.value?.emit("send_message", data);
  }

  /// Send typing status to team
  void sendTypingStatus(bool isTyping, {String? passkey}) {
    if (socket.value == null || !socket.value!.connected) return;
    final userData = getUserData();
    final bool isAdmin = userData.role == 'admin';
    final activePasskey = (passkey != null && passkey.isNotEmpty)
        ? passkey
        : (!isAdmin && userData.passkey != null && userData.passkey!.isNotEmpty)
            ? userData.passkey!
            : (storage.read('clientPasskey')?.toString() ?? 'default');

    final sender = isAdmin ? 'Admin' : (userData.name ?? 'User');

    socket.value?.emit("typing", {
      "passkey": activePasskey,
      "userName": sender,
      "isTyping": isTyping,
    });
  }

  /// Disconnect socket manually (e.g. on logout)
  void disconnectSocket() {
    if (socket.value != null) {
      debugPrint("-----------Socket Manual Disconnect-----------");
      socket.value!.disconnect();
      socket.value = null;
      isSocketConnected.value = false;
      if (timer.value != null) {
        timer.value!.cancel();
      }
      update();
    }
  }

  @override
  void onClose() {
    timer.value?.cancel();
    socket.value?.disconnect();
    super.onClose();
  }
}
