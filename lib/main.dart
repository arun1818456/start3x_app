import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:start3x_app/app/services/notification_services.dart';
import 'package:start3x_app/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  try {
    await Firebase.initializeApp();
    await MyNotification.firebaseNotification();
  } catch (e) {
    debugPrint("Firebase init: $e");
  }
  await GetStorage.init();
  runApp(const MyApp());
}
